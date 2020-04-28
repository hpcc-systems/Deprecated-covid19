IMPORT $.Types;
metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
statsExtRec := Types.statsExtRec;

InfectionPeriod := 10;
periodDays := 7;
scaleFactor := 5;  // Lower will give more hot spots.
minActive := 20; // Minimum cases to be considered emerging

EXPORT CalcMetrics := MODULE
    EXPORT DATASET(statsExtRec) DailyStats(DATASET(statsRec) stats) := FUNCTION
        statsS := SORT(stats, location, -date);
        statsE0 := PROJECT(statsS, TRANSFORM(statsExtRec, SELF.id := COUNTER, SELF := LEFT));
        // Compute the extended data
        // Extend data with previous reading on each record. Note: sort is descending by date, so current has lower id
        statsE1 := ASSERT(JOIN(statsE0, statsE0, LEFT.location = RIGHT.location AND LEFT.id = RIGHT.id - 1,
											TRANSFORM(RECORDOF(LEFT),
                            SELF.prevCases := RIGHT.cumCases,
                            SELF.newCases := LEFT.cumCases - RIGHT.cumCases,
                            SELF.prevDeaths := RIGHT.cumDeaths;
                            SELF.newDeaths := LEFT.cumDeaths - RIGHT.cumDeaths,
                            SELF.periodCGrowth := IF(SELF.prevCases > 0, SELF.newCases / SELF.prevCases, 0),
                            SELF.periodMGrowth := IF(SELF.prevDeaths > 0, SELF.newDeaths / SELF.prevDeaths, 0),
                            SELF := LEFT), LEFT OUTER),newCases >= 0, 'Warning: newCases < 0.  Location = ' + location + '(' + date + ')');

        // Go infectionPeriod days back to see how many have recovered and how many are still active
        statsE2 := JOIN(statsE1, statsE1, LEFT.location = RIGHT.location AND LEFT.id = RIGHT.id - InfectionPeriod, TRANSFORM(RECORDOF(LEFT),
                            SELF.active := IF (LEFT.cumCases < RIGHT.cumCases, LEFT.cumCases, LEFT.cumCases - RIGHT.cumCases),
                            SELF.recovered := IF(RIGHT.cumCases < LEFT.cumDeaths, 0, RIGHT.cumCases - LEFT.cumDeaths),
                            SELF.prevActive := LEFT.prevCases - RIGHT.prevCases,
                            SELF.iMort := (LEFT.cumDeaths - RIGHT.cumDeaths) / RIGHT.cumCases,
                            SELF := LEFT), LEFT OUTER);

        statsE := statsE2;
        RETURN statsE2;
    END;
    // Calculate Metrics, given input Stats Data.
    EXPORT DATASET(metricsRec) WeeklyMetrics(DATASET(statsRec) stats, DATASET(populationRec) pops) := FUNCTION
        statsE := DailyStats(stats);
        // Now combine the records for each week.
        // First add a period to records for each state
        statsGrpd0 := GROUP(statsE, location);
        statsGrpd1 := PROJECT(statsGrpd0, TRANSFORM(RECORDOF(LEFT), SELF.period := (COUNTER-1) DIV periodDays + 1, SELF := LEFT));
        statsGrpd := GROUP(statsGrpd1, location, period);
        //OUTPUT(ctpgrpd[..10000], ALL, NAMED('ctpgrpd'));
        metricsRec doRollup(statsExtRec r, DATASET(statsExtRec) recs) := TRANSFORM
            SELF.location := r.location;
            SELF.period := r.period;
            cRecs := recs(cumCases > 0);
            mRecs := recs(cumDeaths > 0);
            cCount := COUNT(crecs);
            lastC := cRecs[1];
            firstC := cRecs[cCount];
            mCount := COUNT(mrecs);
            lastM := mRecs[1];
            firstM := mRecs[mCount];
            SELF.startDate := firstC.date;
            SELF.endDate := lastC.date;
            SELF.periodDays := IF(cCount = 0, SKIP, cCount);
            SELF.cases := lastC.cumCases;
            SELF.deaths := lastM.cumDeaths;
            SELF.newCases := IF(lastC.cumCases > firstC.prevCases, lastC.cumCases - firstC.prevCases, 0);
            SELF.newDeaths := IF(lastM.cumDeaths > firstM.prevDeaths, lastM.cumDeaths - firstM.prevDeaths, 0);
            SELF.active := lastC.active,
            SELF.recovered := lastC.recovered,
            SELF.iMort := lastC.iMort,
            //cGrowth := lastC.active / firstC.prevActive;
            cGrowth := SELF.newCases / firstC.active;
            cR := POWER(cGrowth, InfectionPeriod/cCount);
            SELF.cR := IF(cR > 0 AND SELF.active > minActive, cR, 0);
        END;

        metrics0 := ROLLUP(statsGrpd, GROUP, doRollup(LEFT, ROWS(LEFT)));
        metrics1 := JOIN(metrics0, pops, LEFT.location = RIGHT.location, TRANSFORM(RECORDOF(LEFT),
                                    SELF.population := IF (RIGHT.population > 0, RIGHT.population, 1),
                                    SELF.cases_per_capita := LEFT.cases / (SELF.population),
                                    SELF.deaths_per_capita := LEFT.deaths / (SELF.population),
                                    SELF.immunePct := LEFT.recovered / SELF.population;
                                    SELF := LEFT), LEFT OUTER);
        metricsRec calc1(metricsRec l, metricsRec r) := TRANSFORM
            prevNewDeaths := IF(r.newDeaths > 0, r.newDeaths, 1);
            mGrowth :=  l.newDeaths / prevNewDeaths;
            mR := POWER(mGrowth, InfectionPEriod/periodDays);
            SELF.mR := mR;
            R1 := IF(l.mR > 0, (l.cr + mR) / 2, l.cR);
            SELF.cmRatio := IF(mR > 0, l.cR / mR, 0);
            SELF.dcR := IF(r.cR > 0, l.cR / r.cR - 1, 0);
            SELF.dmR := IF (r.mR > 0, l.mR / r.mR - 1, 0);
            SELF.medIndicator := IF(SELF.cmRatio > 0 AND r.cmRatio > 0, l.cmRatio / r.cmRatio - 1, 0);
            SELF.sdIndicator := IF(R1 > 1, -SELF.dcR, 0);
            // Assume that cR decreases with the inverse log of time.  First we calculate the base of the log
            b := POWER(10, (l.cR/r.cR * LOG(periodDays)));
            wtp0 := POWER(b, l.cR - 1);
            // Don't project beyond 10 weeks
            wtp := IF(wtp0 > 10, 999, wtp0);
            SELF.weeksToPeak := IF(l.cR > 1, IF(l.cR < r.cR, wtp, 999), 0);
            SELF := l;
        END;
        metrics2 := JOIN(metrics1, metrics1, LEFT.location = RIGHT.location AND LEFT.period = RIGHT.period - 1,
                            calc1(LEFT, RIGHT), LEFT OUTER);
        metrics3 := JOIN(metrics2, metrics2, LEFT.location = RIGHT.location AND LEFT.period = RIGHT.period - 1,
                            calc1(LEFT, RIGHT), LEFT OUTER);

        // Gavin, why is this calculation wrong occasionally?
        metrics4 := ASSERT(PROJECT(metrics3, TRANSFORM(RECORDOF(LEFT),
                                        SELF.heatIndex := LOG(LEFT.active) * (IF(LEFT.cR > 1, LEFT.cR - 1, 0) +
                                                IF(LEFT.mr > 1,LEFT.mR - 1, 0) +
                                                IF(LEFT.medIndicator < 0, -LEFT.medIndicator, 0) +
                                                IF(LEFT.sdIndicator < 0, -LEFT.sdIndicator, 0))  / scaleFactor,
                                        SELF := LEFT)), heatIndex = 0 OR (cR > 0 OR mR > 0 OR medIndicator < 0 OR sdIndicator < 0 ), 'hi: ' + location + ',' + heatIndex + ',' + active + ',' + cR + ',' + mR + ',' + medIndicator + ',' + sdIndicator);
        metricsRec calc2(metricsRec l, metricsRec r) := TRANSFORM
            R1 := IF(r.mR > 0, (r.cr + r.mR) / 2, r.cR);
            prevState := IF(l.location = r.location, l.iState, 'Initial');
            SELF.iState := MAP(
                prevState in ['Recovered', 'Regressing'] AND r.sdIndicator < 0 AND r.active > minActive => 'Regressing',
                prevState = 'Initial' AND r.active < minActive => 'Initial',
                (prevState = 'Initial' AND r.active >= minActive) OR (prevState = 'Emerging' AND R1 >= 4.0) => 'Emerging',
                R1 >= 1.5 => 'Spreading',
                R1 >= 1.1 AND R1 < 1.5 => 'Stabilizing',
                R1 >= .9 AND R1 < 1.1 => 'Stabilized',
                prevState != 'Initial' AND (R1 > .1 OR r.active > minActive) => 'Recovering',
                prevState != 'Initial' AND R1 <= .1 AND r.active <= minActive => 'Recovered',
                'Initial');
            cR := IF(r.cR > 1, r.cR - 1, 0);
            mR := IF(r.mR > 1, r.mR - 1, 0);
            mi := IF(r.medIndicator < 0, -r.medIndicator, 0);
            sdi := IF(r.sdIndicator < 0, -r.sdIndicator, 0);
            SELF.heatIndex := LOG(r.active) * (cR + mR + mi + sdi) / scaleFactor;
            SELF := r;          
        END;
        metrics5 := SORT(metrics4, location, -period);
        metrics6 := ITERATE(metrics5, calc2(LEFT, RIGHT));
        metrics := SORT(metrics6, location, period);
        return metrics;
    END;
END;
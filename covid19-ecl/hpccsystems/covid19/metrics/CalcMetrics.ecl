IMPORT $.Types;
metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
statsExtRec := Types.statsExtRec;

InfectionPeriod := 10;
scaleFactor := 5;  // Lower will give more hot spots.
minActive := 20; // Minimum cases to be considered emerging

EXPORT CalcMetrics := MODULE
    EXPORT DATASET(statsExtRec) DailyStats(DATASET(statsRec) stats) := FUNCTION
        statsS := SORT(stats, location, -date);
        statsE0 := PROJECT(statsS, TRANSFORM(statsExtRec, SELF.id := COUNTER, SELF := LEFT));
        // Compute the extended data
        // Extend data with previous reading on each record. Note: sort is descending by date, so current has lower id
        statsE1 := JOIN(statsE0, statsE0, LEFT.location = RIGHT.location AND LEFT.id = RIGHT.id - 1, TRANSFORM(RECORDOF(LEFT),
                            SELF.prevCases := RIGHT.cumCases,
                            SELF.newCases := LEFT.cumCases - RIGHT.cumCases,
                            SELF.prevDeaths := RIGHT.cumDeaths;
                            SELF.newDeaths := LEFT.cumDeaths - RIGHT.cumDeaths,
                            SELF.periodCGrowth := IF(SELF.prevCases > 0, SELF.newCases / SELF.prevCases, 0),
                            SELF.periodMGrowth := IF(SELF.prevDeaths > 0, SELF.newDeaths / SELF.prevDeaths, 0),
                            SELF := LEFT), LEFT OUTER);

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
        statsGrpd1 := PROJECT(statsGrpd0, TRANSFORM(RECORDOF(LEFT), SELF.period := (COUNTER-1) DIV 7 + 1, SELF := LEFT));
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
            SELF.newCases := lastC.cumCases - firstC.prevCases;
            SELF.newDeaths := lastM.cumDeaths - firstM.prevDeaths;
            SELF.active := lastC.active,
            SELF.recovered := lastC.recovered,
            SELF.iMort := lastC.iMort,
            //cGrowth := lastC.active / firstC.prevActive;
            cGrowth := SELF.newCases / firstC.prevActive;
            mGrowth := (lastM.cumDeaths-firstC.prevDeaths) / firstC.prevDeaths;
            cR := POWER(POWER(cGrowth, 1/cCount),InfectionPeriod);
            mR := POWER(POWER(mGrowth, 1/mCount),InfectionPeriod);
            SELF.cR := IF(cR > 0 AND SELF.active > minActive, cR, 0);
            SELF.mR := IF(mR > 0 AND SELF.deaths > minActive, mR, 0);
            SELF.cmRatio := IF(mR > 0, SELF.cR / SELF.mR, 0);
        END;

        metrics0 := ROLLUP(statsGrpd, GROUP, doRollup(LEFT, ROWS(LEFT)));
        metrics1 := JOIN(metrics0, pops, LEFT.location = RIGHT.location, TRANSFORM(RECORDOF(LEFT),
                                    SELF.population := IF (RIGHT.population > 0, RIGHT.population, 1),
                                    SELF.cases_per_capita := LEFT.cases / (SELF.population),
                                    SELF.deaths_per_capita := LEFT.deaths / (SELF.population),
                                    SELF.immunePct := LEFT.recovered / SELF.population;
                                    SELF := LEFT), LEFT OUTER);
        metricsRec calc1(metricsRec l, metricsRec r) := TRANSFORM
            SELF.dcR := IF(r.cR > 0, l.cR / r.cR - 1, 0);
            SELF.dmR := IF (r.mR > 0, l.mR / r.mR - 1, 0);
            SELF.medIndicator := IF(l.cmRatio > 0 AND r.cmRatio > 0, l.cmRatio / r.cmRatio - 1, 0);
            SELF.sdIndicator := IF(l.cR > 1, -SELF.dcR, 0);
            lgr := MAX(l.cR, l.mR);
            rgr := MAX(r.cR, r.mR);
            // Assume that cR decreases with the inverse log of time.  First we calculate the base of the log
            b := POWER(10, (lgr/rgr * LOG(7)));
            wtp0 := POWER(b, lgr-1);
            // Don't project beyond 10 weeks
            wtp := IF(wtp0 > 10, 999, wtp0);
            SELF.weeksToPeak := IF(lgr > 1, IF(lgr < rgr, wtp, 999), 0);
            SELF := l;
        END;
        metrics2 := JOIN(metrics1, metrics1, LEFT.location = RIGHT.location AND LEFT.period = RIGHT.period - 1,
                            calc1(LEFT, RIGHT), LEFT OUTER);
        // Gavin, why is this calculation wrong occasionally?
        metrics3 := ASSERT(PROJECT(metrics2, TRANSFORM(RECORDOF(LEFT),
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
        metrics4 := SORT(metrics3, location, -period);
        metrics5 := ITERATE(metrics4, calc2(LEFT, RIGHT));
        metrics := SORT(metrics5, location, period);
        return metrics;
    END;
END;
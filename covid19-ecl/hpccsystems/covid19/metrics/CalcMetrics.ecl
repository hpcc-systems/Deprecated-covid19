IMPORT Types;
metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;

InfectionPeriod := 10;
scaleFactor := 5;  // Lower will give more hot spots.



// Calculate Metrics, given input Stats Data.
EXPORT DATASET(metricsRec) CalcMetrics(DATASET(statsRec) stats, DATASET(populationRec) pops) := FUNCTION
    statsExtRec := RECORD(statsRec)
        UNSIGNED id;
        INTEGER period := 1;
        UNSIGNED prevCases := 0;
        UNSIGNED newCases := 0;
        UNSIGNED prevDeaths := 0;
        UNSIGNED newDeaths := 0;
        REAL periodCGrowth := 0;
        REAL periodMGrowth := 0;
        UNSIGNED active := 0;
        UNSIGNED prevActive := 0;
        UNSIGNED recovered := 0;
        REAL iMort := 0;
    END;

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
        SELF.cR := IF(cR > 0 AND SELF.cases > 10, cR, 0);
        SELF.mR := IF(mR > 0 AND SELF.deaths > 10, mR, 0);
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
        SELF.sdIndicator := -SELF.dcR;
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
    metrics := PROJECT(metrics2, TRANSFORM(RECORDOF(LEFT),
                                    SELF.heatIndex := LOG(LEFT.active) * (IF(LEFT.cR > 1, (LEFT.cR - 1), 0) +
                                            IF(LEFT.mr > 1,(LEFT.mR - 1), 0) +
                                            IF(LEFT.medIndicator < 0, -LEFT.medIndicator, 0) +
                                            IF(LEFT.sdIndicator < 0, -LEFT.sdIndicator, 0)) / scaleFactor,
                                    SELF := LEFT));
    return metrics;
END;
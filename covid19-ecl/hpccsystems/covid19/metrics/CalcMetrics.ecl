IMPORT $.Types;
IMPORT Python3 AS Python;
metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
statsExtRec := Types.statsExtRec;



EXPORT CalcMetrics := MODULE
		SHARED InfectionPeriod := 10;
		SHARED periodDays := 7;
		SHARED scaleFactor := 5;  // Lower will give more hot spots.
		SHARED minActDefault := 20; // Minimum cases to be considered emerging, by default.
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
    EXPORT DATASET(metricsRec) WeeklyMetrics(DATASET(statsRec) stats, DATASET(populationRec) pops, UNSIGNED minActive = minActDefault) := FUNCTION
				STRING generateCommentary(DATASET(metricsRec) recs, UNSIGNED minActive) := EMBED(Python)
					outstr = ''
					for rec in recs:
						location = rec[1].strip()
						iState = rec[5].strip()
						cases = rec[6]
						deaths = rec[7]
						active = rec[8]
						cr = rec[9]
						mr = rec[10]
						r = rec[11]
						sdi = rec[12]
						mdi = rec[13]
						hi = rec[14]
						infCount = rec[16]
						newCases = rec[18]
						newDeaths = rec[19]
						peakCases = rec[27]
						peakDeaths = rec[28]
						if r < 1:
							if r == 0:
								sev = 1.0
							else:
							 sev = 1/r
						else:
							sev = r
						adv = ''
						if sev > 2:
							adv = 'very quickly '
						elif sev > 1.5:
							adv = 'quickly '
						elif sev < 1.05:
							adv = ''
						elif sev < 1.1:
							adv = 'very slowly '
						elif sev < 1.3:
							adv = 'slowly '
						if sev < 1.05:
							dir = 'steady'
						elif r > 1.0:
							dir = 'increasing'
						else:
							dir = 'decreasing'
						implstr = adv + dir
						outstr = location + ' is currently ' + iState + '. '
						if r > 0:
							rstr = 'The infection is ' + implstr + ' (R = ' + str(r) + '). '
						else:
							rstr = 'It is too early to estimate the growth rate (R). '
						if iState != 'Recovered':
							outstr += rstr
						scaleStr = 'There are currently ' + str(active) + ' active cases. '
						if iState == 'Emerging':
							scaleStr = 'This outbreak is based on a small number of detected infections (' + str(active) + ' cases) and may be quickly contained by policy measures. '
						elif iState == 'Spreading':
							scaleStr = 'This outbreak is probably beyond containment (' + str(active) + ' active cases) and must be mitigated through policy and behavioral changes. '
						elif iState == 'Regressing':
							scaleStr = 'The infection appeared to have been recovering, but has recently begun to grow again (' + str(active) + ' active cases). '
						elif iState == 'Initial':
							scaleStr = 'No significant infection has been detected. '
						elif iState == 'Stabilized':
							scaleStr += 'This implies approximately ' + str(newCases) + ' new cases and ' + str(newDeaths) + ' deaths per week. '
						elif iState == 'Recovered':
							scaleStr = 'No significant active infections remain. '
						elif iState == 'Recovering':
							casePct = 0
							deathsPct = 0
							if peakCases > 0:
								casePct = (peakCases - newCases) / float(peakCases) * 100
							if peakDeaths > 0:
								deathsPct = (peakDeaths - newDeaths) / float(peakDeaths) * 100
							scaleStr += 'New Cases are currently ' + str(newCases) + ' per week, down ' + str(round(casePct)) + '% from a peak of ' + str(peakCases) + ' per week. '
							scaleStr += 'New Deaths are currently ' + str(newDeaths) + ' per week, down ' + str(round(deathsPct)) + '% from a peak of ' + str(peakDeaths) + ' per week. '
						outstr += scaleStr
						infstr = ''
						if infCount > 1:
							ord = 'th'
							if infCount == 2:
								ord = 'nd'
							elif infCount == 3:
								ord = 'rd'
							infstr = 'This is the ' + str(infCount) + ord + ' round of infection. '
						outstr += infstr
						sdString = ''
						if sdi < -.05:
							sdString = 'It appears that the level of social distancing is decreasing, which may result in higher levels of infection growth. '
							outstr += sdString
						if mdi < -.05:
							mdString = 'The mortality rate is growing faster than the case rate, implying that there may be a deterioration in medical conditions, probably due to '
							if r >= 1.5 and active > minActive:
								mdReason = 'an overload of the local medical capacity. '
							else:
								mdReason = 'inadequate testing availability. '
							mdString += mdReason
							outstr += mdString
						hiString = ''
						if hi >= 1.0:
							hiReason = ' various factors. '
							hiString = location + ' is currently on the HotSpot list due to '
							if r > 1.5:
								hiReason = ' rapid spread. '
							elif sdi < 0 or mdi < 0:
								if sdi < mdi:
									hiReason = ' apparent decrease in social distancing measures. '
								else:
									hiReason = ' apparent deterioration of medical conditions. '
							hiString += hiReason
							outstr += hiString
					return outstr
				ENDEMBED;
        statsE := DailyStats(stats);
        // Now combine the records for each week.
        // First add a period to records for each state
        statsGrpd0 := GROUP(statsE, location);
        statsGrpd1 := PROJECT(statsGrpd0, TRANSFORM(RECORDOF(LEFT), SELF.period := (COUNTER-1) DIV periodDays + 1, SELF := LEFT));
        statsGrpd := GROUP(statsGrpd1, location, period);
        metricsRec doRollup(statsExtRec r, DATASET(statsExtRec) recs) := TRANSFORM
            SELF.location := r.location;
						SELF.fips := r.fips;
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
						cGrowth := SELF.newCases / firstC.active;
            cR := POWER(cGrowth, InfectionPeriod/cCount);
            SELF.cR := MIN(cR, 9.99);
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
            mR := MIN(POWER(mGrowth, InfectionPeriod/periodDays), 9.99);
            SELF.mR := mR;
						SELF.cR := l.cR;
						// Use Geometric Mean of cR and mR to compute an estimate of R,
						// since we're working with growth statistics.
            R1 := IF(SELF.mR > 0 AND SELF.cR > 0, POWER(SELF.cR * SELF.mR, .5), IF(SELF.cR > 0, SELF.cR, SELF.mR));
						SELF.R := R1;
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
            prevState := IF(l.location = r.location, l.iState, 'Initial');
						prevInfectCount := IF(l.location = r.location, l.infectionCount, 1);
						R1 := r.R;
            SELF.iState := MAP(
                prevState in ['Recovered', 'Recovering'] AND R1 >= 1.1 => 'Regressing',
                prevState = 'Initial' AND r.active = 0 => 'Initial',
                R1 >= 1.5 AND r.active >= 1 AND r.active < minActive => 'Emerging',
                R1 >= 1.5 => 'Spreading',
                R1 >= 1.1 AND R1 < 1.5 => 'Stabilizing',
                R1 >= .9 AND R1 < 1.1 => 'Stabilized',
                prevState != 'Initial' AND (R1 > .1 OR r.active > minActive) => 'Recovering',
                prevState != 'Initial' AND R1 <= .1 AND r.active <= minActive => 'Recovered',
                'Initial');
						SELF.infectionCount := IF(prevState != 'Regressing' AND self.iState = 'Regressing', prevInfectCount + 1, prevInfectCount);
						SELF.peakCases := IF(l.location = r.location, IF(r.newCases > l.peakCases OR SELF.iState = 'Regressing', r.newCases, l.peakCases), r.newCases);
						SELF.peakDeaths := IF(l.location = r.location, IF(r.newDeaths > l.peakDeaths OR SELF.iState = 'Regressing', r.newDeaths, l.peakDeaths), r.newDeaths);			
            cR := IF(r.cR > 1, r.cR - 1, 0);
            mR := IF(r.mR > 1, r.mR - 1, 0);
            mi := IF(r.medIndicator < 0, -r.medIndicator, 0);
            sdi := IF(r.sdIndicator < 0, -r.sdIndicator, 0);
            SELF.heatIndex := LOG(r.active) * (cR + mR + mi + sdi) / scaleFactor;
            SELF := r;          
        END;
        metrics5 := SORT(metrics4, location, -period);
        metrics6 := ITERATE(metrics5, calc2(LEFT, RIGHT));
				metricsRec addCommentary(metricsRec rec) := TRANSFORM
					SELF.commentary := generateCommentary(DATASET([rec], metricsRec), minActive);
					SELF := rec;
				END;
				metrics7 := PROJECT(metrics6, addCommentary(LEFT));
        metrics := SORT(metrics7, location, period);
        return metrics;
    END;
END;
IMPORT $.Types2 AS Types;
IMPORT $.Configuration AS Config;
IMPORT Python3 AS Python;
metric_t := Types.metric_t;
count_t := Types.count_t;
inputRec := Types.InputRec;
statsRec := Types.statsRec;

EXPORT CalcStats := MODULE
  SHARED InfectionPeriod := Config.InfectionPeriod;
  SHARED PeriodDays := Config.PeriodDays;
  SHARED ScaleFactor := Config.ScaleFactor;  // Lower will give more hot spots.
  SHARED MinActDefault := Config.MinActDefault; // Minimum cases to be considered emerging, by default.
  SHARED MinActPer100k := Config.MinActPer100k; // Minimum active per 100K population to be considered emerging.
  SHARED infectedConfirmedRatio := Config.InfectedConfirmedRatio; // Calibrated by early antibody testing (rough estimate),
                                                                  // and ILI Surge statistics.
  SHARED locDelim := Config.LocDelim; // Delimiter between location terms.

  SHARED DATASET(statsRec) smoothData(DATASET(statsRec) recs) := FUNCTION
    // Filter out any daily increases that imply an R > 10.
    // This is to deal with situations where a locality changes their reporting policy and dumps a large batch
    // of cases or deaths into a single day.
    // We do this by computing a 7-day moving average and setting new cases or deaths to the 7-day average if
    // the implied growth would be greater than R=10.
    // In the process, we add the 7-day MAs, as well as adjusted cumulative counts.  All growth stats are then based
    // on the adjusted counts.
    statsRecE := RECORD(statsRec)
      SET OF count_t casesHistory := [];
      SET OF count_t deathsHistory := [];
    END;
    // Calculate the 7-day MA
    recs1 := DISTRIBUTE(recs, HASH32(location));
    // Sort by location and ascending date
    recs2 := SORT(recs1, location, date, LOCAL);
    // Convert to extended record
    recs3 := PROJECT(recs2, TRANSFORM(statsRecE, SELF := LEFT));
    // Smooth data and calculate basic inter-period stats while we're at it.
    statsRecE calc7dma(statsRecE le, statsRecE ri) := TRANSFORM
      newCases := IF(le.location = ri.location AND ri.cumCases > le.cumCases, ri.cumCases - le.cumCases, 0);
      cases7dma := IF(le.location != ri.location OR COUNT(le.casesHistory) = 0, 0, AVE(le.casesHistory));
      adjNewCases := IF(cases7dma > 0 AND newCases > 2.25 * cases7dma, cases7dma * 2.25, newCases);
      casesHist := IF(le.location != ri.location, ri.casesHistory, [adjNewCases] + le.casesHistory)[..7];
      SELF.casesHistory := casesHist;
      SELF.cases7dma := cases7dma;
      SELF.newCases := adjNewCases;
      SELF.prevCases := IF(le.location = ri.location, le.cumCases, 0);
      SELF.adjPrevCases := IF(le.location = ri.location, le.adjCumCases, 0);
      SELF.adjCumCases := SELF.adjPrevCases + adjNewCases;
      newDeaths := IF(le.location = ri.location AND ri.cumDeaths > le.cumDeaths, ri.cumDeaths - le.cumDeaths, 0);
      deaths7dma := IF(le.location != ri.location OR COUNT(le.deathsHistory) = 0, 0, AVE(le.deathsHistory));
      adjNewDeaths := IF(deaths7dma > 0 AND newDeaths > 2.25 * deaths7dma, deaths7dma * 2.25, newDeaths);
      deathsHist := IF(le.location != ri.location, ri.deathsHistory, [adjNewDeaths] + le.deathsHistory)[..7];
      SELF.deathsHistory := deathsHist;
      SELF.deaths7dma := deaths7dma;
      SELF.newDeaths := adjNewDeaths;
      SELF.prevDeaths := IF(le.location = ri.location, le.cumDeaths, 0);
      SELF.adjPrevDeaths := IF(le.location = ri.location, le.adjCumDeaths, 0);
      SELF.adjCumDeaths := SELF.adjPrevDeaths + adjNewDeaths;
      SELF := ri;
    END;
    recs4 := ITERATE(recs3, calc7dma(LEFT, RIGHT), LOCAL);
    recs5 := SORT(recs4, location, -date);
    recs6 := PROJECT(recs5, statsRec);
    return recs6;
  END;
  EXPORT DATASET(statsRec) DailyStats(DATASET(inputRec) stats, UNSIGNED level, UNSIGNED asOfDate = 0) := FUNCTION
    // Fiter stats to start at asOfDate
    stats0 := IF(asOfDate = 0, stats, stats(date < asOfDate));
    // Add composite location information
    statsRec addLocation(inputRec inp, UNSIGNED lev) := TRANSFORM
      L0Loc := 'The World';
      L1Loc := inp.Country;
      L2Loc := inp.Country + locDelim + inp.Level2;
      L3Loc := inp.Country + locDelim + inp.Level2 + locDelim + inp.Level3;
      SELF.Location := IF(lev = 3, L3Loc, IF(lev = 2, L2Loc, IF(lev=1, L1Loc, L0Loc)));
      SELF := inp;
    END;
    stats1 := PROJECT(stats0, addLocation(LEFT, level));
    // Add record id
    stats2 := SORT(stats1, location, -date);
    stats3 := PROJECT(stats2, TRANSFORM(RECORDOF(LEFT), SELF.id := COUNTER, SELF := LEFT));
    // Get rid of any obsolete locations (i.e. locations that don't have data for the latest date)
    latestDate := MAX(stats3, date);
    obsoleteLocations := DEDUP(stats3, location)(date < latestDate);
    stats4 := JOIN(stats3, obsoleteLocations, LEFT.location = RIGHT.location, LEFT ONLY);
    // Remove spurious data dumps by smoothing and 
    // compute basic delta stats between latest period and previous period
    stats5 := smoothData(stats4);
    // Go infectionPeriod days back to see how many have recovered and how many are still active per SIR model
    stats6 := JOIN(stats5, stats5, LEFT.location = RIGHT.location AND LEFT.id = RIGHT.id - InfectionPeriod, TRANSFORM(RECORDOF(LEFT),
                        SELF.active := IF (LEFT.cumCases >= RIGHT.cumCases, LEFT.cumCases - RIGHT.cumCases, 0),
                        SELF.recovered := IF(RIGHT.cumCases < LEFT.cumDeaths, 0, RIGHT.cumCases - LEFT.cumDeaths),
                        SELF.prevActive := IF(LEFT.prevCases >= RIGHT.prevCases, LEFT.prevCases - RIGHT.prevCases, 0),
                        SELF.cfr := LEFT.adjCumDeaths / RIGHT.adjCumCases,
                        SELF := LEFT), LEFT OUTER);
    RETURN stats6;
  END;  // Daily Stats
  EXPORT statsRec RollupStats(DATASET(statsRec) stats, UNSIGNED rollupLevel) := FUNCTION
    // Valid rollup levels are 1 or 2.  Since 3 is the lowest level
    statsG0 := GROUP(SORT(stats, date), date);
    statsG1 := GROUP(SORT(stats, Country, date), Country, date);
    statsG2 := GROUP(SORT(stats, Country, Level2, date), Country, Level2, date);
    statsG := IF(rollupLevel = 0, statsG0, IF(rollupLevel = 1, statsG1, statsG2));
    statsRec doRollup(statsRec rec, DATASET(statsRec) children) := TRANSFORM
      locName := IF(rollupLevel = 0, 'The World', IF(rollupLevel = 1, rec.Country, rec.Country + locDelim + rec.Level2));
      SELF.location := locName;
      SELF.Country := IF(rollupLevel = 0, '', rec.Country);
      SELF.Level2 := IF(rollupLevel <= 1, '', rec.Level2);
      SELF.Level3 := '';
      SELF.date := rec.date;
      // Counts can be simply summed to get the rollup value
      SELF.cumCases := SUM(children, cumCases);
      SELF.cumDeaths := SUM(children, cumDeaths);
      SELF.cumHosp := SUM(children, cumHosp);
      SELF.tested := SUM(children, tested);
      SELF.negative := SUM(children, negative);
      SELF.positive := SUM(children, positive);
      SELF.population := SUM(children, population);
      SELF.prevCases := SUM(children, prevCases);
      SELF.newCases := SUM(children, newCases);
      SELF.prevDeaths := SUM(children, prevDeaths);
      SELF.newDeaths := SUM(children, newDeaths);
      SELF.active := SUM(children, active);
      SELF.prevActive := SUM(children, prevActive);
      SELF.recovered := SUM(children, recovered);
      SELF.cases7dma := SUM(children, cases7dma);
      SELF.deaths7dma := SUM(children, deaths7dma);
      SELF.adjCumCases := SUM(children, adjCumCases);
      SELF.adjCumDeaths := SUM(children, adjCumDeaths);
      SELF.adjPrevCases := SUM(children, adjPrevCases);
      SELF.adjPrevDeaths := SUM(children, adjPrevDeaths);
      // We need to do population-weighted average for CFR
      SELF.cfr := SUM(children, (REAL8)cfr * population / SELF.population);
    END;
    statsRolled := ROLLUP(statsG, GROUP, doRollup(LEFT, ROWS(LEFT)));
    RETURN SORT(statsRolled, location, -date);
  END; // RollupStats
  EXPORT DATASET(StatsRec) MergeStats(DATASET(StatsRec) rollupRecs, DATASET(StatsRec) sourceRecs, UNSIGNED level) := FUNCTION
    // Favor the rolled up record if it exists, otherwise take the source record
    // But if the source record exist, take fips, lat and long from the source, since the rollup
    // can't determine those.
    merged := JOIN(rollupRecs, sourceRecs, LEFT.location = RIGHT.location AND LEFT.date = RIGHT.date,
                    TRANSFORM(RECORDOF(LEFT),
                              SELF.fips := RIGHT.fips,
                              SELF.latitude := RIGHT.latitude,
                              SELF.longitude := RIGHT.longitude,
                              SELF := IF(LEFT.location != '', LEFT, RIGHT)), FULL OUTER);
    RETURN SORT(merged, location, -date);
  END;
END; // CalcStats
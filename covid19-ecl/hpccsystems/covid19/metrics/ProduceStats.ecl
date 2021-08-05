#WORKUNIT('name', 'Produce_Daily_Stats');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types2 AS Types;
IMPORT $ AS COVID19;
IMPORT COVID19.Paths;

inputRec := Types.inputRec;
statsRec := Types.statsRec;

CalcStats := COVID19.CalcStats;

minSpreadingInfections := 500;

// Read Input Superfiles
L1InputDat := DATASET(Paths.InputLevel1, inputRec, THOR);
L2InputDat := DATASET(Paths.InputLevel2, inputRec, THOR);
//OUTPUT(L2InputDat(date > 20200629), ALL, NAMED('L2Input'));
// We need to roll up the input data, L2 Rollup = Rollup(L3);  L1 Rollup = Rollup(L2 Rollup + L2) ;  It does not work well to rollup the stats.  We need to run
// stats on the rolled up inputs.
L3InputDat := DATASET(Paths.InputLevel3, inputRec, THOR);
L2InputRollup0 := TABLE(L3InputDat, {Country, Level2, date, totCases := SUM(GROUP, cumCases), totDeaths := SUM(GROUP, cumDeaths), totPopulation := SUM(GROUP, population),
                          tot_vacc_dist := SUM(GROUP, vacc_total_dist), tot_vacc_admin := SUM(GROUP, vacc_total_admin), 
                          tot_vacc_ppl := SUM(GROUP, vacc_total_people),
                          tot_vacc_complete := SUM(GROUP, vacc_people_complete)}, Country, Level2, date);
L2InputRollup := PROJECT(L2InputRollup0, TRANSFORM(inputRec,
                        SELF.country := LEFT.country,
                        SELF.Level2 := LEFT.Level2,
                        SELF.Level3 := '',
                        SELF.cumCases := LEFT.totCases,
                        SELF.cumDeaths := LEFT.totDeaths,
                        SELF.population := LEFT.totPopulation,
                        SELF.vacc_total_dist := LEFT.tot_vacc_dist,
                        SELF.vacc_total_admin := LEFT.tot_vacc_admin,
                        SELF.vacc_total_people := LEFT.tot_vacc_ppl,
                        SELF.vacc_people_complete := LEFT.tot_vacc_complete,
                        SELF.FIPS := '',
                        SELF.date := LEFT.date));
//OUTPUT(L2InputRollup, ALL, NAMED('L2InputRollup'));
//OUTPUT(L2InputDat, ALL, NAMED('L2InputDat'));
L1InputRollup0 := JOIN(L2InputRollup, L2InputDat, LEFT.Country = RIGHT.Country AND LEFT.Level2 = RIGHT.Level2 AND LEFT.date = RIGHT.date, TRANSFORM(RECORDOF(LEFT),
                  SELF := IF(LEFT.country != '', LEFT, RIGHT)), FULL OUTER);
L1InputRollup1 := TABLE(L1InputRollup0, {Country, date, totCases := SUM(GROUP, cumCases), totDeaths := SUM(GROUP, cumDeaths), totPopulation := SUM(GROUP, population),
                          tot_vacc_dist := SUM(GROUP, vacc_total_dist), tot_vacc_admin := SUM(GROUP, vacc_total_admin), 
                          tot_vacc_ppl := SUM(GROUP, vacc_total_people),
                          tot_vacc_complete := SUM(GROUP, vacc_people_complete)}, Country, date);
                          
L1InputRollup := PROJECT(L1InputRollup1, TRANSFORM(inputRec,
                        SELF.country := LEFT.country,
                        SELF.Level2 := '',
                        SELF.Level3 := '',
                        SELF.cumCases := LEFT.totCases,
                        SELF.cumDeaths := LEFT.totDeaths,
                        SELF.population := LEFT.totPopulation,
                        SELF.vacc_total_dist := LEFT.tot_vacc_dist,
                        SELF.vacc_total_admin := LEFT.tot_vacc_admin,
                        SELF.vacc_total_people := LEFT.tot_vacc_ppl,
                        SELF.vacc_people_complete := LEFT.tot_vacc_complete,
                        SELF.FIPS := '',
                        SELF.date := LEFT.date));
// Start with the Level 3 Stats
L3Stats := CalcStats.DailyStats(L3InputDat, 3);

OUTPUT(L3Stats, , Paths.StatsLevel3, Thor, OVERWRITE);
//OUTPUT(L3Stats[..10000], ALL, NAMED('L3Stats'));

// Now the Level 2 Stats based on L2 input
//OUTPUT(L2InputDat(date>=20210201), ALL, NAMED('L2InputDat'));
L2Stats := CalcStats.DailyStats(L2InputDat, 2, noFilter := FALSE);
//OUTPUT(L2Stats(date >= 20210201), ALL, NAMED('L2Stats'));

// Run the stats based on the L2 Input Rollup
//L2Rollup := CalcStats.RollupStats(L3Stats, 2);
L2Rollup := CalcStats.DailyStats(L2InputRollup, 2);
//OUTPUT(L2Rollup(Country = 'INDIA'), ALL, NAMED('L2Rollup'));

// Merge the L2 Stats and the L2 Rollup.  Favor the rollup stats
// when there are overlaps.
L2Merged := CalcStats.MergeStats(L2Rollup, L2Stats, 2);  // Merge at Level 2
OUTPUT(L2Merged, , Paths.StatsLevel2, Thor, OVERWRITE);
//OUTPUT(L2Merged(date > 20200531), ALL, NAMED('L2Merged'));

// Calculate L1 Stats from L1 source data
L1Stats := CalcStats.DailyStats(L1InputDat, 1, noFilter := FALSE);
//OUTPUT(L1Stats, ALL, NAMED('L1Stats'));
// Also calculate the stats based on the L1 Input Rollup.
//L1Rollup := CalcStats.RollupStats(L2Merged, 1);
L1Rollup := CalcStats.DailyStats(L1InputRollup, 1);
//OUTPUT(L1Rollup, ALL, NAMED('L1Rollup'));

// Merge the L1 Stats and the L1 Rollup.  Favor the rollup stats
// when things overlap
L1Merged := CalcStats.MergeStats(L1Rollup, L1Stats, 1);

OUTPUT(L1Merged, , Paths.StatsLevel1, Thor, OVERWRITE);

// Rollup the L1 Stats to L0 (The World).
L0Stats0 := CalcStats.RollupStats(L1Merged, 0);
// Call merge, even though there's nothing to merge with, since some stats get recomputed there.
L0Stats := CalcStats.MergeStats(L0Stats0, DATASET([], statsRec), 0);
OUTPUT(L0Stats, , Paths.StatsLevel0, Thor, OVERWRITE);

import $.^.scheduler.utils;
utils.runOrPublishByName('Produce_Daily_Stats', 'RUN');
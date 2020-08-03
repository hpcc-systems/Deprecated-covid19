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
L3InputDat := DATASET(Paths.InputLevel3, inputRec, THOR);

// Start with the Level 3 Stats
L3Stats := CalcStats.DailyStats(L3InputDat, 3);
OUTPUT(L3Stats, , Paths.StatsLevel3, Thor, OVERWRITE);
//OUTPUT(L3Stats[..10000], ALL, NAMED('L3Stats'));

// Now the Level 2 Stats based on L2 input
L2Stats := CalcStats.DailyStats(L2InputDat, 2);
//OUTPUT(L2Stats[..10000], ALL, NAMED('L2Stats'));

// Rollup the L3 stats to L2
L2Rollup := CalcStats.RollupStats(L3Stats, 2);
//OUTPUT(L2Rollup(Country = 'INDIA'), ALL, NAMED('L2Rollup'));

// Merge the L2 Stats and the L2 Rollup.  Favor the rollup stats
// when there are overlaps.
L2Merged := CalcStats.MergeStats(L2Rollup, L2Stats, 2);  // Merge at Level 2
OUTPUT(L2Merged, , Paths.StatsLevel2, Thor, OVERWRITE);
//OUTPUT(L2Merged(date > 20200531), ALL, NAMED('L2Merged'));

// Calculate L1 Stats from L1 source data
L1Stats := CalcStats.DailyStats(L1InputDat, 1);
OUTPUT(L1Stats, ALL, NAMED('L1Stats'));
// Also rollup the merged L2 to produce a L1 Rollup.
L1Rollup := CalcStats.RollupStats(L2Merged, 1);
OUTPUT(L1Rollup, ALL, NAMED('L1Rollup'));

// Merge the L1 Stats and the L1 Rollup.  Favor the rollup stats
// when things overlap
L1Merged := CalcStats.MergeStats(L1Rollup, L1Stats, 1);
OUTPUT(L1Merged, , Paths.StatsLevel1, Thor, OVERWRITE);

// Rollup the L1 Stats to L0 (The World).
L0Stats0 := CalcStats.RollupStats(L1Merged, 0);
// Call merge, even though there's nothing to merge with, since some stats get recomputed there.
L0Stats := CalcStats.MergeStats(L0Stats0, DATASET([], statsRec), 0);
OUTPUT(L0Stats, , Paths.StatsLevel0, Thor, OVERWRITE);
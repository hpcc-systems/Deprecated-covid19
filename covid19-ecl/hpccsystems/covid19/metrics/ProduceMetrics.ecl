#WORKUNIT('name', 'Produce_Weekly_Metrics');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types2 AS Types;
IMPORT $.CalcMetrics2 AS CalcMetrics;
IMPORT $ AS COVID19;
IMPORT COVID19.Paths;

statsRec := Types.statsRec;
metricsRec := Types.metricsRec;

L1MinSpreadingInfections := 2000;
L2MinSpreadingInfections := 500;
L3MinSpreadingInfections := 100;

// Read Stats and produce Metrics
L0Stats := DATASET(Paths.StatsLevel0, statsRec, THOR);
L1Stats := DATASET(Paths.StatsLevel1, statsRec, THOR);
L2Stats := DATASET(Paths.StatsLevel2, statsRec, THOR);
L3Stats := DATASET(Paths.StatsLevel3, statsRec, THOR);

L0Metrics := CalcMetrics.WeeklyMetrics(L0Stats, L1MinSpreadingInfections);
worldCFR := L0Metrics(period=1)[1].cfr;
L1Metrics := CalcMetrics.WeeklyMetrics(L1Stats, L1MinSpreadingInfections, worldCFR);
L2Metrics := CalcMetrics.WeeklyMetrics(L2Stats, L2MinSpreadingInfections, worldCFR);
L3Metrics := CalcMetrics.WeeklyMetrics(L3Stats, L3MinSpreadingInfections, worldCFR);

OUTPUT(L0Metrics, , Paths.MetricsLevel0, Thor, OVERWRITE);
OUTPUT(L1Metrics, , Paths.MetricsLevel1, Thor, OVERWRITE);
OUTPUT(L2Metrics, , Paths.MetricsLevel2, Thor, OVERWRITE);
OUTPUT(L3Metrics, , Paths.MetricsLevel3, Thor, OVERWRITE);

import $.^.scheduler.utils;
utils.runOrPublishByName('Produce_Weekly_Metrics', 'RUN');
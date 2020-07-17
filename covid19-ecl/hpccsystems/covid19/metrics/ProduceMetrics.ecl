#WORKUNIT('name', 'Produce_Weekly_Metrics');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types2 AS Types;
IMPORT $.CalcMetrics2 AS CalcMetrics;
IMPORT $ AS COVID19;

statsRec := Types.statsRec;
metricsRec := Types.metricsRec;


L1MinSpreadingInfections := 2000;
L2MinSpreadingInfections := 500;
L3MinSpreadingInfections := 100;

// Read Stats and produce Metrics
L0Stats := DATASET('~hpccsystems::covid19::file::public::stats::Level0.flat', statsRec, THOR);
L1Stats := DATASET('~hpccsystems::covid19::file::public::stats::Level1.flat', statsRec, THOR);
L2Stats := DATASET('~hpccsystems::covid19::file::public::stats::Level2.flat', statsRec, THOR);
L3Stats := DATASET('~hpccsystems::covid19::file::public::stats::Level3.flat', statsRec, THOR);

L0Metrics := CalcMetrics.WeeklyMetrics(L0Stats, L1MinSpreadingInfections);
worldCFR := L0Metrics(period=1)[1].cfr;
L1Metrics := CalcMetrics.WeeklyMetrics(L1Stats, L1MinSpreadingInfections, worldCFR);
L2Metrics := CalcMetrics.WeeklyMetrics(L2Stats, L2MinSpreadingInfections, worldCFR);
L3Metrics := CalcMetrics.WeeklyMetrics(L3Stats, L3MinSpreadingInfections, worldCFR);

OUTPUT(L0Metrics, , '~hpccsystems::covid19::file::public::metrics::Level0.flat', Thor, OVERWRITE);
OUTPUT(L1Metrics, , '~hpccsystems::covid19::file::public::metrics::Level1.flat', Thor, OVERWRITE);
OUTPUT(L2Metrics, , '~hpccsystems::covid19::file::public::metrics::Level2.flat', Thor, OVERWRITE);
OUTPUT(L3Metrics, , '~hpccsystems::covid19::file::public::metrics::Level3.flat', Thor, OVERWRITE);

#WORKUNIT('name', 'Produce_Metrics_Evolution');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types2 AS Types;
IMPORT $.CalcMetrics2 AS CalcMetrics;
IMPORT $ AS COVID19;
IMPORT COVID19.Paths;

statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
metricsEvolRec := Types.metricsEvolRec;

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

allDates0 := DEDUP(SORT(L0Stats, -date), date);
allDates := TABLE(allDates0, {UNSIGNED date := date});
OUTPUT(allDates0, NAMED('AllDates'));
tempRec := {UNSIGNED asOfDate, DATASET(metricsRec) metricsL0, DATASET(metricsRec) metricsL1, DATASET(metricsRec) metricsL2, DATASET(metricsRec) metricsL3,};

tempRec getEvol({UNSIGNED date} datRec) := TRANSFORM
  L0metr := CalcMetrics.WeeklyMetrics(L0Stats(date <= datRec.date),  L1MinSpreadingInfections, worldCFR);
  SELF.asOfDate := datRec.date;
  SELF.metricsL0 := L0metr(period = 1);
  L1metr := CalcMetrics.WeeklyMetrics(L1Stats(date <= datRec.date),  L1MinSpreadingInfections, worldCFR);
  SELF.metricsL1 := L1metr(period = 1);
  L2metr := CalcMetrics.WeeklyMetrics(L2Stats(date <= datRec.date),  L2MinSpreadingInfections, worldCFR);
  SELF.metricsL2 := L2metr(period = 1);
  L3metr := CalcMetrics.WeeklyMetrics(L3Stats(date <= datRec.date),  L3MinSpreadingInfections, worldCFR);
  SELF.metricsL3 := L3metr(period = 1);
END;

evol := PROJECT(allDates, getEvol(LEFT));

L0evol0 := NORMALIZE(evol, LEFT.metricsL0, TRANSFORM(metricsEvolRec, SELF.asOfDate := LEFT.asOfDate, SELF := RIGHT));
L0evol := SORT(L0evol0, location, -asOfDate);
L1evol0 := NORMALIZE(evol, LEFT.metricsL1, TRANSFORM(metricsEvolRec, SELF.asOfDate := LEFT.asOfDate, SELF := RIGHT));
L1evol := SORT(L1evol0, location, -asOfDate);
L2evol0 := NORMALIZE(evol, LEFT.metricsL2, TRANSFORM(metricsEvolRec, SELF.asOfDate := LEFT.asOfDate, SELF := RIGHT));
L2evol := SORT(L2evol0, location, -asOfDate);
L3evol0 := NORMALIZE(evol, LEFT.metricsL3, TRANSFORM(metricsEvolRec, SELF.asOfDate := LEFT.asOfDate, SELF := RIGHT));
L3evol := SORT(L3evol0, location, -asOfDate);


OUTPUT(L0evol, , Paths.MetricsEvolLevel0, Thor, OVERWRITE);
OUTPUT(L1evol, , Paths.MetricsEvolLevel1, Thor, OVERWRITE);
OUTPUT(L2evol, , Paths.MetricsEvolLevel2, Thor, OVERWRITE);
OUTPUT(L3evol, , Paths.MetricsEvolLevel3, Thor, OVERWRITE);
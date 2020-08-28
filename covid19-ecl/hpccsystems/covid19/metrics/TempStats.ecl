#WORKUNIT('name', 'Key_Stats');

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

//keyStats0 := TABLE(L2Stats(Level2 = 'RHODE ISLAND' AND Level3 = 'PROVIDENCE' AND date >= 20200701), {Level2, Level3, date, cumCases, cumDeaths, deltaCases := cumCases - prevCases, deltaDeaths := cumDeaths - prevDeaths, filtNewCases := newCases, filtNewDeaths := newDeaths, caseAdjustment, deathsAdjustment, newCases2 := newCases - caseAdjustment, newDeaths2 := newDeaths - deathsAdjustment}, Level3, date);
keyStats0 := TABLE(L2Stats(Country = 'US' AND Level2 = 'ALABAMA' AND Level3 = ''), {Country, Level2, Level3, date, cumCases, cumDeaths, deltaCases := cumCases - prevCases, filtNewCases := newCases, deltaDeaths := cumDeaths - prevDeaths, filtNewDeaths := newDeaths, caseAdjustment, deathsAdjustment, newCases2 := newCases - caseAdjustment, newDeaths2 := newDeaths - deathsAdjustment}, Level3, date);
keyStats := SORT(keyStats0, Level3, date);
OUTPUT(keyStats, ALL, NAMED('keyStats'));

adjSummary := TABLE(keyStats, {totCases := SUM(GROUP, MAX(deltaCases, 0)), totCaseAdj := SUM(GROUP, caseAdjustment), caseAdjPct := SUM(GROUP, caseAdjustment) / SUM(GROUP, MAX(deltaCases, 0)),
                  totDeaths := SUM(GROUP, MAX(deltaDeaths, 0)), totDeathAdj := SUM(GROUP, deathsAdjustment), deathsAdjPct := SUM(GROUP, deathsAdjustment) / SUM(GROUP, MAX(deltaDeaths, 0))},
                  ALL);

OUTPUT(adjSummary, NAMED('AdjustmentSummary'));
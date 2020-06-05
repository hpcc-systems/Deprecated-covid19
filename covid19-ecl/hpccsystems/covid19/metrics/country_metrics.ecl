#WORKUNIT('name', 'metrics_by_country');

IMPORT Std;
IMPORT $.Types;

IMPORT $ AS COVID19;
IMPORT $.Types;

metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

minActive := 200;  // Minimum cases to consider a location active.

rawFilePath := '~hpccsystems::covid19::file::public::johnhopkins::world.flat';

worldMetricsPath := '~hpccsystems::covid19::file::public::metrics::weekly_global.flat';

scRecord := RECORD
  string50 fips;
  string admin2;
  string state;
  string country;
  unsigned4 update_date;
  decimal9_6 geo_lat;
  decimal9_6 geo_long;
  REAL8 confirmed;
  REAL8 deaths;
  REAL8 recovered;
  REAL8 active;
  string combined_key;
 END;

_countryFilter := '':STORED('countryFilter'); 

countryFilter := Std.Str.SplitWords(_countryFilter, ',');

// Filter county info
rawData0 := DATASET(rawFilePath, scRecord, THOR);
rawData1 := SORT(rawData0, country, state, admin2, update_date);
rawData2 := DEDUP(rawData1, country, state, admin2, update_date);

// Filter out bad country info
rawData3 := rawData2(country != '' AND update_date != 0 AND (COUNT(countryFilter) = 0 OR country IN countryFilter));
//OUTPUT(rawData3[..10000], ALL, NAMED('rawData'));
//OUTPUT(rawData3(country = 'CHINA'), ALL, NAMED('ChinaRaw'));
// Make sure there are no missing dates for any of the regions.
//rawData4 := COVID19.FixupMissingDates(rawData3);
rawData4 := rawData3;
//OUTPUT(rawData4[..10000], ALL, NAMED('fixedupData'));
//OUTPUT(rawData4(country = 'CHINA'), ALL, NAMED('ChinaFixed'));
// Roll up the data by country for each date
rollupDat := SORT(TABLE(rawData4, {fips, country, update_date, cConfirmed := SUM(GROUP, confirmed), cDeaths := SUM(GROUP, deaths)}, country, update_date), country, update_date);

OUTPUT(rollupDat, ALL, NAMED('RollupStats'));

statsData := PROJECT(rollupDat, TRANSFORM(statsRec,
																						SELF.fips := LEFT.fips,
                                            SELF.date := LEFT.update_date,
                                            SELF.location := LEFT.country,
                                            SELF.cumCases := LEFT.cConfirmed,
                                            SELF.cumDeaths := LEFT.cDeaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

OUTPUT(statsData, ALL, NAMED('InputStats'));

popData := DATASET([], populationRec);

OUTPUT(popData, NAMED('PopulationData'));

worldMetrics := DATASET(worldMetricsPath, metricsRec, THOR);
worldCFR := worldMetrics(period=1)[1].iMort;
OUTPUT(worldCFR, NAMED('WorldCFR'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
OUTPUT(statsE, ,'~hpccsystems::covid19::file::public::metrics::daily_by_country.flat', Thor, OVERWRITE);

metrics0 := CalcMetrics.WeeklyMetrics(statsData, popData, minActive, worldCFR);

// Filter out some bad country names that only had data for one period
metrics1 := metrics0(period != 1 OR endDate > 20200401);
metrics := metrics1;

OUTPUT(metrics, ALL, NAMED('MetricsByWeek'));
OUTPUT(metrics, ,'~hpccsystems::covid19::file::public::metrics::weekly_by_country.flat', Thor, OVERWRITE);
sortedByCR := SORT(metrics, period, -cR, location);
OUTPUT(sortedByCR, ALL, NAMED('metricsByCR'));
sortedByMR := SORT(metrics, period, -mR, location);
OUTPUT(sortedByMR, ALL, NAMED('metricsByMR'));
sortedByCMRatio := SORT(metrics, period, -cmRatio, location);
OUTPUT(sortedByCMRatio, ALL, NAMED('metricsByCMRatio'));

sortedByPerCapita := SORT(metrics, period, -cases_per_capita, location);
OUTPUT(sortedByPerCapita, ALL, NAMED('metricsByPerCapitaCases'));

sortedByDCR := SORT(metrics, period, dcR, location);
OUTPUT(sortedByDCR, ALL, NAMED('metricsByDCR'));

sortedByDMR := SORT(metrics, period, dmR, location);
OUTPUT(sortedByDMR, ALL, NAMED('metricsByDMR'));

sortedByMedInd := SORT(metrics(medIndicator != 0), period, medIndicator, location);
OUTPUT(sortedByMedInd, ALL, NAMED('metricsByMedicalIndicator'));

sortedBySdInd := SORT(metrics(sdIndicator != 0), period, sdIndicator, location);
OUTPUT(sortedBySdInd, ALL, NAMED('metricsBySocialDistanceIndicator'));

sortedByWeeksToPeak := SORT(metrics(period = 1 AND weeksToPeak > 0 AND weeksToPeak < 999), weeksToPeak, location);
OUTPUT(sortedByWeeksToPeak, NAMED('metricsByWeeksToPeak'));

withSeverity := JOIN(metrics(period = 1), COVID19.iStateSeverity, LEFT.iState = RIGHT.stateName, TRANSFORM({metricsRec, UNSIGNED severity},
                          SELF.severity := RIGHT.severity, SELF := LEFT), LOOKUP);
sortedBySeverity := SORT(withSeverity, -severity, location);
OUTPUT(sortedBySeverity, ALL, NAMED('ByInfectionState'));

sortedByHeatIndx := COVID19.HotSpotsRpt(metrics);
OUTPUT(sortedByHeatIndx, ALL, NAMED('HotSpots'));

commentary := SORT(metrics(period = 1), location);
OUTPUT(commentary, {location, commentary}, ALL, NAMED('Commentary'));
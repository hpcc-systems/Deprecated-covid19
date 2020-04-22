#WORKUNIT('name', 'metrics_by_country');

IMPORT Std;
IMPORT $.Types;
IMPORT $ AS COVID19;


metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

rawFilePath := '~hpccsystems::covid19::file::public::johnhopkins::world.flat';

scRecord := RECORD
  string50 fips;
  string admin2;
  string state;
  string country;
  unsigned4 update_date;
  decimal9_6 geo_lat;
  decimal9_6 geo_long;
  unsigned4 confirmed;
  unsigned4 deaths;
  unsigned4 recovered;
  unsigned4 active;
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
rawData4 := COVID19.FixupMissingDates(rawData3);
//OUTPUT(rawData4[..10000], ALL, NAMED('fixedupData'));
//OUTPUT(rawData4(country = 'CHINA'), ALL, NAMED('ChinaFixed'));
// Roll up the data by country for each date
rollupDat := SORT(TABLE(rawData4, {country, update_date, cConfirmed := SUM(GROUP, confirmed), cDeaths := SUM(GROUP, deaths)}, country, update_date), country, update_date);
// Temp for China fixup
chinaDat := rollupDat(country = 'CHINA');
//OUTPUT(chinaDat, ALL,  NAMED('ChinaDataFixed'));

statsData := PROJECT(rollupDat, TRANSFORM(statsRec,
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

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
OUTPUT(statsE, ,'~research::covid19::out::daily_metrics_by_country.flat', Thor, OVERWRITE);

metrics := CalcMetrics.WeeklyMetrics(statsData, popData);



OUTPUT(metrics, ALL, NAMED('MetricsByWeek'));
OUTPUT(metrics, ,'~research::covid19::out::weekly_metrics_by_country.flat', Thor, OVERWRITE);
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

worldTotals0 := TABLE(metrics, {INTEGER weekEnding := endDate, totCases := SUM(GROUP, cases), totDeaths := SUM(GROUP, deaths), totActive := SUM(GROUP, active), totRecovered := SUM(GROUP, recovered), metric_t Avg_cR := AVE(GROUP, cR, cR > 0), metric_t Avg_mR := AVE(GROUP, mR, mR > 0), metric_t avg_iMort := AVE(GROUP, iMort, iMort > 0)}, endDate);
worldTotals := SORT(worldTotals0, -weekEnding);
OUTPUT(worldTotals, NAMED('WorldTotals'));
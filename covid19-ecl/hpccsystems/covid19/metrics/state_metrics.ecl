#WORKUNIT('name', 'metrics_by_us_states');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types;
IMPORT $ AS COVID19;

statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

minSpreadingInfections := 500;

rawFilePath := '~hpccsystems::covid19::file::public::johnhopkins::us.flat';

parentMetricsPath := '~hpccsystems::covid19::file::public::metrics::weekly_by_country.flat';

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

// Filter county info
rawDatIn0 := SORT(DATASET(rawFilePath, scRecord, THOR), state);
OUTPUT(rawDatIn0[..10000], ALL, NAMED('Raw'));
//OUTPUT(rawDatIn0(update_date = 0), ALL, NAMED('RawBadDate'));

// Roll up the data by state
rawDatIn1 := TABLE(rawDatIn0, {fips, state, update_date, stConfirmed := SUM(GROUP, confirmed), stDeaths := SUM(GROUP, deaths)}, state, update_date);


_statesFilter := '':STORED('statesFilter');

statesFilter := Std.Str.SplitWords(_statesFilter, ',');

// Filter out bad state info
rawDatIn := SORT(rawDatIn1(state != '' AND update_date > 0 AND (COUNT(statesFilter) = 0 OR state IN statesFilter)), state, update_date);

statsData := PROJECT(rawDatIn, TRANSFORM(statsRec,
                                            SELF.fips := LEFT.fips,
                                            SELF.location := LEFT.state,
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.stConfirmed,
                                            SELF.cumDeaths := LEFT.stDeaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

OUTPUT(statsData[ .. 10000], ALL, NAMED('InputStats'));
popDatIn := pop.clean;
popData := PROJECT(popDatIn, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state,
                                    SELF.population := LEFT.pop_2018));

OUTPUT(popData, NAMED('PopulationData'));

parentMetrics := DATASET(parentMetricsPath, metricsRec, THOR);
parentCFR := parentMetrics(location = 'US' AND period=1)[1].cfr;
OUTPUT(parentCFR, NAMED('US_CFR'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
OUTPUT(statsE, ,'~hpccsystems::covid19::file::public::metrics::daily_by_state.flat', Thor, OVERWRITE);

metrics := COVID19.CalcMetrics.WeeklyMetrics(statsData, popData, minSpreadingInfections, parentCFR);

OUTPUT(metrics, ALL, NAMED('MetricsByWeek'));
OUTPUT(metrics, ,'~hpccsystems::covid19::file::public::metrics::weekly_by_state.flat', Thor, OVERWRITE);
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

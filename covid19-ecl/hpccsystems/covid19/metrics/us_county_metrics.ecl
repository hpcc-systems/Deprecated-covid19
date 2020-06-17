#WORKUNIT('name', 'metrics_by_us_county');

IMPORT Std;
IMPORT $.Types;
IMPORT $ AS COVID19;

statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

minSpreadingInfections := 100;

countyFilePath := '~hpccsystems::covid19::file::public::johnhopkins::us.flat';

populationPath := '~hpccsystems::covid19::file::public::uscountypopulation::population.flat';

_stateFilter := '':STORED('stateCountyFilter'); 

stateFilter := Std.Str.SplitWords(_stateFilter, ',');

testLocations := ['NEW YORK,NEW YORK CITY', 'COLORADO,LARIMER','CALIFORNIA,SAN MATEO', 'NEW HAMPSHIRE,STRAFFORD', 'MASSACHUSETTS,SUFFOLK'];

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
 
 rawPopRecord := RECORD
  string fips;
  string state;
  string county;
  string stname;
  string ctyname;
  string census2010pop;
  string popestimate2010;
  string popestimate2011;
  string popestimate2012;
  string popestimate2013;
  string popestimate2014;
  string popestimate2015;
  string popestimate2016;
  string popestimate2017;
  string popestimate2018;
  string popestimate2019;
 END;
 
// Filter county info
countyDatIn0 := DATASET(countyFilePath, scRecord, THOR);
// Recompute the combined key to put state first
countyDatIn1 := PROJECT(countyDatIn0, TRANSFORM(RECORDOF(LEFT),
                                        SELF.combined_key := Std.Str.CleanSpaces(LEFT.state) + ',' + Std.Str.CleanSpaces(LEFT.admin2),
                                        SELF := LEFT));
countyDatIn2 := SORT(countyDatIn1, combined_key, update_date);
countyDatIn := countyDatIn2(update_date != 0 AND admin2 != '' AND admin2 != 'UNASSIGNED' AND (COUNT(stateFilter) = 0 OR state IN stateFilter));

OUTPUT(countyDatIn[.. 10000], ALL, NAMED('Raw'));

statsData := PROJECT(countyDatIn, TRANSFORM(statsRec,
                                            SELF.fips := LEFT.fips,
                                            SELF.location := LEFT.combined_key,
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.confirmed,
                                            SELF.cumDeaths := LEFT.deaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

OUTPUT(statsData[.. 10000], ALL, NAMED('InputStats'));
popData0 := DATASET(populationPath, rawPopRecord, THOR);
popData := JOIN(popData0, DEDUP(statsData, fips), LEFT.fips = RIGHT.fips, TRANSFORM(populationRec,
																																SELF.location := RIGHT.location,
																																SELF.population := IF((UNSIGNED)LEFT.popestimate2019 > 0, (UNSIGNED)LEFT.popestimate2019, 1)),
																																				LEFT OUTER);

OUTPUT(popData, ALL, NAMED('PopulationData'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
OUTPUT(statsE, ,'~hpccsystems::covid19::file::public::metrics::daily_by_us_county.flat', Thor, OVERWRITE);

metrics := COVID19.CalcMetrics.WeeklyMetrics(statsData, popData, minSpreadingInfections);


OUTPUT(metrics, ,'~hpccsystems::covid19::file::public::metrics::weekly_by_us_county.flat', Thor, OVERWRITE);

metricsRed := metrics[ .. 20000 ]; // Reduced set for wu output
OUTPUT(metricsRed(location in testLocations), ALL, NAMED('MetricsByWeek'));

sortedByCases := SORT(metricsRed, period, -cases);
//OUTPUT(sortedByCases, ALL, NAMED('metricsByCases'));
sortedByCR := SORT(metricsRed, period, -cR, location);
//OUTPUT(sortedByCR, ALL, NAMED('metricsByCR'));
sortedByMR := SORT(metricsRed, period, -mR, location);
//OUTPUT(sortedByMR, ALL, NAMED('metricsByMR'));
sortedByCMRatio := SORT(metricsRed, period, -cmRatio, location);
//OUTPUT(sortedByCMRatio, ALL, NAMED('metricsByCMRatio'));

sortedByPerCapita := SORT(metricsRed, period, -cases_per_capita, location);
//OUTPUT(sortedByPerCapita, ALL, NAMED('metricsByPerCapitaCases'));

sortedByDCR := SORT(metricsRed, period, dcR, location);
//OUTPUT(sortedByDCR, ALL, NAMED('metricsByDCR'));

sortedByDMR := SORT(metricsRed, period, dmR, location);
//OUTPUT(sortedByDMR, ALL, NAMED('metricsByDMR'));

sortedByMedInd := SORT(metrics(medIndicator != 0), period, medIndicator, location);
//OUTPUT(sortedByMedInd, ALL, NAMED('metricsByMedicalIndicator'));

sortedBySdInd := SORT(metrics(sdIndicator != 0), period, sdIndicator, location);
//OUTPUT(sortedBySdInd, ALL, NAMED('metricsBySocialDistanceIndicator'));

withSeverity := JOIN(metrics(period = 1 AND iState != 'Initial'), COVID19.iStateSeverity, LEFT.iState = RIGHT.stateName, TRANSFORM({metricsRec, UNSIGNED severity},
                          SELF.severity := RIGHT.severity, SELF := LEFT), LOOKUP);
sortedBySeverity := SORT(withSeverity, -severity, location);
//OUTPUT(sortedBySeverity, ALL, NAMED('ByInfectionState'));

sortedByHeatIndx := COVID19.HotSpotsRpt(metrics);
//OUTPUT(sortedByHeatIndx, ALL, NAMED('HotSpots'));

commentary := SORT(metrics(period = 1), location);
//OUTPUT(commentary, {location, commentary}, ALL, NAMED('Commentary'));
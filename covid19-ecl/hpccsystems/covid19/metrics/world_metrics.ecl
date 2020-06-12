#WORKUNIT('name', 'global_metrics');

IMPORT Std;
IMPORT $.Types;

IMPORT $ AS COVID19;
IMPORT $.Types;

metric_t := Types.metric_t;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;

minSpreadingInfections := 1000;


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

// Filter county info
rawData0 := DATASET(rawFilePath, scRecord, THOR);
rawData1 := SORT(rawData0, country, state, admin2, update_date);
rawData2 := DEDUP(rawData1, country, state, admin2, update_date);

// Filter out bad country info
rawData3 := rawData2(country != '' AND update_date != 0);
// Make sure there are no missing dates for any of the regions.
rawData4 := rawData3;
// Roll up the data for each date
rollupDat := SORT(TABLE(rawData4, {update_date, cConfirmed := SUM(GROUP, confirmed), cDeaths := SUM(GROUP, deaths)}, update_date), update_date);

statsData := PROJECT(rollupDat, TRANSFORM(statsRec,
                                            SELF.date := LEFT.update_date,
                                            SELF.location := 'The World',
                                            SELF.cumCases := LEFT.cConfirmed,
                                            SELF.cumDeaths := LEFT.cDeaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

OUTPUT(statsData, ALL, NAMED('InputStats'));

popData := DATASET([{'The World', 7783766000}], populationRec);

OUTPUT(popData, NAMED('PopulationData'));

// Extended Statistics
statsE := CalcMetrics.DailyStats(statsData);
OUTPUT(statsE, ,'~hpccsystems::covid19::file::public::metrics::daily_global.flat', Thor, OVERWRITE);

metrics := CalcMetrics.WeeklyMetrics(statsData, popData, minSpreadingInfections);

OUTPUT(metrics, ALL, NAMED('MetricsByWeek'));
OUTPUT(metrics, ,'~hpccsystems::covid19::file::public::metrics::weekly_global.flat', Thor, OVERWRITE);

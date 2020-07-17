#WORKUNIT('name', 'Produce_Daily_Stats');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.Types2 AS Types;
IMPORT $ AS COVID19;

inputRec := Types.inputRec;
statsRec := Types.statsRec;
metricsRec := Types.metricsRec;
populationRec := Types.populationRec;
CalcMetrics := COVID19.CalcMetrics;
CalcStats := COVID19.CalcStats;

minSpreadingInfections := 500;


// For US County and State level
USFilePath := '~hpccsystems::covid19::file::public::johnhopkins::us.flat';
countyPopulationPath := '~hpccsystems::covid19::file::public::uscountypopulation::population.flat';
countryMetricsPath := '~hpccsystems::covid19::file::public::metrics::weekly_by_country.flat';

// For country level
countryFilePath := '~hpccsystems::covid19::file::public::johnhopkins::world.flat';
worldMetricsPath := '~hpccsystems::covid19::file::public::metrics::weekly_global.flat';

countryPopulationPath := '~hpccsystems::covid19::file::public::worldpopulation::population_gender.flat';

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

countyPopRecord := RECORD
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

countryPopRecord := RECORD
	string locid;
	string location;
	unsigned4 time;
	string agegrp;
	unsigned8 popmale;
	unsigned8 popfemale;
	unsigned8 poptotal;
END;

// Country Data contains some L2 and L3 data as well for certain countries.  Combine that with
// US County and State data to produce L2 and L3 inputs.
countryData0 := SORT(DATASET(countryFilePath, scRecord, THOR), country, state, admin2, update_date);
OUTPUT(countryData0[.. 10000], ALL, NAMED('RawCountryData'));

// Prepare L3 level input

USDatIn0 := DATASET(USFilePath, scRecord, THOR);
USDatIn := USDatIn0(state != '' AND admin2 != '' AND update_date != 0);
OUTPUT(USDatIn[..10000], ALL, NAMED('RawUSData'));
L3WorldDatIn := countryData0(country != '' AND country != 'US' AND state != '' AND admin2 != '' AND update_date != 0);
L3DatIn := SORT(USDatIn + L3WorldDatIn, state, admin2, update_date);
//OUTPUT(rawDatIn0(update_date = 0), ALL, NAMED('RawBadDate'));
L3InputDat0 := PROJECT(L3DatIn, TRANSFORM(inputRec,
                                            SELF.fips := LEFT.fips,
                                            SELF.country := Std.Str.CleanSpaces(LEFT.country),
                                            SELF.Level2 := Std.Str.CleanSpaces(LEFT.state),
                                            SELF.Level3 := Std.Str.CleanSpaces(LEFT.admin2),
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.Confirmed,
                                            SELF.cumDeaths := LEFT.Deaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));

L3PopData := DATASET(countyPopulationPath, countyPopRecord, THOR);
L3InputDat1 := JOIN(L3InputDat0, L3PopData, LEFT.fips = RIGHT.fips, TRANSFORM(RECORDOF(LEFT),
																																SELF.population := IF((UNSIGNED)RIGHT.popestimate2019 > 0, (UNSIGNED)RIGHT.popestimate2019, 1),
                                                                SELF := LEFT),
																																				LEFT OUTER, LOOKUP);
L3InputDat := SORT(L3InputDat1, Country, Level2, Level3, -date);
OUTPUT(L3InputDat[..10000], ALL, NAMED('L3InputData'));

// Prepare L2 level input
L2WorldDatIn := countryData0(country != '' AND state != '' AND admin2 = '' AND update_date != 0);
USStateDatIn := USDatIn0(state != '' AND admin2 = '' AND update_date != 0);
L2DatIn := SORT(L2WorldDatIn + USStateDatIn, country, state, update_date);

L2InputDat0 := PROJECT(L2DatIn, TRANSFORM(inputRec,
                                            SELF.fips := LEFT.fips,
                                            SELF.country := Std.Str.CleanSpaces(LEFT.country),
                                            SELF.Level2 := Std.Str.CleanSpaces(LEFT.state),
                                            SELF.Level3 := '',
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.confirmed,
                                            SELF.cumDeaths := LEFT.deaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));


statePopDatIn := pop.clean;
statePopData := PROJECT(statePopDatIn, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state,
                                    SELF.population := LEFT.pop_2018));

OUTPUT(statePopData, NAMED('StatePopulationData'));

L2InputDat1 := JOIN(L2InputDat0, statePopData, LEFT.Country = 'US' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := RIGHT.population,
                                SELF := LEFT), LEFT OUTER);
L2InputDat := SORT(L2InputDat1, Country, Level2, -date);
OUTPUT(L2InputDat[ .. 10000], ALL, NAMED('L2InputData'));

countryMetrics := DATASET(countryMetricsPath, metricsRec, THOR);
countryCFR := countryMetrics(location = 'US' AND period=1)[1].cfr;
OUTPUT(countryCFR, NAMED('US_CFR'));

// Prepare Country Level Input
countryData1 := SORT(countryData0, country, update_date);
countryData2 := DEDUP(countryData1, country, update_date);

// Filter out bad country info
countryData3 := countryData2(country != '' AND state = '' and admin2 = '' AND update_date != 0);
countryPopData0 := DATASET(countryPopulationPath, countryPopRecord, THOR);
countryPopData := DEDUP(SORT(countryPopData0, location, -time), location);
countryInputDat := JOIN(countryData3, countryPopData, LEFT.Country = RIGHT.location, TRANSFORM(inputRec,
                                            SELF.fips := LEFT.fips,
                                            SELF.country := Std.Str.CleanSpaces(LEFT.country),
                                            SELF.Level2 := '',
                                            SELF.Level3 := '',
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.Confirmed,
                                            SELF.cumDeaths := LEFT.Deaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0,
                                            SELF.population := RIGHT.poptotal), LEFT OUTER);
OUTPUT(countryPopData, NAMED('CountryPopulationData'));

worldMetrics := DATASET(worldMetricsPath, metricsRec, THOR);
worldCFR := worldMetrics(period=1)[1].cfr;
OUTPUT(worldCFR, NAMED('WorldCFR'));

// Statistics
L1InputDat := countryInputDat;

L3Stats := CalcStats.DailyStats(L3InputDat, 3);
OUTPUT(L3Stats, ,'~hpccsystems::covid19::file::public::stats::Level3.flat', Thor, OVERWRITE);
//OUTPUT(L3Stats[..10000], ALL, NAMED('L3Stats'));
L2Stats := CalcStats.DailyStats(L2InputDat, 2);
OUTPUT(L2Stats, ALL, NAMED('L2Stats'));
L1Stats := CalcStats.DailyStats(L1InputDat, 1);

L2Rollup := CalcStats.RollupStats(L3Stats, 2);
OUTPUT(L2Rollup, ALL, NAMED('L2Rollup'));

L2Merged := CalcStats.MergeStats(L2Rollup, L2Stats, 2);  // Merge at Level 2
OUTPUT(L2Merged, ,'~hpccsystems::covid19::file::public::stats::Level2.flat', Thor, OVERWRITE);
//OUTPUT(L2Merged(date > 20200531), ALL, NAMED('L2Merged'));

L1Rollup := CalcStats.RollupStats(L2Merged, 1);
OUTPUT(L1Rollup, ALL, NAMED('L1Rollup'));
L1Merged := CalcStats.MergeStats(L1Rollup, L1Stats, 1);
OUTPUT(L1Merged, ,'~hpccsystems::covid19::file::public::stats::Level1.flat', Thor, OVERWRITE);

L0Stats := CalcStats.RollupStats(L1Merged, 0);
OUTPUT(L0Stats, ,'~hpccsystems::covid19::file::public::stats::Level0.flat', Thor, OVERWRITE);
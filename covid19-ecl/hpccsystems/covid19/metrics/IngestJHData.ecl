#WORKUNIT('name', 'Ingest_JH_data');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.^.file.public as file;
IMPORT $.Types2 AS Types;
IMPORT $ AS COVID19;
IMPORT COVID19.Paths;

inputRec := Types.inputRec;
populationRec := Types.populationRec;

// For L1 level
countryFilePath := '~hpccsystems::covid19::file::public::johnhopkins::world.flat';
worldMetricsPath := '~hpccsystems::covid19::file::public::metrics::weekly_global.flat';

countryPopulationPath := '~hpccsystems::covid19::file::public::worldpopulation::population_gender.flat';

// For L2 level
indiaStatePopPath := '~hpccsystems::covid19::file::public::indiapopulation::v1::population.flat';
australiaStatePopPath := '~hpccsystems::covid19::file::public::australiapopulation::v1::population.flat';
ukStatePopPath := '~hpccsystems::covid19::file::public::ukpopulation::v1::population.flat';
canadaStatePopPath := '~hpccsystems::covid19::file::public::canadapopulation::v1::population.flat';
mexicoStatePopPath := '~hpccsystems::covid19::file::public::mexicopopulation::v1::population.flat';
brazilStatePopPath := '~hpccsystems::covid19::file::public::brazilpopulation::v1::population.flat';

// For L3 level
USFilePath := '~hpccsystems::covid19::file::public::johnhopkins::us.flat';
countyPopulationPath := '~hpccsystems::covid19::file::public::uscountypopulation::population.flat';
countryMetricsPath := '~hpccsystems::covid19::file::public::metrics::weekly_by_country.flat';

// Various input record formats
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

indiaStatePopRec := RECORD
  string4 state;
  string area_name;
  unsigned8 total_persons;
  unsigned8 total_males;
  unsigned8 total_females;
  unsigned8 rural_persons;
  unsigned8 rural_males;
  unsigned8 rural_females;
  unsigned8 urban_persons;
  unsigned8 urban_males;
  unsigned8 urban_females;
 END;

australiaStatePopRec := RECORD
  string state_and_territory;
  unsigned8 population;
  integer8 change_over_previous_year;
  decimal5_2 change_over_previous_year_percentage;
 END;

ukStatePopRec := RECORD
  string code;
  string name;
  string geography1;
  unsigned8 all_ages;
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
//OUTPUT(countryData0[.. 10000], ALL, NAMED('RawCountryData'));

// Prepare L3 level input

USDatIn0 := DATASET(USFilePath, scRecord, THOR);
USDatIn := USDatIn0(state != '' AND admin2 != '' AND update_date != 0);
//OUTPUT(USDatIn[..10000], ALL, NAMED('RawUSData'));
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
out3 := OUTPUT(L3InputDat, ,Paths.JHLevel3, Thor, OVERWRITE);

//OUTPUT(L3InputDat[..10000], ALL, NAMED('L3InputData'));

// Prepare L2 level input
L2WorldDatIn := countryData0(country != '' AND state != '' AND admin2 = '' AND update_date != 0);
USStateDatIn := USDatIn0(state != '' AND admin2 = '' AND update_date != 0);
L2DatIn := SORT(L2WorldDatIn + USStateDatIn, country, state, update_date);

L2InputDat0 := PROJECT(DEDUP(L2DatIn, country, state, update_date), TRANSFORM(inputRec,
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

usStatePopDatIn := pop.clean;
usstatePopData := PROJECT(usStatePopDatIn, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state,
                                    SELF.population := LEFT.pop_2018));
indiaStatePopData0 := DATASET(indiaStatePopPath, indiaStatePopRec, THOR);
indiaStatePopData := PROJECT(indiaStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := LEFT.area_name,
                                    SELF.population := LEFT.total_persons));
australiaStatePopData0 := DATASET(australiaStatePopPath, australiaStatePopRec, THOR);
australiaStatePopData := PROJECT(australiaStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state_and_territory,
                                    SELF.population := LEFT.population));
ukStatePopData0 := DATASET(ukStatePopPath, ukStatePopRec, THOR);
ukStatePopData := PROJECT(ukStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := LEFT.name,
                                    SELF.population := LEFT.all_ages));
mexicoStatePopData0 := DATASET(mexicoStatePopPath, file.mexicopopulation.layout, THOR);
mexicoStatePopData := PROJECT(mexicoStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state,
                                    SELF.population := LEFT.total));
canadaStatePopData0 := DATASET(canadaStatePopPath, file.canadapopulation.layout, THOR);
canadaStatePopData := PROJECT(canadaStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := LEFT.geography,
                                    SELF.population := LEFT.pop_2019));
brazilStatePopData0 := DATASET(brazilStatePopPath, file.brazilpopulation.layout, THOR);
brazilStatePopData := PROJECT(brazilStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := LEFT.state,
                                    SELF.population := LEFT.population));
//OUTPUT(statePopData, NAMED('StatePopulationData'));

L2InputDat1 := JOIN(L2InputDat0, usStatePopData, LEFT.Country = 'US' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := RIGHT.population,
                                SELF := LEFT), LEFT OUTER);
L2InputDat2 := JOIN(L2InputDat1, indiaStatePopData, LEFT.Country = 'INDIA' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat3 := JOIN(L2InputDat2, australiaStatePopData, LEFT.Country = 'AUSTRALIA' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat4 := JOIN(L2InputDat3, ukStatePopData, LEFT.Country = 'UNITED KINGDOM' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat5 := JOIN(L2InputDat4, mexicoStatePopData, LEFT.Country = 'MEXICO' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat6 := JOIN(L2InputDat5, brazilStatePopData, LEFT.Country = 'BRAZIL' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat7 := JOIN(L2InputDat6, canadaStatePopData, LEFT.Country = 'CANADA' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);

L2InputDat := SORT(L2InputDat7, Country, Level2, -date);



out2 := OUTPUT(L2InputDat, ,Paths.JHLevel2, Thor, OVERWRITE);
//OUTPUT(L2InputDat(date > 20200629), ALL, NAMED('L2InputData'));

// Prepare Country Level Input
countryData1 := SORT(countryData0, country, update_date);
countryData2 := DEDUP(countryData1, country, update_date);

// Filter out bad country info
// Note: We want at least one record per country so we can get population data.
countryData3 := countryData2(country != '' AND update_date != 0);
countryData4 := DEDUP(countryData3, country, update_date);
countryPopData0 := DATASET(countryPopulationPath, countryPopRecord, THOR);
countryPopData := DEDUP(SORT(countryPopData0, location, -time), location);
countryInputDat := JOIN(countryData4, countryPopData, LEFT.Country = RIGHT.location, TRANSFORM(inputRec,
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
//OUTPUT(countryPopData, NAMED('CountryPopulationData'));
out1 := OUTPUT(CountryInputDat, ,Paths.JHLevel1, Thor, OVERWRITE);

SEQUENTIAL(
    Std.File.RemoveSuperFile(Paths.InputLevel1, Paths.JHLevel1),
    Std.File.RemoveSuperFile(Paths.InputLevel2, Paths.JHLevel2),
    Std.File.RemoveSuperFile(Paths.InputLevel3, Paths.JHLevel3),
    out1,
    out2,
    out3,
    Std.File.AddSuperfile(Paths.InputLevel1, Paths.JHLevel1),
    Std.File.AddSuperfile(Paths.InputLevel2, Paths.JHLevel2),
    Std.File.AddSuperfile(Paths.InputLevel3, Paths.JHLevel3),
    );

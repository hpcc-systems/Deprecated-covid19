﻿#WORKUNIT('name', 'Ingest_JH_data');

IMPORT Std;
IMPORT $.USPopulationFiles as pop;
IMPORT $.^.file.public as file;
IMPORT $.Types2 AS Types;
IMPORT $ AS COVID19;
IMPORT COVID19.Paths;

inputRec := Types.inputRec;
populationRec := Types.populationRec;
cleanSpaces := Std.Str.CleanSpaces;

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
spainStatePopPath := '~hpccsystems::covid19::file::public::spainpopulation::v1::population.flat';
italyStatePopPath := '~hpccsystems::covid19::file::public::italypopulation::v1::population.flat';
germanyStatePopPath := '~hpccsystems::covid19::file::public::germanypopulation::v1::population.flat';

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

spainStatePopRec := RECORD
  string location;
  unsigned8 total;
  unsigned8 males;
  unsigned8 females;
 END;

italyStatePopRec := RECORD
  string territory;
  unsigned8 value;
END;

germanyStatePopRec := RECORD
  string location;
  string code;
  string name;
  unsigned8 total;
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

STRING cleanupLocation(STRING location) := Std.Str.CleanSpaces(Std.Str.FindReplace(location, '-', ' '));
STRING cleanupFIPS(STRING fips) := FUNCTION
  fips2 := (STRING)(INTEGER)fips;
  fipsLen := LENGTH(fips2);
  final := MAP(fipsLen = 5 => fips2,
              fipsLen = 4 => '0' + fips2,
              fipsLen = 3 => '00' + fips2,
              fipsLen = 2 => '000' + fips2,
              fipsLen = 1 => '0000' + fips2,
              fips2);
  return final;
END;

// Vaccine Data Formats
L1VaccineRec := RECORD
  string location;
  string iso_code;
  unsigned4 date;
  unsigned8 total_vaccinations;
  unsigned8 people_vaccinated;
  unsigned8 people_fully_vaccinated;
  unsigned8 daily_vaccinations_raw;
  unsigned8 daily_vaccinations;
  decimal12_2 total_vaccinations_per_hundred;
  decimal12_2 people_vaccinated_per_hundred;
  decimal12_2 people_fully_vaccinated_per_hundred;
  decimal12_2 daily_vaccinations_per_million;
 END;

 L2VaccineRec := RECORD
  unsigned4 date;
  string location;
  unsigned8 total_distributed;
  unsigned8 total_vaccinations;
  decimal12_2 distributed_per_hundred;
  decimal12_2 total_vaccinations_per_hundred;
  unsigned8 people_vaccinated;
  decimal12_2 people_vaccinated_per_hundred;
  unsigned8 people_fully_vaccinated;
  decimal12_2 people_fully_vaccinated_per_hundred;
  unsigned8 daily_vaccinations_raw;
  unsigned8 daily_vaccinations;
  decimal12_2 daily_vaccinations_per_million;
  decimal12_2 share_dose_used;
 END;

// Country Data contains some L2 and L3 data as well for certain countries.  Combine that with
// US County and State data to produce L2 and L3 inputs.
countryData0 := SORT(DATASET(countryFilePath, scRecord, THOR)(update_date >= 20200322), country, state, admin2, update_date);  // New format starts a 20200322
// France reports data for its territories, but not its mainland at level 2.  Assign a level 2 name "CONTINENTAL" to
// the mainland data so that rollups work properly.
// Until 6/11/20, UK reports data at L1 and after that date, moves all of that data to L2 = 'UNKNOWN'.  Fix by assigning L1 data to UNKNOWN.
countryData1 := PROJECT(countryData0, TRANSFORM(RECORDOF(LEFT),
                                              SELF.Country := Std.Str.CleanSpaces(LEFT.Country),
                                              SELF.State := MAP(SELF.Country = 'FRANCE' AND CleanSpaces(LEFT.State) = '' => 'CONTINENTAL',
                                                                SELF.Country = 'UNITED KINGDOM' AND CleanSpaces(LEFT.state) = '' => 'UNKNOWN',
                                                                CleanSpaces(LEFT.state)),
                                              SELF := LEFT));
//OUTPUT(countryData1(update_date > 20201220 AND Country = 'UNITED KINGDOM'), ALL, NAMED('CountryData1'));
// Prepare L3 level input

USDatIn0 := DATASET(USFilePath, scRecord, THOR);
USDatIn := USDatIn0(state != '' AND admin2 != '' AND update_date >= 20200322);  // New format starts a 20200322
//OUTPUT(USDatIn[..10000], ALL, NAMED('RawUSData'));
L3WorldDatIn := countryData0(country != '' AND country != 'US' AND state != '' AND admin2 != '' AND update_date != 0);
L3DatIn := DEDUP(SORT(USDatIn + L3WorldDatIn, country, state, admin2, update_date));
//OUTPUT(rawDatIn0(update_date = 0), ALL, NAMED('RawBadDate'));
L3InputDat0 := PROJECT(L3DatIn, TRANSFORM(inputRec,
                                            SELF.fips := cleanupFIPS(LEFT.fips),
                                            SELF.country := CleanSpaces(LEFT.country),
                                            SELF.Level2 := CleanSpaces(LEFT.state),
                                            SELF.Level3 := CleanSpaces(LEFT.admin2),
                                            SELF.date := LEFT.update_date,
                                            SELF.cumCases := LEFT.Confirmed,
                                            SELF.cumDeaths := LEFT.Deaths,
                                            SELF.cumHosp := 0,
                                            SELF.tested := 0,
                                            SELF.positive := 0,
                                            SELF.negative := 0));
// Fixup some bad FIPS mappings in the input data
inputRec fixupBadLocations(inputRec rec) := TRANSFORM
  SELF.fips := MAP(rec.Country = 'US' AND rec.Level2 = 'MASSACHUSETTS' AND rec.Level3 = 'DUKES AND NANTUCKET' => '25007',
                    rec.Country = 'US' AND rec.Level2 = 'NEW YORK' AND rec.Level3 IN ['NEW YORK', 'QUEENS', 'BRONX', 'BROOKLYN', 'STATTEN ISLAND', 'KINGS', 'RICHMOND'] => '36061',
                    rec.fips);
  SELF.Level3 := MAP(SELF.fips = '36061' => 'NEW YORK CITY',
                        rec.Level3);
  SELF := rec;
END;
L3InputDat1 := PROJECT(L3InputDat0, fixupBadLocations(LEFT), LOCAL);
// Roll up the corrections to sum up stats for reassigned locations
L3InputDat1G := GROUP(SORT(L3InputDat1, Country, Level2, Level3, date), Country, Level2, Level3, date);
inputRec doRollup(inputRec rec, DATASET(inputRec) recs) := TRANSFORM
                          SELF.cumCases := SUM(recs, cumCases);
                          SELF.cumDeaths := SUM(recs, cumDeaths);
                          SELF.cumHosp := SUM(recs, cumHosp);
                          SELF.tested := SUM(recs, tested);
                          SELF.positive := SUM(recs, positive);
                          SELF.negative := SUM(recs, negative);
                          SELF := rec;
END;
L3InputDat1R := ROLLUP(L3InputDat1G, GROUP, doRollup(LEFT, ROWS(LEFT)));

L3PopData0 := DATASET(countyPopulationPath, countyPopRecord, THOR);
// Normalize FIPS codes to integer representation to get rid of leading zeros and spurious '.0'
L3PopData := PROJECT(L3PopData0, TRANSFORM(RECORDOF(LEFT), SELF.FIPS := cleanupFIPS(LEFT.fips), SELF := LEFT));
L3InputDat2 := JOIN(L3InputDat1R, L3PopData, LEFT.fips = RIGHT.fips, TRANSFORM(RECORDOF(LEFT),
																																SELF.population := IF((UNSIGNED)RIGHT.popestimate2019 > 0, (UNSIGNED)RIGHT.popestimate2019, 1),
                                                                SELF := LEFT),
																																LEFT OUTER, LOOKUP);
L3InputDat := SORT(L3InputDat2, Country, Level2, Level3, -date);

out3 := OUTPUT(L3InputDat, ,Paths.JHLevel3, Thor, OVERWRITE);

//OUTPUT(L3InputDat[..10000], ALL, NAMED('L3InputData'));

// Prepare L2 level input
L2WorldDatIn := countryData1(country != '' AND state != '' AND admin2 = '' AND update_date != 0);
USStateDatIn := USDatIn0(state != '' AND admin2 = '' AND update_date != 0);
L2DatIn := SORT(L2WorldDatIn + USStateDatIn, country, state, update_date);

L2InputDat0 := PROJECT(DEDUP(L2DatIn, country, state, update_date), TRANSFORM(inputRec,
                                            SELF.fips := cleanupFIPS(LEFT.fips),
                                            SELF.country := cleanupLocation(LEFT.country),
                                            SELF.Level2 := cleanupLocation(LEFT.state),
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
spainStatePopData0 := DATASET(spainStatePopPath, spainStatePopRec, THOR);
spainStatePopData := PROJECT(spainStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := cleanupLocation(LEFT.location),
                                    SELF.population := LEFT.total));
italyStatePopData0 := DATASET(italyStatePopPath, italyStatePopRec, THOR);
italyStatePopData := PROJECT(italyStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := cleanupLocation(LEFT.territory),
                                    SELF.population := LEFT.value));
germanyStatePopData0 := DATASET(germanyStatePopPath, germanyStatePopRec, THOR);
germanyStatePopData := PROJECT(germanyStatePopData0, TRANSFORM(populationRec,
                                    SELF.location := cleanupLocation(LEFT.name),
                                    SELF.population := LEFT.total));
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
L2InputDat8 := JOIN(L2InputDat7, spainStatePopData, LEFT.Country = 'SPAIN' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat9 := JOIN(L2InputDat8, italyStatePopData, LEFT.Country = 'ITALY' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2InputDat10 := JOIN(L2InputDat9, germanyStatePopData, LEFT.Country = 'GERMANY' AND LEFT.Level2 = RIGHT.location,
                                TRANSFORM(RECORDOF(LEFT),
                                SELF.population := IF(LEFT.population = 0, RIGHT.population, LEFT.population),
                                SELF := LEFT), LEFT OUTER);
L2VaccData0 := DATASET(Paths.VaccLevel2, L2VaccineRec ,THOR);
L2VaccData1 := SORT(L2VaccData0, location, date);
// Fixup vaccine data for proper cumulation.  Currently, days with no vaccines show 0 as the total, rather than the previous total
L2VaccineRec cumulateVaccL2(L2VaccineRec l, L2VaccineRec r) := TRANSFORM
  SELF.total_vaccinations := IF(l.location = r.location, MAX(r.total_vaccinations, l.total_vaccinations), r.total_vaccinations);
  SELF.people_vaccinated := IF(l.location = r.location, MAX(r.people_vaccinated, l.people_vaccinated), r.people_vaccinated);
  SELF.people_fully_vaccinated := IF(l.location = r.location, MAX(r.people_fully_vaccinated, l.people_fully_vaccinated), r.people_fully_vaccinated);
  SELF.total_distributed := IF(l.location = r.location, MAX(r.total_distributed, l.total_distributed), r.total_distributed);
  SELF := r;
END;
L2VaccData := ITERATE(L2VaccData1, cumulateVaccL2(LEFT, RIGHT), LOCAL);
//OUTPUT(L2VaccData, ALL, NAMED('L2Vacc'));
L2LatestDate := MAX(L2InputDat10, date);
L2InputDat11 := JOIN(L2InputDat10, L2VaccData(date <= L2LatestDate), LEFT.Country = 'US' AND LEFT.Level2 = RIGHT.location AND LEFT.date = RIGHT.date, TRANSFORM(RECORDOF(LEFT),
                              SELF.vacc_total_dist := RIGHT.total_distributed,
                              SELF.vacc_total_admin := RIGHT.total_vaccinations,
                              SELF.vacc_total_people := RIGHT.people_vaccinated,
                              SELF.vacc_people_complete := RIGHT.people_fully_vaccinated,
                              SELF.Country := IF(LENGTH(LEFT.Country) = 0, 'US', LEFT.Country),
                              SELF.date := IF(LEFT.date = 0, RIGHT.date, LEFT.date),
                              SELF.level2 := IF(LENGTH(LEFT.level2) = 0, RIGHT.location, LEFT.level2),
                              SELF := LEFT), FULL OUTER);

L2InputDat := SORT(L2InputDat11, Country, Level2, -date);


out2 := OUTPUT(L2InputDat, ,Paths.JHLevel2, Thor, OVERWRITE);
//OUTPUT(L2InputDat(date > 20200629), ALL, NAMED('L2InputData'));

// Prepare Country Level Input
countryData2 := SORT(countryData1, country, update_date);
countryData3 := DEDUP(countryData2, country, update_date);

// Filter out bad country info
// Note: We want at least one record per country so we can get population data.
countryData4 := countryData3(country != '' AND update_date != 0);
countryData5 := DEDUP(countryData4, country, update_date);
countryPopData0 := DATASET(countryPopulationPath, countryPopRecord, THOR);
countryPopData := DEDUP(SORT(countryPopData0, location, -time), location);
countryInputDat0 := JOIN(countryData5, countryPopData, LEFT.Country = RIGHT.location, TRANSFORM(inputRec,
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
vaccFilteredLocationsL1 := ['ENGLAND', 'NORTHERN IRELAND', 'SCOTLAND', 'WALES', 'WORLD'];
L1VaccData0 := DATASET(Paths.VaccLevel1, L1VaccineRec ,THOR)(location NOT IN vaccFilteredLocationsL1);
L1VaccData1 := SORT(L1VaccData0, location, date);
// Fixup vaccine data for proper cumulation.  Currently, days with no vaccines show 0 as the total, rather than the previous total
L1VaccineRec cumulateVacc(L1VaccineRec l, L1VaccineRec r) := TRANSFORM
  SELF.total_vaccinations := IF(l.location = r.location, MAX(r.total_vaccinations, l.total_vaccinations), r.total_vaccinations);
  SELF.people_vaccinated := IF(l.location = r.location, MAX(r.people_vaccinated, l.people_vaccinated), r.people_vaccinated);
  SELF.people_fully_vaccinated := IF(l.location = r.location, MAX(r.people_fully_vaccinated, l.people_fully_vaccinated), r.people_fully_vaccinated);
  SELF := r;
END;
L1VaccData := ITERATE(L1VaccData1, cumulateVacc(LEFT, RIGHT), LOCAL);
//OUTPUT(L1VaccData, ALL, NAMED('L1Vacc'));
//OUTPUT(countryInputDat0(date >= 20210101), ALL, NAMED('CountryData'));
L1LatestDate := MAX(countryInputDat0, date);
countryInputDat := JOIN(countryInputDat0, L1VaccData(date <= L1LatestDate), LEFT.Country = RIGHT.location AND LEFT.date = RIGHT.date, TRANSFORM(RECORDOF(LEFT),
                              SELF.vacc_total_dist := 0,
                              SELF.vacc_total_admin := RIGHT.total_vaccinations,
                              SELF.vacc_total_people := RIGHT.people_vaccinated,
                              SELF.vacc_people_complete := RIGHT.people_fully_vaccinated,
                              SELF.Country := IF(LENGTH(LEFT.Country) = 0, RIGHT.location, LEFT.Country),
                              SELF.date := IF(LEFT.date = 0, RIGHT.date, LEFT.date),
                              SELF := LEFT), FULL OUTER);
out1 := OUTPUT(countryInputDat, ,Paths.JHLevel1, Thor, OVERWRITE);

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


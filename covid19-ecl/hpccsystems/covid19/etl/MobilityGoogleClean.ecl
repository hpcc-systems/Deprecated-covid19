IMPORT hpccsystems.covid19.file.raw.MobilityGoogle as mobilityRaw;
IMPORT hpccsystems.covid19.file.public.MobilityGoogle as mobilityClean;
IMPORT Std;


cleands := PROJECT(mobilityraw.ds,
                       TRANSFORM(mobilityClean.layout,

                                  SELF.country_region_code := STD.STR.TOUPPERCASE(LEFT.country_region_code),
                                  SELF.country_region := STD.STR.TOUPPERCASE(LEFT.country_region),
                                  SELF.sub_region_1 := STD.STR.TOUPPERCASE(LEFT.sub_region_1),
                                  SELF.sub_region_2 := STD.STR.TOUPPERCASE(LEFT.sub_region_2),
                                  SELF.metro_area := STD.STR.TOUPPERCASE(LEFT.metro_area),
                                  SELF.iso_3166_2_code := STD.STR.TOUPPERCASE(LEFT.iso_3166_2_code),
                                  SELF.census_fips_code := STD.STR.TOUPPERCASE(LEFT.census_fips_code),
                                  SELF.date :=   (UNSIGNED) STD.Str.FindReplace(LEFT.date, '-', ''),
                                  SELF.retail_and_recreation_percent_change_from_baseline :=    LEFT.retail_and_recreation_percent_change_from_baseline / 100,
                                  SELF.grocery_and_pharmacy_percent_change_from_baseline :=    LEFT.grocery_and_pharmacy_percent_change_from_baseline / 100,
                                  SELF.parks_percent_change_from_baseline :=    LEFT.parks_percent_change_from_baseline / 100,
                                  SELF.transit_stations_percent_change_from_baseline :=     LEFT.transit_stations_percent_change_from_baseline / 100,
                                  SELF.workplaces_percent_change_from_baseline :=    LEFT.workplaces_percent_change_from_baseline / 100,
                                  SELF.residential_percent_change_from_baseline :=    LEFT.residential_percent_change_from_baseline / 100
                       ));
  
OUTPUT(cleands, , mobilityClean.filepath, OVERWRITE, COMPRESSED);

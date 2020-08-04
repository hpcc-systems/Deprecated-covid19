
EXPORT mobilityGoogle := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::raw::mobility::Google::global_mobility_report.csv';
EXPORT layout := RECORD
    STRING country_region_code;
    STRING country_region;
    STRING sub_region_1;
    STRING sub_region_2;
    STRING metro_area;
    STRING iso_3166_2_code;
    STRING census_fips_code;
    STRING date;
    INTEGER retail_and_recreation_percent_change_from_baseline;
    INTEGER grocery_and_pharmacy_percent_change_from_baseline;
    INTEGER parks_percent_change_from_baseline;
    INTEGER transit_stations_percent_change_from_baseline;
    INTEGER workplaces_percent_change_from_baseline;
    INTEGER residential_percent_change_from_baseline;
END;

EXPORT ds := DATASET(filepath, Layout, CSV(HEADING(1)));

END;
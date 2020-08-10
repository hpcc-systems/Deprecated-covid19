EXPORT MobilityGoogle := MODULE

EXPORT filepath := '~hpccsystems::covid19::file::public::mobility::Google::daily.flat';
EXPORT layout := RECORD
    STRING country_region_code;
    STRING country_region;
    STRING sub_region_1;
    STRING sub_region_2;
    STRING metro_area;
    STRING iso_3166_2_code;
    STRING census_fips_code;
    UNSIGNED4 date;
    DECIMAL5_3 retail_and_recreation_percent_change_from_baseline;
    DECIMAL5_3 grocery_and_pharmacy_percent_change_from_baseline;
    DECIMAL5_3 parks_percent_change_from_baseline;
    DECIMAL5_3 transit_stations_percent_change_from_baseline;
    DECIMAL5_3 workplaces_percent_change_from_baseline;
    DECIMAL5_3 residential_percent_change_from_baseline;
END;

EXPORT ds := DATASET(filepath, layout, Flat);

END;
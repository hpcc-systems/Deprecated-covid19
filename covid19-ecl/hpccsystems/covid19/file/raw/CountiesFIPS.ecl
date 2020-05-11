EXPORT CountiesFIPS := MODULE
    
    EXPORT path := '~hpccsystems::covid19::file::raw::misc::countyfips::v1::county_fips_master.csv';
    
    EXPORT layout := RECORD
        STRING fips;
        STRING county_name;
        STRING state_abbr;
        STRING state_name;
        STRING long_name;
        STRING sumlev;
        STRING region;
        STRING division;
        STRING state;
        STRING county;
        STRING crosswalk;
        STRING region_name;
        STRING division_name;
    END;

   EXPORT ds := DATASET(path, layout, CSV(HEADING(1)));  

END;
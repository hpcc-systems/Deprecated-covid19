EXPORT CountiesFIPS := MODULE
    
    EXPORT path := '~hpccsystems::covid19::file::public::misc::countyfips::v1::county_fips_master.flat';
    
    EXPORT layout := RECORD
        STRING fips;
        STRING county_name;
        STRING state_abbr;
        STRING state_name;
        STRING long_name;
    END;

   EXPORT ds := DATASET(path, layout, THOR);  

END;
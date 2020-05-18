IMPORT Std;

EXPORT JohnHopkins := MODULE 
    
    EXPORT worldFilePath := '~hpccsystems::covid19::file::public::johnhopkins::world.flat';  
    EXPORT usFilePath := '~hpccsystems::covid19::file::public::johnhopkins::US.flat';

    EXPORT layout := RECORD
        STRING50 fips;
        STRING50 admin2;
        STRING50 state;
        STRING50 country;
        Std.Date.Date_t update_date;
        DECIMAL9_6 geo_lat;
        DECIMAL9_6 geo_long;
        REAL8 confirmed;
        REAL8 deaths;
        REAL8 recovered;
        REAL8 active;
        STRING50 combined_key;
    END;

	EXPORT worldDs := DATASET(worldFilePath, layout, THOR);//ds will always be the default
    EXPORT usDs := DATASET(usFilePath, layout, THOR);
END;
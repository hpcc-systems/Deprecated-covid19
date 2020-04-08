EXPORT JohnHopkinsV2 := MODULE 
    EXPORT filePath := '~{hpccsystems::covid19::file::raw::03-22-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-23-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-24-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-25-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-26-2020.csv,'+ 
                        'hpccsystems::covid19::file::raw::03-27-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-28-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-29-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-30-2020.csv,'+
                        'hpccsystems::covid19::file::raw::03-31-2020.csv,'+
                        'hpccsystems::covid19::file::raw::04-01-2020.csv,'+
                        'hpccsystems::covid19::file::raw::04-02-2020.csv,'+
                        'hpccsystems::covid19::file::raw::04-03-2020.csv,'+
                        'hpccsystems::covid19::file::raw::04-04-2020.csv,'+
                        'hpccsystems::covid19::file::raw::04-05-2020.csv,'+ 
                        'hpccsystems::covid19::file::raw::04-06-2020.csv,'+
                        'hpccsystems::covid19::file::raw::04-07-2020.csv' + '}'; 

    EXPORT layout := RECORD
        STRING fips;
        STRING admin2; 
        STRING state;
        STRING country;
        STRING last_update;
        STRING geo_lat;
        STRING geo_long;
        STRING confirmed;
        STRING deaths;
        STRING recovered;
        STRING active;
        STRING combined_key;
    END;

    EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  
END;
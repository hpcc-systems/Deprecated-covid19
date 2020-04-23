EXPORT DailyMetrics := MODULE
  
    EXPORT statesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_state.flat';
    EXPORT countriesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_country.flat';
    EXPORT countiesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_us_county.flat';  


    EXPORT statsrec := RECORD
        string location;
        unsigned4 date;
        DECIMAL8_2 cumcases;
        DECIMAL8_2 cumdeaths;
        DECIMAL8_2 cumhosp;
        DECIMAL8_2 tested;
        DECIMAL8_2 positive;
        DECIMAL8_2 negative;
    END;

    EXPORT Layout := RECORD (statsrec)
        unsigned8 id;
        integer8 period;
        DECIMAL8_2 prevcases;
        DECIMAL8_2 newcases;
        DECIMAL8_2 prevdeaths;
        DECIMAL8_2 newdeaths;
        real8 periodcgrowth;
        real8 periodmgrowth;
        DECIMAL8_2 active;
        DECIMAL8_2 prevactive;
        DECIMAL8_2 recovered;
        real8 imort;
    END;


    EXPORT states := DATASET(statesPath, layout, THOR);
    EXPORT counties := DATASET(countiesPath, layout, THOR);
    EXPORT countries := DATASET(countriesPath, layout, THOR);


END;
EXPORT DailyMetrics := MODULE
  
    EXPORT statesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_state.flat';
    EXPORT countriesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_country.flat';
    EXPORT countiesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_us_county.flat';  


    EXPORT statsrec := RECORD
        string location;
        unsigned4 date;
        REAL8 cumcases;
        REAL8 cumdeaths;
        REAL8 cumhosp;
        REAL8 tested;
        REAL8 positive;
        REAL8 negative;
    END;

    EXPORT Layout := RECORD (statsrec)
        unsigned8 id;
        integer8 period;
        REAL8 prevcases;
        REAL8 newcases;
        REAL8 prevdeaths;
        REAL8 newdeaths;
        real8 periodcgrowth;
        real8 periodmgrowth;
        REAL8 active;
        REAL8 prevactive;
        REAL8 recovered;
        real8 imort;
    END;


    EXPORT states := DATASET(statesPath, layout, THOR);
    EXPORT counties := DATASET(countiesPath, layout, THOR);
    EXPORT countries := DATASET(countriesPath, layout, THOR);


END;
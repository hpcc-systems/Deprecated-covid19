EXPORT DailyMetrics := MODULE
  
    EXPORT statesPath := '~research::covid19::out::daily_metrics_by_state.flat';
    EXPORT countriesPath := '~research::covid19::out::daily_metrics_by_country.flat';
    EXPORT countiesPath := '~research::covid19::out::daily_metrics_by_us_county.flat';  


    EXPORT statsrec := RECORD
        string location;
        unsigned4 date;
        unsigned8 cumcases;
        unsigned8 cumdeaths;
        unsigned8 cumhosp;
        unsigned8 tested;
        unsigned8 positive;
        unsigned8 negative;
    END;

    EXPORT Layout := RECORD (statsrec)
        unsigned8 id;
        integer8 period;
        unsigned8 prevcases;
        unsigned8 newcases;
        unsigned8 prevdeaths;
        unsigned8 newdeaths;
        real8 periodcgrowth;
        real8 periodmgrowth;
        unsigned8 active;
        unsigned8 prevactive;
        unsigned8 recovered;
        real8 imort;
    END;


    EXPORT states := DATASET(statesPath, layout, THOR);
    EXPORT counties := DATASET(countiesPath, layout, THOR);
    EXPORT countries := DATASET(countriesPath, layout, THOR);


END;
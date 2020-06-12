
IMPORT STD;


EXPORT Files := MODULE
    EXPORT l_worldpopgender := RECORD
        STRING LocID;
        STRING Location;
        STRING VarID;
        STRING Variant;
        STRING Time;
        STRING MidPeriod;
        STRING PopMale;
        STRING PopFemale;
        STRING PopTotal;
        STRING PopDensity;
    END;

    EXPORT l_worldpopgender_clean := RECORD
        STRING LocID;
        STRING Location;
        UNSIGNED4 Time;
        UNSIGNED PopMale;
        UNSIGNED PopFemale;
        UNSIGNED PopTotal;
        DECIMAL10_2 PopDensity;
    END;

    EXPORT worldpopgender_raw := DATASET('~hpccsystems::covid19::file::public::worldpopulation::population_gender.flat', L_worldpopgender, CSV(HEADING(1)));

    // Fileter time = 2019
    EXPORT worldpopgender_2019 := worldpopgender_raw(time = '2019');

    EXPORT worldpopgender := DATASET('~hpccsystems::covid19::file::public::worldpopulation::population_gender.flat', l_worldpopgender_clean, THOR);

    EXPORT l_worldpopage := RECORD
        STRING LocID;
        STRING Location;
        STRING VarID;
        STRING Variant;
        STRING Time;
        STRING MidPeriod;
        STRING AgeGrp;
        STRING AgeGrpStart;
        STRING AgeGrpSpan;
        STRING PopMale;
        STRING PopFemale;
        STRING PopTotal;
    END;

    EXPORT l_worldpopage_clean := RECORD
        STRING LocID;
        STRING Location;
        UNSIGNED4 Time;
        STRING AgeGrp;
        UNSIGNED PopMale;
        UNSIGNED PopFemale;
        UNSIGNED PopTotal;
    END;

    EXPORT worldpopage_raw := DATASET('~hpccsystems::covid19::file::raw::worldpopulation::wpp2019_populationbyagesex_medium.csv', l_worldpopage, CSV(HEADING(1)));

    EXPORT worldpopage_2019 := worldpopage_raw( time = '2019'); 

    EXPORT worldpopage := DATASET('~hpccsystems::covid19::file::public::worldpopulation::population_age.flat', l_worldpopage_clean, FLAT );

END;




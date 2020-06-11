
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

EXPORT worldpopgender_raw := DATASET('~hpccsystems::covid19::file::raw::worldpopulation::wpp2019_totalpopulationbysex.csv', L_worldpopgender, CSV(HEADING(1)));

// Fileter time = 2019
EXPORT worldpopgender_2019 := worldpopgender_raw(time = '2019');

EXPORT worldpop := DATASET('~hpccsystems::covid19::file::public::worldpopulation::population.flat', l_worldpopgender_clean, THOR);






END;




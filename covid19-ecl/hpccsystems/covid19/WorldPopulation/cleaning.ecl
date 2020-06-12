
IMPORT STD;

l_worldpopgender := RECORD
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

l_worldpopgender_clean := RECORD
    STRING LocID;
    STRING Location;
    UNSIGNED4 Time;
    UNSIGNED PopMale;
    UNSIGNED PopFemale;
    UNSIGNED PopTotal;
    DECIMAL10_2 PopDensity;
END;

worldpopgender_raw := DATASET('~hpccsystems::covid19::file::raw::worldpopulation::wpp2019_totalpopulationbysex.csv', L_worldpopgender, CSV(HEADING(1)));
// output(worldpopgender_raw);

worldpopgender_2019 := worldpopgender_raw(time = '2019');

worldpopgender_clean := PROJECT(worldpopgender_2019,
                   TRANSFORM(l_worldpopgender_clean,
                   SELF.Location   := TRIM(STD.Str.ToUpperCase(LEFT.Location), LEFT, RIGHT),
                   SELF.time       := (INTEGER) LEFT.time,
                   SELF.popMale    := (INTEGER) (LEFT.PopMale  )  * 1000,
                   SELF.popFemale  := (INTEGER) (LEFT.PopFemale)  * 1000,
                   SELF.PopTotal   := (INTEGER) (LEFT.PopTotal )  * 1000,
                   SELF.popDensity := (REAL)LEFT.PopDensity * 1000,
                   SELF := LEFT
                   ));
OUTPUT(worldpopgender_clean,, '~hpccsystems::covid19::file::public::worldpopulation::population_gender.flat', OVERWRITE );


l_worldpopage := RECORD
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

l_worldpopage_clean := RECORD
    STRING LocID;
    STRING Location;
    UNSIGNED4 Time;
    STRING AgeGrp;
    UNSIGNED PopMale;
    UNSIGNED PopFemale;
    UNSIGNED PopTotal;
END;

worldpopage_raw := DATASET('~hpccsystems::covid19::file::raw::worldpopulation::wpp2019_populationbyagesex_medium.csv', l_worldpopage, CSV(HEADING(1)));
// OUTPUT(worldpopage_raw);

worldpopage_2019 := worldpopage_raw( time = '2019'); 



worldpopage_clean := PROJECT(worldpopage_2019,
                   TRANSFORM(l_worldpopage_clean,
                   SELF.Location   := TRIM(STD.Str.ToUpperCase(LEFT.Location), LEFT, RIGHT),
                   SELF.time       := (INTEGER) LEFT.time,
                   SELF.popMale    := (INTEGER) (LEFT.PopMale  )  * 1000,
                   SELF.popFemale  := (INTEGER) (LEFT.PopFemale)  * 1000,
                   SELF.PopTotal   := (INTEGER) (LEFT.PopTotal )  * 1000,
                   SELF := LEFT
                   ));
OUTPUT(worldpopage_clean,, '~hpccsystems::covid19::file::public::worldpopulation::population_age.flat' , OVERWRITE);


// OUTPUT(worldpopage_clean );



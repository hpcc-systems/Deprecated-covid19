

EXPORT WorldPopulation := MODULE

    EXPORT filepath_popgender := '~hpccsystems::covid19::file::public::worldpopulation::population_gender.flat';
    EXPORT layout_popgender := RECORD
        STRING LocID;
        STRING Location;
        UNSIGNED4 Time;
        UNSIGNED PopMale;
        UNSIGNED PopFemale;
        UNSIGNED PopTotal;
        DECIMAL10_2 PopDensity;
    END;

    EXPORT ds_popgender := DATASET(filepath_popgender, layout_popgender, THOR);

    EXPORT filepath_popage := '~hpccsystems::covid19::file::public::worldpopulation::population_age.flat';

   EXPORT layout_popage := RECORD
        STRING LocID;
        STRING Location;
        UNSIGNED4 Time;
        STRING AgeGrp;
        UNSIGNED PopMale;
        UNSIGNED PopFemale;
        UNSIGNED PopTotal;
    END;


    EXPORT ds_popage := DATASET(filepath_popage, layout_popage, FLAT );
END;
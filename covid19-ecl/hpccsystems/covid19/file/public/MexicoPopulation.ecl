EXPORT MexicoPopulation := MODULE 
EXPORT filepath := '~hpccsystems::covid19::file::public::mexicopopulation::v1::population.flat';

EXPORT layout := RECORD
    STRING state;
    UNSIGNED Total;
END;

EXPORT ds := DATASET(filepath, layout, FLAT);
END;
EXPORT MexicoPopulation := MODULE 
EXPORT filepath := '~hpccsystems::covid19::file::raw::mexicopopulation::v1::mexicostatepopulation2010.csv';

EXPORT layout := RECORD
    STRING state;
    STRING Total;
END;

EXPORT ds := DATASET(filepath, layout, CSV(HEADING(1)));

END;
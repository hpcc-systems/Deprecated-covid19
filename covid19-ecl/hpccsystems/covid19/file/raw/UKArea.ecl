EXPORT UKArea := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::raw::uk::areadata.csv';

EXPORT layout := RECORD
    STRING filters;
    STRING date;
    STRING name;
    STRING code;
    UNSIGNED daily;
    UNSIGNED deaths;
    UNSIGNED cumulative;
END;

EXPORT ds := DATASET(filepath, layout, CSV(HEADING(1)));

END;
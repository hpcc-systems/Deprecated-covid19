
IMPORT hpccsystems.covid19.file.raw.UKArea as Raw;

EXPORT UKArea := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::public::uk::areadata.flat';

EXPORT layout := RECORD
    STRING filters;
    UNSIGNED4 date;
    STRING name;
    STRING code;
    UNSIGNED daily;
    UNSIGNED deaths;
    UNSIGNED cumulative;
END;


EXPORT ds := DATASET(filepath, layout,FLAT);

END;
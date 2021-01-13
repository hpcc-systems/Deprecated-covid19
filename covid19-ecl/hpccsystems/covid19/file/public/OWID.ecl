import STD;

EXPORT OWID := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::raw::owid::v1::vaccinations.flat';
EXPORT layout := RECORD
    STRING location;
    STRING iso_code;
    STD.Date.Date_t date;
    UNSIGNED total_vaccinations;
    UNSIGNED daily_vaccinations;
    DECIMAL12_2 total_vaccinations_per_hundred;
    DECIMAL12_2 daily_vaccinations_per_million;
END;


EXPORT ds := DATASET(filepath, Layout, flat);

END;
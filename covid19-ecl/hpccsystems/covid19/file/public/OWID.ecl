import STD;

EXPORT OWID := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::public::owid::v2::vaccinations.flat';
EXPORT layout := RECORD
    STRING location;
    STRING iso_code;
    STD.Date.Date_t date;
    UNSIGNED total_vaccinations;
    UNSIGNED people_vaccinated;
    UNSIGNED people_fully_vaccinated;
    UNSIGNED daily_vaccinations_raw;
    UNSIGNED daily_vaccinations;
    DECIMAL12_2 total_vaccinations_per_hundred;
    DECIMAL12_2 people_vaccinated_per_hundred;
    DECIMAL12_2 people_fully_vaccinated_per_hundred;
    DECIMAL12_2 daily_vaccinations_per_million;
END;


EXPORT ds := DATASET(filepath, Layout, flat);

END;
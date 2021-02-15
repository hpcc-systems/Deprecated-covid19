import STD;

EXPORT OWID := MODULE 

EXPORT worldFilePath := '~hpccsystems::covid19::file::public::owid::v2::vaccinations.flat';
EXPORT usFilePath := '~hpccsystems::covid19::file::public::owid::v2::us_states_vaccinations.flat';

EXPORT worldLayout := RECORD
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

EXPORT usLayout := RECORD
    STD.Date.Date_t date;
    STRING location;
    UNSIGNED4 total_vaccinations;
    UNSIGNED4 total_distributed;
    UNSIGNED4 people_vaccinated;
    DECIMAL people_fully_vaccinated_per_hundred;
    DECIMAL total_vaccinations_per_hundred;
    UNSIGNED4 people_fully_vaccinated;
    DECIMAL people_vaccinated_per_hundred;
    DECIMAL distributed_per_hundred;
    UNSIGNED4 daily_vaccinations_raw;
    UNSIGNED4 daily_vaccinations;
    DECIMAL daily_vaccinations_per_million;
    DECIMAL share_doses_used;
END;


EXPORT worldDs := DATASET(worldFilePath, worldLayout, flat);
EXPORT usDs := DATASET(usFilePath, usLayout, flat);

END;
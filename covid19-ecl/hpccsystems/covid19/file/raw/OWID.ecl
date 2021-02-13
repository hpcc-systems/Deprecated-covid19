EXPORT OWID := MODULE 

//Please refer to the following doc for definitions:
//https://ourworldindata.org/covid-vaccinations

EXPORT worldFilePath := '~hpccsystems::covid19::file::raw::owid::v2::vaccinations.csv';
EXPORT usFilePath := '~hpccsystems::covid19::file::raw::owid::v2::us_state_vaccinations.csv';

EXPORT worldLayout := RECORD
    STRING location;
    STRING iso_code;
    STRING date;
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
    STRING date;
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

EXPORT worldDs := DATASET(worldFilePath, worldLayout, CSV(HEADING(1)));
EXPORT usDs := DATASET(usFilePath, usLayout, CSV(HEADING(1)));

END;


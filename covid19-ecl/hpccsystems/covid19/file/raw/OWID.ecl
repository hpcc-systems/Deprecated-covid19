EXPORT OWID := MODULE 

//Please refer to the following doc for definitions:
//https://ourworldindata.org/covid-vaccinations

EXPORT filepath := '~hpccsystems::covid19::file::raw::owid::v2::vaccinations.csv';
EXPORT layout := RECORD
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

EXPORT ds := DATASET(filepath, Layout, CSV(HEADING(1)));

END;


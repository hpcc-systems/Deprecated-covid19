EXPORT OWID := MODULE 

//Please refer to the following doc for definitions:
//https://ourworldindata.org/covid-vaccinations

EXPORT filepath := '~hpccsystems::covid19::file::raw::owid::v1::vaccinations.csv';
EXPORT layout := RECORD
    STRING location;
    STRING iso_code;
    STRING date;
    UNSIGNED total_vaccinations;
    UNSIGNED daily_vaccinations;
    DECIMAL12_2 total_vaccinations_per_hundred;
    DECIMAL12_2 daily_vaccinations_per_million;
END;

EXPORT ds := DATASET(filepath, Layout, CSV(HEADING(1)));

END;


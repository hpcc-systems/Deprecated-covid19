EXPORT USCountyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::uscountypopulation::population.flat';  

 
  EXPORT layout := RECORD
    STRING FIPS;
    STRING STATE;
    STRING COUNTY;
    STRING STNAME;
    STRING CTYNAME;
    DECIMAL14_2 CENSUS2010POP := 0;
    DECIMAL14_2 POPESTIMATE2010 := 0;
    DECIMAL14_2 POPESTIMATE2011 := 0;
    DECIMAL14_2 POPESTIMATE2012 := 0;
    DECIMAL14_2 POPESTIMATE2013 := 0;
    DECIMAL14_2 POPESTIMATE2014 := 0;
    DECIMAL14_2 POPESTIMATE2015 := 0;
    DECIMAL14_2 POPESTIMATE2016 := 0;
    DECIMAL14_2 POPESTIMATE2017 := 0;
    DECIMAL14_2 POPESTIMATE2018 := 0;
    DECIMAL14_2 POPESTIMATE2019 := 0;
  END;

  EXPORT ds := DATASET(filePath, layout, THOR);

  EXPORT filePath_agegender := '~hpccsystems::covid19::file::public::uscountypopulation::population_genderage.flat';  

 
  EXPORT layout_agegender := RECORD
    STRING FIPS;
    STRING STATE;
    STRING COUNTY;
    STRING STNAME;
    STRING CTYNAME;
    STRING YEAR;
    STRING AGEGRP;
    STRING TOT_POP;
    STRING TOT_MALE;
    STRING TOT_FEMALE;
  END;

  EXPORT ds_agegender := DATASET(filePath_agegender, layout_agegender, THOR);

END;
EXPORT USCountyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::uscountypopulation::population.flat';  

 
  EXPORT layout := RECORD
    STRING FIPS;
    STRING STATE;
    STRING COUNTY;
    STRING STNAME;
    STRING CTYNAME;
    DECIMAL14_2 CENSUS2010POP;
    DECIMAL14_2 POPESTIMATE2010;
    DECIMAL14_2 POPESTIMATE2011;
    DECIMAL14_2 POPESTIMATE2012;
    DECIMAL14_2 POPESTIMATE2013;
    DECIMAL14_2 POPESTIMATE2014;
    DECIMAL14_2 POPESTIMATE2015;
    DECIMAL14_2 POPESTIMATE2016;
    DECIMAL14_2 POPESTIMATE2017;
    DECIMAL14_2 POPESTIMATE2018;
    DECIMAL14_2 POPESTIMATE2019;
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
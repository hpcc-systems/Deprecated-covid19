EXPORT USCountyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::uscountypopulation::population.flat';  

 
  EXPORT layout := RECORD
    STRING FIPS;
    STRING STATE;
    STRING COUNTY;
    STRING STNAME;
    STRING CTYNAME;
    STRING CENSUS2010POP;
    STRING POPESTIMATE2010;
    STRING POPESTIMATE2011;
    STRING POPESTIMATE2012;
    STRING POPESTIMATE2013;
    STRING POPESTIMATE2014;
    STRING POPESTIMATE2015;
    STRING POPESTIMATE2016;
    STRING POPESTIMATE2017;
    STRING POPESTIMATE2018;
    STRING POPESTIMATE2019;
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
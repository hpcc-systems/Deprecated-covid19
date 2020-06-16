EXPORT USStatePopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::usstatepopulation::population_agegender.flat';  
                       

  EXPORT layout := RECORD
    STRING STATE;
    STRING NAME;
    STRING SEX;
    STRING AGE;
    STRING YEAR;
    STRING POPEST;
  END;


  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  


END;
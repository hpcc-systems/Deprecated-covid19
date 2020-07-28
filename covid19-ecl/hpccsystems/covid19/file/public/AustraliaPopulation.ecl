EXPORT AustraliaPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::australiapopulation::v1::population.flat';  
                       

  EXPORT layout := RECORD
    STRING State_and_territory;
    UNSIGNED   Population;
    INTEGER   Change_over_previous_year;
    DECIMAL5_2 Change_over_previous_year_percentage;
  END;

  EXPORT ds := DATASET(filePath, layout, FLAT);  

END;
EXPORT GermanyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::Germanypopulation::v1::population.flat';  
                       

  EXPORT layout := RECORD
    STRING location;
    STRING code;
    STRING name;
    UNSIGNED Total;
  END;


  EXPORT ds := DATASET(filePath, layout, FLAT);  

END;
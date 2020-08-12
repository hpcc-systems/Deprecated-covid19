EXPORT SpainPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::Spainpopulation::v1::population.flat';  
                       

  EXPORT layout := RECORD
    STRING location;
    UNSIGNED total;
    UNSIGNED Males;
    UNSIGNED Females;
  END;

  EXPORT ds := DATASET(filePath, layout, FLAT);  

END;
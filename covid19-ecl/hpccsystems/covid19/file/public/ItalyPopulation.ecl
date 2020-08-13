EXPORT ItalyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::Italypopulation::v1::population.flat';  
                       

  EXPORT layout := RECORD
    STRING Territory;
    UNSIGNED Value;

  END;;

  EXPORT ds := DATASET(filePath, layout, FLAT);  

END;
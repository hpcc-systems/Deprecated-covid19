EXPORT SpainPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::Spainpopulation::v1::Spainstatepopulation2020.csv';  
                       

  EXPORT layout := RECORD
    STRING location;
    UNSIGNED total;
    UNSIGNED Males;
    UNSIGNED Females;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
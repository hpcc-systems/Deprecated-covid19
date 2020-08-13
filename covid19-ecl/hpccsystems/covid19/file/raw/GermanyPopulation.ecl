EXPORT GermanyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::Germanypopulation::v1::germanystatepopulation2011.csv';  
                       

  EXPORT layout := RECORD
    STRING location;
    STRING code;
    STRING name;
    UNSIGNED Total;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
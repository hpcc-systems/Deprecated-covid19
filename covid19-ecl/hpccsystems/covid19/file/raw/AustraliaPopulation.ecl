EXPORT AustraliaPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::australiapopulation::v1::australiapopulation2019.csv';  
                       

  EXPORT layout := RECORD
    STRING State_and_territory;
    STRING Population_at_31_Dec_2019;
    STRING Change_over_previous_year__000;
    STRING Change_over_previous_year__;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
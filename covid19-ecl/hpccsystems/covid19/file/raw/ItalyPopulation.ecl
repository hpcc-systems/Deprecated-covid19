EXPORT ItalyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::Italypopulation::v1::italystatepopulation2020.csv';  
                       

  EXPORT layout := RECORD
    STRING ITTER107;
    STRING Territory;
    STRING TIPO_DATO15;
    STRING Demographic_data_type;
    STRING SEXISTAT1;
    STRING Gender;
    STRING ETA1;
    UNSIGNED Age;
    STRING STATCIV2;
    STRING Marital_status;
    STRING TIME;
    STRING Select_time;
    UNSIGNED Value;
    STRING Flag_Codes;
    STRING Flags;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
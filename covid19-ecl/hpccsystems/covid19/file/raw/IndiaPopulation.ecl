EXPORT IndiaPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::indiapopulation::v1::ds-0000-d01-mdds.csv';  
                       

  EXPORT layout := RECORD
    STRING Table_name;
    STRING State;
    STRING District;
    STRING Area_Name;
    STRING Birth_place;
    UNSIGNED Total_Persons;
    UNSIGNED Total_Males;
    UNSIGNED Total_Females;
    UNSIGNED Rural_Persons;
    UNSIGNED Rural_Males;
    UNSIGNED Rural_Females;
    UNSIGNED Urban_Persons;
    UNSIGNED Urban_Males;
    UNSIGNED Urban_Females;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
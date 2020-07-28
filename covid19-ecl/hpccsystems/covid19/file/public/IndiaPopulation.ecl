EXPORT IndiaPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::indiapopulation::population.flat';  

	EXPORT layout := RECORD
    STRING4 State;
    STRING Area_Name;
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

  EXPORT ds := DATASET(filePath, layout, THOR);

END;
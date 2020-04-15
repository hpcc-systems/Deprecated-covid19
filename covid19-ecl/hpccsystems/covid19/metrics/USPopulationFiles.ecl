Import Std;

EXPORT USPopulationFiles := MODULE


  EXPORT rawPath := '~research::covid19::in::us_population.csv';  

  EXPORT rawLayout := RECORD
      STRING state;
      STRING pop_1990;
      STRING pop_2000;
      STRING pop_2010;
      STRING pop_2018;
      STRING change_2010_2018;
  END;

  EXPORT raw := DATASET(rawPath, rawLayout, CSV(HEADING(1)));  

  EXPORT cleanPath := '~research::covid19::out::us_population.flat';  

	EXPORT cleanLayout := RECORD
      STRING state;
      UNSIGNED4 pop_1990;
      UNSIGNED4 pop_2000;
      UNSIGNED4 pop_2010;
      UNSIGNED4 pop_2018;
  END;

	EXPORT clean := DATASET(cleanPath, cleanLayout, THOR);

END;
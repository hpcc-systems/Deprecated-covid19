EXPORT USPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::us_population.csv';  

  EXPORT layout := RECORD
      STRING state;
      STRING pop_1990;
      STRING pop_2000;
      STRING pop_2010;
      STRING pop_2018;
      STRING change_2010_2018;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
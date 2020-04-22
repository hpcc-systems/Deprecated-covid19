EXPORT USPopulation := MODULE

    EXPORT filePath := '~hpccsystems::covid19::file::public::uspopulation::population.flat';  

	EXPORT layout := RECORD
      STRING state;
      UNSIGNED4 pop_1990;
      UNSIGNED4 pop_2000;
      UNSIGNED4 pop_2010;
      UNSIGNED4 pop_2018;
  END;

  EXPORT ds := DATASET(filePath, layout, THOR);

END;
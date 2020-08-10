EXPORT CanadaPopulation := MODULE

    EXPORT filePath := '~hpccsystems::covid19::file::public::Canadapopulation::population.flat';  

	EXPORT layout := RECORD
        STRING Geography;
        UNSIGNED pop_2015;
        UNSIGNED pop_2016;
        UNSIGNED pop_2017;
        UNSIGNED pop_2018;
        UNSIGNED pop_2019;
  END;

  EXPORT ds := DATASET(filePath, layout, THOR);

END;
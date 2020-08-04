EXPORT CanadaPopulation := MODULE

    EXPORT filePath := '~hpccsystems::covid19::file::raw::Canadapopulation::v1::canadastatepopulation.csv';  

	EXPORT layout := RECORD
        STRING Geography;
        UNSIGNED _015;
        UNSIGNED _016;
        UNSIGNED _017;
        UNSIGNED _018;
        UNSIGNED _019;
    END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));

END;
EXPORT WorldPopulation := MODULE

  EXPORT filePath_popgender := '~hpccsystems::covid19::file::raw::worldpopulation::v1::wpp2019_totalpopulationbysex.csv';  
                       

  EXPORT layout_popgender  := RECORD
      STRING LocID;
      STRING Location;
      STRING VarID;
      STRING Variant;
      STRING Time;
      STRING MidPeriod;
      STRING PopMale;
      STRING PopFemale;
      STRING PopTotal;
      STRING PopDensity;
  END;

  EXPORT ds_popgender := DATASET(filePath_popgender, layout_popgender, CSV(HEADING(1)));  

END;
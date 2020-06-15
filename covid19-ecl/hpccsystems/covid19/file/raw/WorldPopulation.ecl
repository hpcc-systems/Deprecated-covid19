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


  EXPORT filePath_popage := '~hpccsystems::covid19::file::raw::worldpopulation::v1::wpp2019_populationbyagesex_medium.csv';  
            

   EXPORT layout_popage := RECORD
        STRING LocID;
        STRING Location;
        STRING VarID;
        STRING Variant;
        STRING Time;
        STRING MidPeriod;
        STRING AgeGrp;
        STRING AgeGrpStart;
        STRING AgeGrpSpan;
        STRING PopMale;
        STRING PopFemale;
        STRING PopTotal;
    END;
    
  EXPORT ds_popage := DATASET(filePath_popage, layout_popage, CSV(HEADING(1)));  

END;
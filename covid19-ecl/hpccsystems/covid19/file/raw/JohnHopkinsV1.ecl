EXPORT JohnHopkinsV1 := MODULE

  EXPORT filePath := '~{hpccsystems::covid19::file::raw::JohnHopkins::V1::03-21-2020.csv,' +
                        'hpccsystems::covid19::file::raw::JohnHopkins::V1::03-20-2020.csv,' +
                        'hpccsystems::covid19::file::raw::JohnHopkins::V1::03-19-2020.csv,' +
                        'hpccsystems::covid19::file::raw::JohnHopkins::V1::03-18-2020.csv,' + 
                        'hpccsystems::covid19::file::raw::JohnHopkins::V1::03-17-2020.csv}';  

  EXPORT layout := RECORD
      STRING state;
      STRING country;
      STRING last_update;
      STRING confirmed;
      STRING deaths;
      STRING recovered;
      STRING geo_lat;
      STRING geo_long;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;

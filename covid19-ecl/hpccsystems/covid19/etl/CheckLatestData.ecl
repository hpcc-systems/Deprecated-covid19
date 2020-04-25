IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV2 as jhv2;

ds := DATASET('~hpccsystems::covid19::file::raw::JohnHopkins::V2::04-23-2020.csv', jhv2.layout, CSV(HEADING(1)));  

OUTPUT(TABLE(ds(country='US'), {last_update, total := SUM(GROUP, (UNSIGNED)confirmed)}, last_update));
IMPORT hpccsystems.covid19.file.raw.tripsByDistance as Raw;
IMPORT hpccsystems.covid19.file.public.tripsByDistance as Clean;

IMPORT Std;



cleaned := PROJECT
    (
       Raw.ds, 
       TRANSFORM
       (Clean.layout,
               SELF.Level := STD.Str.ToUpperCase(TRIM(LEFT.Level, LEFT, RIGHT)),
               SELF.State_Postal_Code := STD.Str.ToUpperCase(TRIM(LEFT.State_Postal_Code, LEFT, RIGHT)),
               SELF.County_Name := STD.Str.ToUpperCase(TRIM(LEFT.County_Name, LEFT, RIGHT)),
               SELF.date := (INTEGER) (LEFT.date[1..4] +  LEFT.date[6..7] +  LEFT.date[9..10]) ,
               SELF := LEFT,

       ) 
    );       


OUTPUT(cleaned, , clean.filePath, THOR, COMPRESSED, OVERWRITE);
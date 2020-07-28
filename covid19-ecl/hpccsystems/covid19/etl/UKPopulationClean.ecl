IMPORT hpccsystems.covid19.file.raw.UKPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.UKPopulation as popClean;

IMPORT Std;


cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (popClean.layout,
            SELF.code := STD.Str.ToUpperCase(TRIM(LEFT.code, LEFT, RIGHT)),
            SELF.name  := STD.Str.ToUpperCase(TRIM(LEFT.name, LEFT, RIGHT)),
            SELF.geography1  := STD.Str.ToUpperCase(TRIM(LEFT.geography1, LEFT, RIGHT)),
            SELF := LEFT
       ) 
    );       



OUTPUT(cleanedPop, , popclean.filePath, THOR, COMPRESSED, OVERWRITE);
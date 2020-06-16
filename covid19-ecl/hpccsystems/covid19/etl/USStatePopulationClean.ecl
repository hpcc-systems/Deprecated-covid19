
IMPORT hpccsystems.covid19.file.raw.USStatePopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.USStatePopulation as popClean;

IMPORT Std;

cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (
         popClean.layout,                     
         SELF.STATE := Std.Str.ToUpperCase(LEFT.STATE),
         SELF.NAME := Std.Str.ToUpperCase(LEFT.NAME),
         SELF.YEAR := '2018',
         SELF.POPEST:= LEFT.POPEST2018_CIV,
         SELF := LEFT
          ) 
    );       

OUTPUT(cleanedPop ,,popclean.filePath, THOR, COMPRESSED, OVERWRITE);

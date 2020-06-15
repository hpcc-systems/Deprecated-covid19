
IMPORT hpccsystems.covid19.file.raw.USCountyPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.USCountyPopulation as popClean;

IMPORT Std;

cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (
         popClean.layout,
         SELF.FIPS := LEFT.STATE + LEFT.COUNTY,                        
         SELF.STATE := Std.Str.ToUpperCase(LEFT.STATE),
         SELF.COUNTY := Std.Str.ToUpperCase(LEFT.COUNTY),
         SELF.STNAME := Std.Str.ToUpperCase(LEFT.STNAME),
         SELF.CTYNAME := Std.Str.ToUpperCase(LEFT.CTYNAME),
         SELF:= LEFT
          ) 
    );       

OUTPUT(cleanedPop ,,popclean.filePath, THOR, COMPRESSED, OVERWRITE);
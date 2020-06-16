
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



cleanedPop_agegender := PROJECT
    (
       popRaw.ds_agegender(year = '11' AND AGEGRP <> '0'), 
       TRANSFORM
       (
         popClean.layout_agegender,
         SELF.YEAR := '2018',
         SELF.FIPS := LEFT.STATE + LEFT.COUNTY,                        
         SELF.STATE := Std.Str.ToUpperCase(LEFT.STATE),
         SELF.COUNTY := Std.Str.ToUpperCase(LEFT.COUNTY),
         SELF.STNAME := Std.Str.ToUpperCase(LEFT.STNAME),
         SELF.CTYNAME := Std.Str.ToUpperCase(LEFT.CTYNAME),
         SELF:= LEFT
          ) 
    );       

OUTPUT(cleanedPop_agegender ,,popclean.filePath_agegender, THOR, COMPRESSED, OVERWRITE);
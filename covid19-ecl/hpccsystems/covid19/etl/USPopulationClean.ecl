IMPORT hpccsystems.covid19.file.raw.USPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.USPopulation as popClean;

IMPORT Std;

cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (
         popClean.layout,                          
         SELF.state := Std.Str.ToUpperCase(LEFT.state),
         SELF.pop_1990 := (UNSIGNED4)STD.Str.FindReplace(LEFT.pop_1990,',',''),
         SELF.pop_2000 := (UNSIGNED4)STD.Str.FindReplace(LEFT.pop_2000,',',''),
         SELF.pop_2010 := (UNSIGNED4)STD.Str.FindReplace(LEFT.pop_2010,',',''),
         SELF.pop_2018 := (UNSIGNED4)STD.Str.FindReplace(LEFT.pop_2018,',','')
       ) 
    );       

OUTPUT(cleanedPop ,,popclean.filePath, THOR, COMPRESSED, OVERWRITE);
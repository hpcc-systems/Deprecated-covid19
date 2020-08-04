IMPORT hpccsystems.covid19.file.raw.canadaPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.canadaPopulation as popClean;

IMPORT Std;


cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (
         popClean.layout,                          
         SELF.geography := IF( LEFT.geography = 'Ontario by Health Unit 8', 'ONTARIO',  Std.Str.ToUpperCase(LEFT.geography)),
         SELF.pop_2015 := LEFT._015,
         SELF.pop_2016 := LEFT._016,
         SELF.pop_2017 := LEFT._017,
         SELF.pop_2018 := LEFT._018,
         SELF.pop_2019 := LEFT._019
       ) 
    );       
clean := SORT(cleanedPop(geography <> 'ONTARIO BY LOCAL HEALTH INTEGRATION NETWORK 8'), geography);

OUTPUT(clean ,,popclean.filePath, THOR, COMPRESSED, OVERWRITE);
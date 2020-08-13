IMPORT hpccsystems.covid19.file.raw.GermanyPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.GermanyPopulation as popClean;
IMPORT Std;


cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (RECORDOF(LEFT),
            location0 := REGEXREPLACE('[^A-Za-z]', LEFT.location, '');
            SELF.location := STD.Str.ToUpperCase(TRIM(location0, LEFT, RIGHT));
            name0 := REGEXREPLACE('[^A-Za-z-]', LEFT.name, '');
            name1 := STD.Str.ToUpperCase(TRIM(name0, LEFT, RIGHT));
            SELF.name := IF( name1 = 'BADEN-WRTTEMBERG','BADEN-WURTTEMBERG' , name1),
            SELF := LEFT;
       ) 
    );   




OUTPUT(cleanedPop, , popclean.filePath, THOR, COMPRESSED, OVERWRITE);
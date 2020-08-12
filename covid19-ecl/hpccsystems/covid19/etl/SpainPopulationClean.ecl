IMPORT hpccsystems.covid19.file.raw.SpainPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.SpainPopulation as popClean;

IMPORT Std;


cleanLocation(STRING s) := FUNCTION 
RETURN CASE(s, 
            'ANDALUC A' => 'ANDALUSIA' ,
            'ARAG N' => 'ARAGON' ,
            'ASTURIAS PRINCIPADO DE' => 'ASTURIAS' ,
            'BALEARS ILLES' => 'BALEARES' ,
            'CASTILLA Y LE N' => 'CASTILLA Y LEON' ,
            'CASTILLA LA MANCHA' => 'CASTILLA - LA MANCHA' ,
            'CATALU A' => 'CATALONIA' ,
            'COMUNITAT VALENCIANA' => 'C. VALENCIANA' ,
            'MADRID COMUNIDAD DE' => 'MADRID' ,
            'MURCIA REGI N DE' => 'MURCIA' , 
            'NAVARRA COMUNIDAD FORAL DE' => 'NAVARRA' ,
            'PA S VASCO' => 'PAIS VASCO' ,
            'RIOJA LA' => 'LA RIOJA' ,
            // '' => '' ,
            s);

END;

cleanedPop := PROJECT
    (
       popRaw.ds[2..], 
       TRANSFORM
       (popClean.layout,
            place0 := REGEXReplace('[^A-Za-z]', TRIM(LEFT.location[4..], LEFT, RIGHT), ' ');
            place1 := REGEXReplace('[ ]+', place0, ' ');
            place2 := STD.Str.ToUpperCase(place1);
            SELF.location :=cleanLocation(place2) ,
            SELF := LEFT
       ) 
    );       

OUTPUT(cleanedPop, , popclean.filePath, THOR, COMPRESSED, OVERWRITE);

OUTPUT(popRaw.ds);
OUTPUT(cleanedPop);
IMPORT hpccsystems.covid19.file.raw.ItalyPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.ItalyPopulation as popClean;
IMPORT Std;


cleanedPop0 := PROJECT
    (
       popRaw.ds( eta1 = 'TOTAL'), 
       TRANSFORM
       (RECORDOF(LEFT),
            SELF.territory := STD.Str.ToUpperCase(TRIM(LEFT.territory, LEFT, RIGHT));
            SELF.gender := STD.Str.ToUpperCase(TRIM(LEFT.gender, LEFT, RIGHT));
            SELF := LEFT;
       ) 
    );   

cleanedPop1 := PROJECT(cleanedpop0( gender = 'TOTAL'),
                            TRANSFORM(popclean.layout,
                                        SELF.territory := CASE(LEFT.territory,
                                                                'FRIULI-VENEZIA GIULIA' => 'FRIULI VENEZIA GIULIA',
                                                                'PROVINCIA AUTONOMA BOLZANO / BOZEN' => 'P.A. BOLZANO',
                                                                'PROVINCIA AUTONOMA TRENTO' => 'P.A. TRENTO',
                                                                'VALLE D\'AOSTA / VALL?E D\'AOSTE' => 'VALLE D\'AOSTA',
                                                                LEFT.territory),
                                        SELF := LEFT));


OUTPUT(cleanedPop1, , popclean.filePath, THOR, COMPRESSED, OVERWRITE);
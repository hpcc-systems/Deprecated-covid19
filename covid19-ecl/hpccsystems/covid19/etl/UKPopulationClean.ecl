IMPORT hpccsystems.covid19.file.raw.UKPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.UKPopulation as popClean;
IMPORT hpccsystems.covid19.file.public.WorldPopulation as worldpopClean;
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

rTemp := RECORD
    popClean.layout.Code;
    popClean.layout.Name;
    popClean.layout.Geography1;
    popClean.layout.All_ages;
END;

overseas := DATASET([{'NA', 'ANGUILLA', 'OVERSEAS TERRITORY', 15015},
                    {'NA', 'BERMUDA', 'OVERSEAS TERRITORY', 62258},
                    {'NA', 'BRITISH VIRGIN ISLANDS', 'OVERSEAS TERRITORY', 31758},
                    {'NA', 'CAYMAN ISLANDS', 'OVERSEAS TERRITORY', 68076},
                    {'NA', 'CHANNEL ISLANDS', 'OVERSEAS TERRITORY', 174002},
                    {'NA', 'FALKLAND ISLANDS (ISLAS MALVINAS)', 'OVERSEAS TERRITORY', 3486},
                    {'NA', 'FALKLAND ISLANDS (MALVINAS)', 'OVERSEAS TERRITORY', 3200},
                    {'NA', 'GIBRALTAR', 'OVERSEAS TERRITORY', 33701},
                    {'NA', 'ISLE OF MAN', 'OVERSEAS TERRITORY', 84077},
                    {'NA', 'MONTSERRAT', 'OVERSEAS TERRITORY', 5215},
                    {'NA', 'TURKS AND CAICOS ISLANDS', 'OVERSEAS TERRITORY', 38191}
                    ],rTemp);

ISLAS_MALVINAS := overseas( name = 'FALKLAND ISLANDS (ISLAS MALVINAS)');

t1 := PROJECT(worldpopclean.ds_popgender(location IN SET(overseas,name)), 
              TRANSFORM(popClean.layout,
                            SELF.name := LEFT.location,
                            SELF.code := 'NA',
                            SELF.Geography1 := 'OVERSEAS TERRITORY',
                            SELF.all_ages := LEFT.poptotal,
                            SELF := LEFT));
t2 := PROJECT(ISLAS_MALVINAS,TRANSFORM(popClean.layout, SELF := LEFT ));


cleands := cleanedPop + t1 + t2;


OUTPUT(cleands , , popclean.filePath, THOR, COMPRESSED, OVERWRITE);


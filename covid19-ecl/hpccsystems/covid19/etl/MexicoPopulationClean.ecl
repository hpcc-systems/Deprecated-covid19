IMPORT hpccsystems.covid19.file.raw.MexicoPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.MexicoPopulation as popClean;
IMPORT STD;


cleanDS := PROJECT(popRaw.ds,
                        TRANSFORM(popClean.layout,
                                  SELF.state := MAP( LEFT.state = 'Coahuila de Zaragoza' => 'COAHUILA',
                                                     LEFT.state = 'Michoacan de Ocampo' => 'MICHOACAN',
                                                     LEFT.state = 'Veracruz de Ignacio de la Llave' => 'VERACRUZ',                            
                                                     STD.Str.ToUPPERCase(LEFT.state)),
                                  SELF.total := (UNSIGNED) STD.Str.FindReplace(LEFT.total, ' ', '')
                                  ));


OUTPUT(cleands,, popClean.filepath, OVERWRITE);



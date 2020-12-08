IMPORT hpccsystems.covid19.file.raw.UKArea as Raw;
IMPORT hpccsystems.covid19.file.public.UKArea as Public;
IMPORT STD;


cleanDS := PROJECT(raw.ds, 
                    TRANSFORM(public.layout, 
                                  SELF.filters := STD.Str.ToUpperCase(LEFT.filters[26..]),
                                  SELF.name := STD.Str.ToUpperCase(LEFT.name),
                                  SELF.date := (INTEGER) (LEFT.date[1..4] + LEFT.date[6..7] + LEFT.date[9..10]), 
                                  SELF := LEFT));


OUTPUT(cleands,, public.filepath, OVERWRITE);



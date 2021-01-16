IMPORT hpccsystems.covid19.file.raw.OWID as raw;
IMPORT hpccsystems.covid19.file.public.OWID as public;
IMPORT STD;

ds := raw.ds;

cleanDS := PROJECT(ds, TRANSFORM(public.layout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= IF(LEFT.iso_code='USA','US',Std.Str.ToUpperCase(LEFT.location)),
                                  SELF := LEFT));


OUTPUT(cleands, , public.filepath, OVERWRITE, COMPRESSED);
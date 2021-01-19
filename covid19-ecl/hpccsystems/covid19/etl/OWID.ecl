IMPORT hpccsystems.covid19.file.raw.OWID as raw;
IMPORT hpccsystems.covid19.file.public.OWID as public;
IMPORT STD;

worldDs := raw.worldDs;

cleanWorldDs := PROJECT(worldDs, TRANSFORM(public.worldLayout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= IF(LEFT.iso_code='USA','US',Std.Str.ToUpperCase(LEFT.location)),
                                  SELF := LEFT));


OUTPUT(cleanWorldDS, , public.worldFilePath, OVERWRITE, COMPRESSED);


usDs := raw.usDs;

cleanUSDs := PROJECT(usDs, TRANSFORM(public.usLayout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= Std.Str.ToUpperCase(LEFT.location),
                                  SELF := LEFT));


OUTPUT(cleanUSDs, , public.usFilePath, OVERWRITE, COMPRESSED);
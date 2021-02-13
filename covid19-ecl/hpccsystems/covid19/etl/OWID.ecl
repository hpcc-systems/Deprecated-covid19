IMPORT hpccsystems.covid19.file.raw.OWID as raw;
IMPORT hpccsystems.covid19.file.public.OWID as public;
IMPORT STD;
#WORKUNIT('name', 'OWID_Clean');

today := STD.Date.Today();

worldDs := raw.worldDs;

cleanWorldDs0 := PROJECT(worldDs, TRANSFORM(public.worldLayout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= IF(LEFT.iso_code='USA','US',Std.Str.ToUpperCase(LEFT.location)),
                                  SELF := LEFT));


dates_world := TABLE(cleanWorldDs0, {date, cnt := COUnt(GROUP)}, date );
locations_world :=  TABLE(cleanWorldDs0, {location, iso_code, cnt := COUnt(GROUP)}, location, iso_code );
pair_world := JOIN(dates_world, locations_world, TRUE, TRANSFORM({UNSIGNED4 date, STRING location, STRING iso_code}, SELF := LEFT, SELF := RIGHT), ALL);
cleanWorldDs:= JOIN(pair_world, cleanWorldDs0 , LEFT.location = RIGHT.location AND LEFT.date = RIGHT.date, TRANSFORM(RECORDOF(RIGHT),  SELF := LEFT, SELF := RIGHT),  LEFT OUTER);
// OUTPUT(SORT(cleanWorldDS, location, date), , public.worldFilePath, OVERWRITE, COMPRESSED);
// t0 :=  TABLE(cleanWorldDs, {location, iso_code, cnt := COUnt(GROUP)}, location, iso_code );
// t0;

usDs := raw.usDs;

cleanUSDs0 := PROJECT(usDs, TRANSFORM(public.usLayout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= IF( LEFT.location = 'New York State', 'NEW YORK',Std.Str.ToUpperCase(LEFT.location)),
                                  SELF := LEFT));


dates_US := TABLE(cleanUSds0, {date, cnt := COUnt(GROUP)}, date );
locations_US :=  TABLE(cleanUSds0, {location, cnt := COUnt(GROUP)}, location);
pairs_US := JOIN(dates_US, locations_US, TRUE, TRANSFORM({UNSIGNED4 date, STRING location}, SELF := LEFT, SELF := RIGHT), ALL);
cleanUSDS:= JOIN(pairs_US, cleanUSds0 , LEFT.location = RIGHT.location AND LEFT.date = RIGHT.date, TRANSFORM(RECORDOF(RIGHT),  SELF := LEFT, SELF := RIGHT),  HASH, LEFT OUTER);
OUTPUT(SORT(cleanUSDS, location, date), , public.usFilePath, OVERWRITE, COMPRESSED);
// t := table(cleanusDS, {location, cnt := COUNT(GROUP)}, location);
// t;

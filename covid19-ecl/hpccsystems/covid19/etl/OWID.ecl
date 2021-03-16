IMPORT hpccsystems.covid19.file.raw.OWID as raw;
IMPORT hpccsystems.covid19.file.public.OWID as public;
IMPORT STD;
#WORKUNIT('name', 'OWID_Clean');

today := STD.Date.Today();
yesterday := STD.DATE.AdjustDate(today, , , -1);

worldDs := raw.worldDs;
cleanWorldDs0 := PROJECT(worldDs, TRANSFORM(public.worldLayout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= IF(LEFT.iso_code='USA','US',Std.Str.ToUpperCase(LEFT.location)),
                                  SELF := LEFT));
locations_world :=  TABLE(cleanWorldDs0, {location, iso_code, d := MAX(GROUP, date), gap := STD.Date.DaysBetween(MAX(GROUP, date), today), cnt := COUnt(GROUP)}, location, iso_code );
public.worldLayout transNormWorld(RECORDOF(locations_world) l, INTEGER c) :=TRANSFORM
  SELF.date := STD.DATE.AdjustDate(l.d, , , c);
  SELF.total_vaccinations:= 0;
  SELF.people_vaccinated:= 0;
  SELF.people_fully_vaccinated:= 0;
  SELF.daily_vaccinations_raw:= 0;
  SELF.daily_vaccinations:= 0;
  SELF.total_vaccinations_per_hundred:= 0;
  SELF.people_vaccinated_per_hundred:= 0;
  SELF.people_fully_vaccinated_per_hundred:= 0;
  SELF.daily_vaccinations_per_million := 0;
  SELF := l;
END;

inserts_world := NORMALIZE(locations_world, LEFT.gap, transNormWorld(LEFT, COUNTER));
cleanWorldDs:= cleanWorldDs0 + inserts_world;
OUTPUT(SORT(cleanWorldDS, location, date), , public.worldFilePath, OVERWRITE, COMPRESSED);
// cleanWorldDS;



usDs := raw.usDs;

cleanUSDs0 := PROJECT(usDs, TRANSFORM(public.usLayout,
                                  SELF.Date := Std.Date.FromStringToDate(LEFT.Date, '%Y-%m-%d'),
                                  SELF.location:= IF( LEFT.location = 'New York State', 'NEW YORK',Std.Str.ToUpperCase(LEFT.location)),
                                  SELF := LEFT));
locations_US :=  TABLE(cleanUSDs0, {location,  d := MAX(GROUP, date), gap := STD.Date.DaysBetween(MAX(GROUP, date), today), cnt := COUnt(GROUP)}, location);
public.USLayout transNormUS(RECORDOF(locations_US) l, INTEGER c) :=TRANSFORM
  SELF.date := STD.DATE.AdjustDate(l.d, , , c);
  SELF.total_vaccinations := 0;
  SELF.total_distributed := 0;
  SELF.people_vaccinated := 0;
  SELF.people_fully_vaccinated_per_hundred := 0;
  SELF.total_vaccinations_per_hundred := 0;
  SELF.people_fully_vaccinated := 0;
  SELF.people_vaccinated_per_hundred := 0;
  SELF.distributed_per_hundred := 0;
  SELF.daily_vaccinations_raw := 0;
  SELF.daily_vaccinations := 0;
  SELF.daily_vaccinations_per_million := 0;
  SELF.share_doses_used := 0;
  SELF := l;
END;

inserts_US := NORMALIZE(locations_US, LEFT.gap, transNormUS(LEFT, COUNTER));
cleanUSDs:= cleanUSDs0 + inserts_US;
OUTPUT(SORT(cleanUSDS, location, date), , public.usFilePath, OVERWRITE, COMPRESSED);

// cleanUSds(location = 'ALABAMA');

scRecord := RECORD
  string50 fips;
  string admin2;
  string state;
  string country;
  unsigned4 update_date;
  decimal9_6 geo_lat;
  decimal9_6 geo_long;
  unsigned4 confirmed;
  unsigned4 deaths;
  unsigned4 recovered;
  unsigned4 active;
  string combined_key;
 END;

EXPORT DATASET(scRecord) FixupMissingDates(DATASET(scRecord) recs) := FUNCTION
    clean := SORT(recs(update_date > 0), update_date);
    allDates0 := DEDUP(clean, update_date);
    allDates := TABLE(allDates0, {unsigned4 date := update_date});
    clean2 := SORT(clean, admin2, state, country, update_date);
    allLocs0 := DEDUP(clean2, admin2, state, country);
    allLocs := TABLE(allLocs0, {adm2 := admin2, st := state, ctry := country});
    allRecs0 := JOIN(allLocs, allDates,TRUE, TRANSFORM({RECORDOF(LEFT), RECORDOF(RIGHT)},
                    SELF := LEFT, SELF := RIGHT), ALL);
    allRecs := DEDUP(allRecs0, RECORD);
    fixedRecs0 := JOIN(clean, allRecs, LEFT.admin2 = RIGHT.adm2 AND LEFT.state = RIGHT.st AND LEFT.country = RIGHT.ctry AND LEFT.update_date = RIGHT.date, TRANSFORM(RECORDOF(LEFT),
                            SELF.update_date := RIGHT.date,
                            SELF.admin2 := RIGHT.adm2,
                            SELF.state := RIGHT.st,
                            SELF.country := RIGHT.ctry,
                            SELF := LEFT), RIGHT OUTER);
    fixedRecs1 := SORT(fixedRecs0, country, state, admin2, update_date);
    scRecord fixupZeros(scRecord l, scRecord r) := TRANSFORM
        isSameLocation := l.admin2 = r.admin2 AND l.state = r.state AND l.country = r.country;
        SELF.confirmed := IF(isSameLocation, IF(r.confirmed = 0, l.confirmed, r.confirmed), IF(r.confirmed = 0, SKIP, r.confirmed));
        SELF.deaths := IF(isSameLocation, IF(r.confirmed = 0, l.deaths, r.deaths), r.deaths);
        SELF:= r;
    END;
    fixedRecs := ITERATE(fixedRecs1, fixupZeros(LEFT, RIGHT));
    RETURN fixedRecs;
END;
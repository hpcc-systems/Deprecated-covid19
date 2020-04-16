#WORKUNIT('name', 'hpccsystems_covid19_query_trends');

IMPORT hpccsystems.covid19.file.public.JohnHopkins AS covid;  
IMPORT Std;

_typeFilter := 'states':STORED('typeFilter');

latestDate := MAX(covid.worldDs, update_date);
leastDate := Std.Date.AdjustDate(latestDate,0,0,-6);

locationsFilter := '':STORED('locationsFilter'); 
_locationsFilter := Std.Str.SplitWords(locationsFilter, ',') ;
_topX := 5:STORED('topX'); 

sumByDate := IF (_typeFilter='countries',
                    TABLE(covid.worldDs,
                    {     STRING location := country, 
                          Std.Date.Date_t date := update_date, 
                          UNSIGNED4 confirmed := SUM(GROUP, confirmed),
                          UNSIGNED4 deaths := SUM(GROUP, deaths),
                          UNSIGNED4 recovered := SUM(GROUP, recovered),
                          UNSIGNED4 active := SUM(GROUP, active)
                    },
                    country, update_date),
                    TABLE(covid.usDs,
                    {     STRING location := state, 
                          Std.Date.Date_t date := update_date, 
                          UNSIGNED4 confirmed := SUM(GROUP, confirmed),
                          UNSIGNED4 deaths := SUM(GROUP, deaths),
                          UNSIGNED4 recovered := SUM(GROUP, recovered),
                          UNSIGNED4 active := SUM(GROUP, active)
                    },
                    state, update_date)
              );


increaseByDayLayout := RECORD
  sumByDate;
  UNSIGNED4  confirmed_increase := 0;  
  UNSIGNED4  deaths_increase := 0; 
  UNSIGNED4  recovered_increase := 0; 
  UNSIGNED4  active_increase := 0;  
END;

increaseByDayTemp := TABLE(sumByDate,increaseByDayLayout);


increaseByDay := ITERATE(SORT(increaseByDayTemp,location,date), 
                         TRANSFORM(increaseByDayLayout, 
                                         SELF.confirmed_increase := IF(LEFT.location=RIGHT.location, IF(RIGHT.confirmed-LEFT.confirmed > 0, RIGHT.confirmed-LEFT.confirmed, 0), 0),
                                         SELF.deaths_increase := IF(LEFT.location=RIGHT.location, IF(RIGHT.deaths-LEFT.deaths > 0, RIGHT.deaths-LEFT.deaths, 0), 0),
                                         SELF.recovered_increase := IF(LEFT.location=RIGHT.location, IF(RIGHT.recovered-LEFT.recovered > 0, RIGHT.recovered-LEFT.recovered, 0), 0),
                                         SELF.active_increase := IF(LEFT.location=RIGHT.location, IF(RIGHT.active-LEFT.active > 0, RIGHT.active-LEFT.active, 0), 0),
                                         SELF:= RIGHT
                                   ));


latest := increaseByDay(date=latestDate);
topConfirmed := TOPN(latest,_topX,-confirmed);
OUTPUT(topConfirmed,,NAMED('top_confirmed'));
OUTPUT(TOPN(latest,_topX,-deaths),,NAMED('top_deaths'));
OUTPUT(TOPN(latest,_topX,-confirmed_increase),,NAMED('top_confirmed_increase'));
OUTPUT(TOPN(latest,_topX,-deaths_increase),,NAMED('top_deaths_increase'));

OUTPUT (CHOOSEN(latest,1000),,NAMED('latest'));

OUTPUT(TABLE(latest, {date, confirmed_total:= SUM(GROUP, confirmed), 
                      confirmed_increase_total:= SUM(GROUP, confirmed_increase), 
                      deaths_total:= SUM(GROUP, deaths), 
                      deaths_increase_total:= SUM(GROUP,deaths_increase)}, date),,NAMED('summary'));

_locationsFilterWithDefaults := IF (COUNT(_locationsFilter) = 0, SET(topConfirmed,location), _locationsFilter);
world := increaseByDay(location in _locationsFilterWithDefaults and date > leastDate);

OUTPUT(world,,NAMED('trends'));
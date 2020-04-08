#WORKUNIT('name', 'hpccsystems_covid19_query_summary_world');

IMPORT hpccsystems.covid19.file.public.JohnHopkins AS covid;  
IMPORT Std;


latestDate := MAX(covid.worldDs, update_date);
leastDate := Std.Date.AdjustDate(latestDate,0,0,-6);

_countriesFilter := '':STORED('countriesFilter'); 

sumByCountryDate := TABLE(covid.worldDs,
                          {country, 
                                Std.Date.Date_t date := update_date, 
                                UNSIGNED4 confirmed := SUM(GROUP, confirmed),
                                UNSIGNED4 deaths := SUM(GROUP, deaths),
                                UNSIGNED4 recovered := SUM(GROUP, recovered),
                                UNSIGNED4 active := SUM(GROUP, active)
                           },
                          country, update_date);


increaseByDayLayout := RECORD
  sumByCountryDate;
  UNSIGNED4  confirmed_increase := 0;  
  UNSIGNED4  deaths_increase := 0; 
  UNSIGNED4  recovered_increase := 0; 
  UNSIGNED4  active_increase := 0;  
END;

increaseByDayTemp := TABLE(sumByCountryDate,increaseByDayLayout);


increaseByDay := ITERATE(SORT(increaseByDayTemp,country,date), 
                         TRANSFORM(increaseByDayLayout, 
                                         SELF.confirmed_increase := IF(LEFT.country=RIGHT.country, IF(RIGHT.confirmed-LEFT.confirmed > 0, RIGHT.confirmed-LEFT.confirmed, 0), 0),
                                         SELF.deaths_increase := IF(LEFT.country=RIGHT.country, IF(RIGHT.deaths-LEFT.deaths > 0, RIGHT.deaths-LEFT.deaths, 0), 0),
                                         SELF.recovered_increase := IF(LEFT.country=RIGHT.country, IF(RIGHT.recovered-LEFT.recovered > 0, RIGHT.recovered-LEFT.recovered, 0), 0),
                                         SELF.active_increase := IF(LEFT.country=RIGHT.country, IF(RIGHT.active-LEFT.active > 0, RIGHT.active-LEFT.active, 0), 0),
                                         SELF:= RIGHT
                                   ));


world := increaseByDay(country in Std.Str.SplitWords(_countriesFilter, ',')  and date > leastDate);

OUTPUT(world,,NAMED('world'));

OUTPUT(TOPN(increaseByDay(date=latestDate),10,-confirmed),,NAMED('top_confirmed'));
OUTPUT(TOPN(increaseByDay(date=latestDate),10,-deaths),,NAMED('top_deaths'));
OUTPUT(TOPN(increaseByDay(date=latestDate),10,-confirmed_increase),,NAMED('top_confirmed_increase'));
OUTPUT(TOPN(increaseByDay(date=latestDate),10,-deaths_increase),,NAMED('top_deaths_increase'));

OUTPUT (CHOOSEN(TABLE(DEDUP(SORT(covid.worldDs,country),country), {STRING50 name := country}),1000),,NAMED('countries_catalog'));
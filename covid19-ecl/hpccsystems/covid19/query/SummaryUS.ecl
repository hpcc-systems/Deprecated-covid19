#WORKUNIT('name', 'hpccsystems_covid19_query_summary_us');

IMPORT hpccsystems.covid19.file.public.JohnHopkins AS covid;  
IMPORT hpccsystems.covid19.file.public.USPopulation AS Pop;
IMPORT hpccsystems.covid19.utils.CatalogUSStates As utils;
IMPORT Std;

_statesFilter := 'CALIFORNIA,NEW YORK,GEORGIA,LOUISIANA,MICHIGAN':STORED('statesFilter'); 

statesFilter := Std.Str.SplitWords(_statesFilter, ',');

latestDate := MAX(covid.worldDs, update_date);
leastDate := Std.Date.AdjustDate(latestDate,0,0,-6);



statesDS := covid.worldDs(country='US');

sumByUSStateDate := TABLE(statesDS,
                         {
                          state, Std.Date.Date_t date := update_date, 
                          UNSIGNED4 confirmed := SUM(GROUP, confirmed),
                          UNSIGNED4 deaths := SUM(GROUP, deaths),
                          UNSIGNED4 recovered := SUM(GROUP, recovered),
                          UNSIGNED4 active    := SUM(GROUP, active)   
                         },
                          state,update_date);


statesIncreaseByDayLayout := RECORD
  sumByUSStateDate;
  UNSIGNED4  confirmed_increase := 0;  
  UNSIGNED4  deaths_increase := 0; 
  UNSIGNED4  recovered_increase := 0; 
  UNSIGNED4  active_increase := 0;  
END;

statesIncreaseByDayTemp := TABLE(sumByUSStateDate, statesIncreaseByDayLayout);

increaseByDay := ITERATE(SORT(statesIncreaseByDayTemp, state, date),
                               TRANSFORM(statesIncreaseByDayLayout,
                                         SELF.confirmed_increase := IF(LEFT.state=RIGHT.state, IF(RIGHT.confirmed-LEFT.confirmed > 0, RIGHT.confirmed-LEFT.confirmed, 0), 0),
                                         SELF.deaths_increase := IF(LEFT.state=RIGHT.state, IF(RIGHT.deaths-LEFT.deaths > 0, RIGHT.deaths-LEFT.deaths, 0), 0),
                                         SELF.recovered_increase := IF(LEFT.state=RIGHT.state, IF(RIGHT.recovered-LEFT.recovered > 0, RIGHT.recovered-LEFT.recovered, 0), 0),
                                         SELF.active_increase := IF(LEFT.state=RIGHT.state, IF(RIGHT.active-LEFT.active > 0, RIGHT.active-LEFT.active, 0), 0),
                                         SELF:= RIGHT));
                                         
 


states := increaseByDay(state in statesFilter and date > leastDate);
popStates := Pop.ds(state in statesFilter);

joinStatesPop := JOIN(states, popStates, LEFT.state=RIGHT.state, 
                      TRANSFORM(RECORDOF(states), 
                                SELF.confirmed := RIGHT.pop_2018/LEFT.confirmed, SELF := LEFT));

OUTPUT(SORT(states, state, date),,NAMED('states'));

OUTPUT(TABLE(SORT(popStates, state),{state, pop_2018}),,NAMED('pop_states'));
    
OUTPUT(TABLE(sumByUSStateDate(date=latestDate), {STRING2 state_code := Utils.toStateCode(state), confirmed}),,NAMED('states_today'));

OUTPUT(TABLE(Utils.states,{STRING50 state := name}),,NAMED('catalog_states'));

OUTPUT(TOPN(increaseByDay(date=latestDate),10,-confirmed),,NAMED('top_confirmed'));
OUTPUT(TOPN(increaseByDay(date=latestDate),10,-deaths),,NAMED('top_deaths'));
OUTPUT(TOPN(increaseByDay(date=latestDate),10,-confirmed_increase),,NAMED('top_confirmed_increase'));
OUTPUT(TOPN(increaseByDay(date=latestDate),10,-deaths_increase),,NAMED('top_deaths_increase'));

OUTPUT (CHOOSEN(TABLE(DEDUP(SORT(covid.usDs,state),state), {STRING50 name := state}),1000),,NAMED('countries_catalog'));


#WORKUNIT('name', 'hpccsystems_covid19_query_countries_map');

IMPORT hpccsystems.covid19.file.public.DailyMetrics AS dailyMetrics;  
IMPORT hpccsystems.covid19.file.public.WeeklyMetrics AS weeklyMetrics;  
IMPORT hpccsystems.covid19.utils.CatalogUSStates as states;
IMPORT Std;


latestDate := MAX(dailyMetrics.states, date);

daily := JOIN(dailyMetrics.countries (date=latestDate), weeklyMetrics.world (period = 1), 
          LEFT.location=RIGHT.location,
          TRANSFORM ({STRING location,
                      STRING location_code,
                      unsigned4 date,
                      STRING date_string,
                      REAL8 cases,
                      REAL8 new_cases,
                      REAL8 deaths,
                      REAL8 new_deaths,
                      REAL8 active,
                      REAL8 recovered,
                      REAL8 cases_per_capita,
                      REAL8 deaths_per_capita,                      
                      REAL8 period_new_cases,
                      REAL8 period_new_deaths,
                      REAL8 period_active,
                      REAL8 period_recovered,
                      STRING status,
                      STRING period_string,
                      REAL8 cr,
                      REAL8 mr,
                      REAL8 R,
                      REAL8 sd_indicator,
                      REAL8 med_indicator,
                      REAL8 cfr,
                      REAL8 heat_index,
                      REAL8 status_numb,
                      REAL8 infection_count,
                      REAL8 sti,
                      REAL8 ewi,
                      },

                      SELF.location := LEFT.location,
                      SELF.location_code := LEFT.location,
                      SELF.date := LEFT.date,
                      SELF.date_string := Std.Date.DateToString(LEFT.date , '%B %e, %Y'),
                      SELF.cases := LEFT.cumcases,
                      SELF.new_cases := LEFT.newcases,
                      SELF.deaths := LEFT.cumdeaths,
                      SELF.new_deaths := LEFT.newdeaths,
                      SELF.active := LEFT.active,
                      SELF.recovered := LEFT.recovered,
                      SELF.cases_per_capita := RIGHT.cases_per_capita,
                      SELF.deaths_per_capita := RIGHT.deaths_per_capita,
                      SELF.status := RIGHT.istate,
                      SELF.status_numb := CASE(RIGHT.istate, 
                                        'Initial' => 0, 
                                        'Recovered' => 1, 
                                        'Recovering' => 2,
                                        'Stabilized' => 3,
                                        'Stabilizing' => 4,
                                        'Emerging' => 5,
                                        'Spreading' => 6,
                                        'Regressing' => 7, 0),
                      SELF.period_string := Std.Date.DateToString(RIGHT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(RIGHT.enddate , '%B %e, %Y'),
                      SELF.cr := RIGHT.cr,
                      SELF.mr := RIGHT.mr,
                      SELF.R := RIGHT.R,
                      SELF.sd_indicator := RIGHT.sdIndicator,
                      SELF.med_indicator := RIGHT.medIndicator,
                      SELF.cfr := RIGHT.cfr, 
                      SELF.sti := RIGHT.sti,
                      SELF.ewi := RIGHT.ewi,
                      SELF.heat_index := RIGHT.heatIndex,
                      SELF.infection_count := RIGHT.infectionCount,
                      SELF.period_new_cases := RIGHT.newCases;
                      SELF.period_new_deaths := RIGHT.newDeaths;
                      SELF.period_recovered := RIGHT.recovered;
                      SELF.period_active := RIGHT.active;                         
                      ));



OUTPUT (daily,ALL,NAMED('latest'));

maxDs := TABLE(daily, {date, 
                      cases_max := MAX(GROUP, cases),
                      new_cases_max := MAX(GROUP, new_cases),
                      deaths_max := MAX(GROUP, deaths),
                      new_deaths_max := MAX(GROUP, new_deaths),
                      cases_per_capita_max := MAX(GROUP, cases_per_capita),
                      deaths_per_capita_max := MAX(GROUP, deaths_per_capita)
                      }, date);

OUTPUT(TABLE(weeklyMetrics.global (period = 1), {cases_total:= cases,
                                                 new_cases_total := newCases,
                                                 new_deaths_total := newDeaths,
                                                 deaths_total := deaths,
                                                 active_total := active,
                                                 recovered_total := recovered,
                                                 cases_max := maxDs[1].cases_max,   
                                                 deaths_max := maxDs[1].deaths_max,
                                                 new_cases_max := maxDs[1].new_cases_max,
                                                 new_deaths_max := maxDs[1].new_deaths_max,
                                                 cases_per_capita_max := maxDs[1].cases_per_capita_max,
                                                 deaths_per_capita_max := maxDs[1].deaths_per_capita_max,
                                                 commentary}),,NAMED('summary'));          


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

                      STRING status,
                      STRING period_string,
                      REAL8 cr,
                      REAL8 mr,
                      REAL8 sd_indicator,
                      REAL8 med_indicator,
                      REAL8 imort,
                      REAL8 heat_index,
                      REAL8 status_numb
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
                      SELF.sd_indicator := RIGHT.sdIndicator,
                      SELF.med_indicator := RIGHT.medIndicator,
                      SELF.imort := RIGHT.imort,
                      SELF.heat_index := RIGHT.heatIndex,
                      
                      ));



OUTPUT (daily,ALL,NAMED('latest'));

OUTPUT(TABLE(daily, {date, 
                      cases_total:= SUM(GROUP, cases), 
                      new_cases_total:= SUM(GROUP, new_cases), 
                      deaths_total:= SUM(GROUP, deaths), 
                      new_deaths_total:= SUM(GROUP, new_deaths),
                      active_total:= SUM(GROUP, active),
                      recovered_total := SUM(GROUP, recovered),
                      cases_max := MAX(GROUP, cases),
                      new_cases_max := MAX(GROUP, new_cases),
                      deaths_max := MAX(GROUP, deaths),
                      new_deaths_max := MAX(GROUP, new_deaths),
                      status_max := 7,
                      }, date),,NAMED('summary'));          
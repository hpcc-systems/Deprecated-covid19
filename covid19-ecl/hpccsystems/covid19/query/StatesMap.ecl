#WORKUNIT('name', 'hpccsystems_covid19_query_states_map');

IMPORT hpccsystems.covid19.file.public.DailyMetrics AS dailyMetrics;  
IMPORT hpccsystems.covid19.file.public.WeeklyMetrics AS weeklyMetrics;  
IMPORT hpccsystems.covid19.utils.CatalogUSStates as states;
IMPORT Std;

latestDate := MAX(dailyMetrics.states, date);

daily := JOIN(dailyMetrics.states (date=latestDate), weeklyMetrics.states (period = 1), 
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
                      REAL8 heat_index
                      },

                      SELF.location := LEFT.location,
                      SELF.location_code := states.toCode(LEFT.location),
                      SELF.date := LEFT.date,
                      SELF.date_string := Std.Date.DateToString(LEFT.date , '%B %e, %Y'),
                      SELF.cases := LEFT.cumcases,
                      SELF.new_cases := LEFT.newcases,
                      SELF.deaths := LEFT.cumdeaths,
                      SELF.new_deaths := LEFT.newdeaths,
                      SELF.active := LEFT.active,
                      SELF.recovered := LEFT.recovered, 
                      SELF.status := RIGHT.istate,
                      SELF.period_string := Std.Date.DateToString(RIGHT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(RIGHT.enddate , '%B %e, %Y'),
                      SELF.cr := RIGHT.cr,
                      SELF.mr := RIGHT.mr,
                      SELF.sd_indicator := RIGHT.sdIndicator,
                      SELF.med_indicator := RIGHT.medIndicator,
                      SELF.imort := RIGHT.imort,
                      SELF.heat_index := RIGHT.heatIndex
                      ));



latest := daily(date=latestDate);

OUTPUT (latest,ALL,NAMED('latest'));

OUTPUT(TABLE(latest, {date, 
                      cases_total:= SUM(GROUP, cases), 
                      new_cases_total:= SUM(GROUP, new_cases), 
                      deaths_total:= SUM(GROUP, deaths), 
                      new_deaths_total:= SUM(GROUP, new_deaths),
                      active_total:= SUM(GROUP, active),
                      recovered_total := SUM(GROUP, recovered)
                      }, date),,NAMED('summary'));          
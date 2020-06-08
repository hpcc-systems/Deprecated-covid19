#WORKUNIT('name', 'hpccsystems_covid19_query_daily_metrics');

IMPORT hpccsystems.covid19.file.public.DailyMetrics AS metrics;  
IMPORT Std;

_typeFilter := 'states':STORED('typeFilter');

latestDate := MAX(metrics.states, date);
leastDate := Std.Date.AdjustDate(latestDate,0,0,-7);

locationsFilter := '':STORED('locationsFilter'); 
_locationsFilter := Std.Str.SplitWords(locationsFilter, ',') ;
_topX := 5:STORED('topX'); 

raw := CASE(_typeFilter, 'states' => metrics.states, 'countries' => metrics.countries, 'counties' => metrics.counties, metrics.states);
daily := TABLE(raw, {location, 
            date, 
            STRING date_string := STD.Date.Year(date) + '-' + STD.Date.Month(date) + '-' + STD.Date.Day(date),
            REAL8 cases:= cumcases, 
            REAL8 new_cases := newcases,
            REAL8 deaths:= cumdeaths,
            REAL8 new_deaths:= newdeaths,
            REAL8 active := active,
            REAL8 recovered:= recovered});

latest := daily(date=latestDate);
topConfirmed := TOPN(latest,_topX,-active);

OUTPUT (CHOOSEN(latest,1000),,NAMED('latest'));

OUTPUT(TABLE(latest, {date, 
                      cases_total:= SUM(GROUP, cases), 
                      new_cases_total:= SUM(GROUP, new_cases), 
                      deaths_total:= SUM(GROUP, deaths), 
                      new_deaths_total:= SUM(GROUP, new_deaths),
                      active_total:= SUM(GROUP, active),
                      recovered_total := SUM(GROUP, recovered)
                      }, date),,NAMED('summary'));

_locationsFilterWithDefaults := IF (COUNT(_locationsFilter) = 0, SET(topConfirmed,location), _locationsFilter);

dailyTrend := daily(location in _locationsFilterWithDefaults and date > leastDate);

OUTPUT(SORT(dailyTrend, date),,NAMED('trends'));


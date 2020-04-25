#WORKUNIT('name', 'hpccsystems_covid19_query_daily_metrics');

IMPORT hpccsystems.covid19.file.public.DailyMetrics AS metrics;  
IMPORT Std;

_typeFilter := 'states':STORED('typeFilter');

latestDate := MAX(metrics.states, date);
leastDate := Std.Date.AdjustDate(latestDate,0,0,-6);

locationsFilter := '':STORED('locationsFilter'); 
_locationsFilter := Std.Str.SplitWords(locationsFilter, ',') ;
_topX := 5:STORED('topX'); 

raw := CASE(_typeFilter, 'states' => metrics.states, 'countries' => metrics.countries, 'counties' => metrics.counties, metrics.states);
daily := TABLE(raw, {location, 
            date, 
            DECIMAL8_2 cases:= cumcases, 
            DECIMAL8_2 new_cases := newcases,
            DECIMAL8_2 deaths:= cumdeaths,
            DECIMAL8_2 new_deaths:= newdeaths,
            DECIMAL8_2 active := active,
            DECIMAL8_2 recovered:= recovered});

latest := daily(date=latestDate);
topConfirmed := TOPN(latest,_topX,-cases);

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


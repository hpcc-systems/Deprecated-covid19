#WORKUNIT('name', 'hpccsystems_covid19_query_metrics_grouped');

IMPORT hpccsystems.covid19.file.public.WeeklyMetrics as metrics;
IMPORT Std;

_typeFilter := 'states':STORED('typeFilter');
_periodFilter := 1:STORED('periodFilter');
locationsFilter := '':STORED('locationsFilter'); 
_locationsFilter := Std.Str.SplitWords(locationsFilter, ',');

allData := CASE (_typeFilter, 'states' => metrics.statesGrouped, 'countries' => metrics.worldGrouped, 'counties' => metrics.countiesGrouped, metrics.statesGrouped);

filtered := allData(period = _periodFilter and location in _locationsFilter);
OUTPUT(CHOOSEN(filtered, 10000),,NAMED('metrics_grouped'));


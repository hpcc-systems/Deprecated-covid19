#WORKUNIT('name', 'hpccsystems_covid19_query_metrics_grouped');

IMPORT hpccsystems.covid19.file.public.Metrics as metrics;
IMPORT Std;

_typeFilter := 'states':STORED('typeFilter');
_periodFilter := 1:STORED('periodFilter');
locationsFilter := '':STORED('locationsFilter'); 
_locationsFilter := Std.Str.SplitWords(locationsFilter, ',');

allData := CASE (_typeFilter, 'states' => metrics.statesGrouped, 'countries' => metrics.worldGrouped, 'counties' => metrics.countiesGrouped, metrics.statesGrouped);

OUTPUT(allData(period = _periodFilter and location in _locationsFilter),,NAMED('metrics_grouped'));
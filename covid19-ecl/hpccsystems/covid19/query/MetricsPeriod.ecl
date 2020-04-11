#WORKUNIT('name', 'hpccsystems_covid19_query_metrics_period');

IMPORT hpccsystems.covid19.file.public.Metrics as metrics;

_typeFilter := 'states':STORED('typeFilter');
_periodFilter := 1:STORED('periodFilter');

allData := CASE (_typeFilter, 'states' => metrics.statesAll, 'countries' => metrics.worldAll, 'counties' => metrics.countiesAll, metrics.statesAll);

OUTPUT(SORT(allData(period = _periodFilter),-heatindex),,NAMED('metrics_period'));
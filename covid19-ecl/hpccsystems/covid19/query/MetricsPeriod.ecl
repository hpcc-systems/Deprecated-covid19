#WORKUNIT('name', 'hpccsystems_covid19_query_metrics_period');

IMPORT hpccsystems.covid19.file.public.WeeklyMetrics as metrics;

_typeFilter := 'states':STORED('typeFilter');
_heatIndex := 1:STORED('heatIndex');

allData := CASE (_typeFilter, 'states' => metrics.statesAll, 'countries' => metrics.worldAll, 'counties' => metrics.countiesAll, metrics.statesAll);

filtered := SORT(allData(period = 1 and heatindex >= _heatIndex),-heatindex);   


OUTPUT(CHOOSEN(filtered, 10000),,NAMED('metrics_period'));

OUTPUT(CHOOSEN(TABLE(filtered, {location}), 10),,NAMED('default_locations'));
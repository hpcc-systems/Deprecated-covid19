#WORKUNIT('name', 'hpccsystems_covid19_query_location_metrics');

IMPORT hpccsystems.covid19.file.public.WeeklyMetrics as metrics;

_location := 'GEORGIA':STORED('location');
_locationType :=  'states':STORED('location_type');

ds := CASE(_locationType, 'states' => metrics.states, 'countries' => metrics.world, 'counties' => metrics.counties, metrics.states);
ds_children := CASE (_locationType, 'states' => metrics.counties, 'countries' => metrics.states, DATASET([], RECORDOF(metrics.counties)));

OUTPUT(ds((location=_location or fips=_location) and period=1),ALL,NAMED('summary'));
OUTPUT(ds_children(location=_location and period=1),ALL,NAMED('children'));//FIXME: Will need to fix counties FIPS. Ask Roger to do it in the processing itself?

//TODO: Daily trends
//TODO: Period trends
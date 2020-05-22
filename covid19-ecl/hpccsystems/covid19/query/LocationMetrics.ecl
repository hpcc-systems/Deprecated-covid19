#WORKUNIT('name', 'hpccsystems_covid19_query_location_metrics');

IMPORT hpccsystems.covid19.file.public.WeeklyMetrics as metrics;
IMPORT STD;

_location := 'GEORGIA':STORED('location');
_locationType :=  'states':STORED('location_type');

ds := CASE(_locationType, 'states' => metrics.states, 'countries' => metrics.world, 'counties' => metrics.counties, metrics.states);
ds_children := CASE (_locationType, 'states' => metrics.countiesAll, 'countries' => metrics.statesAll, DATASET([], RECORDOF(metrics.countiesAll)));

OUTPUT(ds((location=_location or fips=_location) and period=1),ALL,NAMED('summary'));

ds_filtered_children :=TABLE(ds_children(parentlocation=_location and period=1),
                            {location,istate,r,commentary});
OUTPUT(SORT(ds_filtered_children,-istate),ALL,NAMED('children'));//FIXME: Will need to fix counties FIPS. Ask Roger to do it in the processing itself?

//TODO: Daily trends
//TODO: Period trends
ds_period_trend := SORT(ds((location=_location or fips=_location)), -period);
OUTPUT(TABLE(ds_period_trend, 
      {ds_period_trend, 
       period_string:= Std.Date.DateToString(startdate , '%B %e') + ' - ' + Std.Date.DateToString(enddate , '%B %e')})
       ,ALL,NAMED('period_trend'));
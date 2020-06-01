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


ds_period_trend := SORT(ds((location=_location or fips=_location)), -period);
OUTPUT(TABLE(ds_period_trend, 
      {ds_period_trend, 
       period_string:= Std.Date.DateToString(startdate , '%b %e') + ' - ' + Std.Date.DateToString(enddate , '%b %e')})
       ,ALL,NAMED('period_trend'));

ds_cases_deaths_trend := NORMALIZE(ds_period_trend, 2, TRANSFORM (
      {STRING period_string,
       STRING measure,
       REAL value},
       SELF.period_string := Std.Date.DateToString(LEFT.startdate , '%b %e') + ' - ' + Std.Date.DateToString(LEFT.enddate , '%b %e'),
       SELF.measure := CASE (COUNTER, 1 => 'New Cases', 2 => 'New Deaths', 'Unknown'),
       SELF.value := CASE (COUNTER, 1 => LEFT.newCases, 2 => LEFT.newDeaths, 0)
));

OUTPUT(ds_cases_deaths_trend, ALL, NAMED('period_cases_deaths_trend'));

ds_metrics_trend := NORMALIZE(ds_period_trend, 3, TRANSFORM (
      {STRING period_string,
       STRING measure,
       REAL value},
       SELF.period_string := Std.Date.DateToString(LEFT.startdate , '%b %e') + ' - ' + Std.Date.DateToString(LEFT.enddate , '%b %e'),
       SELF.measure := CASE (COUNTER, 1 => 'Infection Rate (R)', 2 => 'Cases Rate (cR)', 3 => 'Mortality Rate (mR)', 'Unknown'),
       SELF.value := CASE (COUNTER, 1 => LEFT.r, 2 => LEFT.cR, 3 => LEFT.mR, 0)
));

OUTPUT(ds_metrics_trend, ALL, NAMED('period_metrics_trend'));

   
#WORKUNIT('name', 'hpccsystems_covid19_query_metrics_catalog');

IMPORT hpccsystems.covid19.file.public.Metrics as metrics;

_typeFilter := 'states':STORED('typeFilter');

defaultLocations := CASE (_typeFilter, 'states' => metrics.statesDefaultLocations, 'countries' => metrics.worldDefaultLocations, 'counties' => metrics.countiesDefaultLocations, metrics.statesDefaultLocations);
periodsCatalog := CASE (_typeFilter, 'states' => metrics.statesPeriodsCatalog, 'countries' => metrics.worldPeriodsCatalog, 'counties' => metrics.countiesPeriodsCatalog, metrics.statesPeriodsCatalog);

OUTPUT(CHOOSEN(defaultLocations,10),,NAMED('default_locations'));
OUTPUT(periodsCatalog,,NAMED('catalog_periods'));

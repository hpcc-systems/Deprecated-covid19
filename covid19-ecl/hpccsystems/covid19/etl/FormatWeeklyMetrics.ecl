IMPORT hpccsystems.covid19.file.public.WeeklyMetrics as metrics;
IMPORT hpccsystems.covid19.metrics.Types as types;
IMPORT hpccsystems.covid19.utils.CatalogUSStates as states;
IMPORT Std;


metricsScope := '~hpccsystems::covid19::file::public::metrics::';
  

formatAllMetrics(DATASET(Types.metricsRec) metricsData, STRING destinationFileScope, STRING destinationPrefix) := FUNCTION

        //Fix Locations
        projectedMetrics := PROJECT(metricsData, TRANSFORM(
                                                       metrics.layout,
                                                       locations := Std.Str.SplitWords(LEFT.location, ',');
                                                       SELF.location := IF(COUNT(locations) > 1,locations[1] + '-' + locations[2], TRIM(LEFT.location));
                                                       SELF.parentLocation := IF(COUNT(locations) > 1,locations[1], TRIM(LEFT.location));//The 2 is a workaround to overcome optimization
                                                       SELF.istate := CASE(LEFT.istate, 
                                                                      'Initial' => '0-Initial', 
                                                                      'Recovered' => '1-Recovered', 
                                                                      'Recovering' => '2-Recovering',
                                                                      'Stabilized' => '3-Stabilized',
                                                                      'Stabilizing' => '4-Stabilizing',
                                                                      'Emerging' => '5-Emerging',
                                                                      'Spreading' => '6-Spreading',
                                                                      'Regressing' => '7-Regressing', '8-Unknown');
                                                       SELF := LEFT;
                                                        
                                    ));
        

        locationsCatalog := TABLE(DEDUP(SORT(projectedMetrics(period=1), location), location), {STRING50 id:= TRIM(location), STRING50 title:= TRIM(location)}); 
        defaultLocations := TABLE(TOPN(projectedMetrics(period=1),50,-heatindex), {location});

        metricsByLocation := NORMALIZE(SORT(projectedMetrics,-heatindex),5,TRANSFORM
                                        (
                                            metrics.groupedLayout,
                                            SELF.measure := CASE (COUNTER, 1 => 'R', 2 => 'sdIndicator', 3 => 'medIndicator', 4 => 'imort' ,5 => 'heatindex' ,''),
                                            SELF.value := CASE (COUNTER, 1 => LEFT.r, 2 => LEFT.sdIndicator, 3 => LEFT.medIndicator, 4 => LEFT.imort, 5 => LEFT.heatindex,0),
                                            SELF.locationstatus := TRIM(LEFT.location) + ' [' + TRIM(LEFT.istate) + ']',
                                            SELF := LEFT;
                                        )
                                      );   

        
         periodsCatalog := TABLE(DEDUP(
                                    SORT(metricsByLocation, period),period), 
                                    {STRING50 id := period, STRING50 title := period + ' - [date: ' + startdate + ' - ' + enddate + ', days: ' + perioddays + ']'}
                                );                             

        return SEQUENTIAL (
                    OUTPUT(metricsByLocation,, destinationFileScope + destinationPrefix + '_grouped.flat', THOR, COMPRESSED, OVERWRITE),
                    OUTPUT(projectedMetrics,, destinationFileScope + destinationPrefix + '_all.flat', THOR, COMPRESSED, OVERWRITE),
                    OUTPUT(locationsCatalog,, destinationFileScope + destinationPrefix + '_locations_catalog.flat', THOR, COMPRESSED, OVERWRITE),
                    OUTPUT(periodsCatalog,, destinationFileScope + destinationPrefix + '_periods_catalog.flat', THOR, COMPRESSED, OVERWRITE),
                    OUTPUT(defaultLocations,, destinationFileScope + destinationPrefix + '_locations_default.flat', THOR, COMPRESSED, OVERWRITE)
               );     
                   
END;

formatAllMetrics(metrics.states, metricsScope, 'states');
formatAllMetrics(metrics.counties, metricsScope, 'counties');
formatAllMetrics(metrics.world, metricsScope, 'world');
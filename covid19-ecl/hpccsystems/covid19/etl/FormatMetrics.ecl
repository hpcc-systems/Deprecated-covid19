IMPORT hpccsystems.covid19.file.public.Metrics as metrics;
IMPORT Std;


metricsScope := '~hpccsystems::covid19::file::public::';


formatAllMetrics(DATASET(metrics.inputLayout) metricsData, STRING destinationFileScope, STRING destinationPrefix) := FUNCTION

        //Fix Locations
        projectedMetrics := PROJECT(metricsData, TRANSFORM(
                                                       metrics.layout,
                                                       locations := Std.Str.SplitWords(LEFT.location, ',');
                                                       SELF.location := IF(COUNT(locations) > 1,locations[1] + '-' + locations[2], LEFT.location);
                                                       SELF.parentLocation := IF(COUNT(locations) > 1,locations[1], LEFT.location);//The 2 is a workaround to overcome optimization
                                                       SELF := LEFT;
                                                        
                                    ));
        

        locationsCatalog := TABLE(DEDUP(SORT(projectedMetrics(period=1), location), location), {STRING50 id:= location, STRING50 title:= location}); 
        defaultLocations := TABLE(TOPN(projectedMetrics(period=1),50,-heatindex), {location});

        metricsByLocation := NORMALIZE(SORT(projectedMetrics,-heatindex),6,TRANSFORM
                                        (
                                            metrics.groupedLayout,
                                            SELF.measure := CASE (COUNTER, 1 => 'cR', 2 => 'mR', 3 => 'sdIndicator', 4 => 'medIndicator', 5 => 'imort' ,6 => 'heatindex' ,''),
                                            SELF.value := CASE (COUNTER, 1 => LEFT.cr, 2 => LEFT.mr, 3 => LEFT.sdIndicator, 4 => LEFT.medIndicator, 5 => LEFT.imort, 6 => LEFT.heatindex,0),
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

formatAllMetrics(metrics.states, metricsScope, 'metrics_states');
formatAllMetrics(metrics.counties, metricsScope, 'metrics_counties');
formatAllMetrics(metrics.world, metricsScope, 'metrics_world');
IMPORT hpccsystems.covid19.file.public.Metrics as metrics;
IMPORT Std;


metricsScope := '~hpccsystems::covid19::file::public::metrics::';


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
                                            SELF.measure := CASE (COUNTER, 6 => 'cR', 5 => 'mR', 4 => 'sdIndicator', 3 => 'medIndicator', 2 => 'imort' ,1 => 'heatindex' ,''),
                                            SELF.value := CASE (COUNTER, 6 => LEFT.cr, 5 => LEFT.mr, 4 => LEFT.sdIndicator, 3 => LEFT.medIndicator, 2 => LEFT.imort, 1 => LEFT.heatindex,0),
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
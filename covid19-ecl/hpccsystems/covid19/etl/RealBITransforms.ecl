
IMPORT hpccsystems.covid19.file.public.LevelMeasures as measures;

IMPORT STD;

realbi  := MODULE
  EXPORT stats := '~hpccsystems::covid19::file::public::realbi::stats.flat';
  EXPORT catalog_countries := '~hpccsystems::covid19::file::public::realbi::catalog_countries.flat';
END;

stats := measures.level1_stats;

latestDate := MAX(stats, date);
leastDate := Std.Date.AdjustDate(latestDate,0,0,-10);

//add ranking column to stats
stats_top := SORT(stats (latestDate = date), -newcases);//should be one record per country
stats_top_temp := TABLE(stats_top, {country, INTEGER rank := 0});

 
country_ranking := ITERATE(stats_top_temp, 
                           TRANSFORM(   
                                    {stats_top_temp},
                                    SELF.rank := LEFT.rank + 1,
                                    SELF.country := RIGHT.country)
                            ); 
OUTPUT(country_ranking);
                            
stats_with_ranking := JOIN(stats, country_ranking, LEFT.country=RIGHT.country);

OUTPUT(stats_with_ranking,,realbi.stats,THOR, COMPRESSED, OVERWRITE);

//catalog of countries
catalog_countries := DEDUP(SORT(TABLE(stats, {country}), country), country);

OUTPUT(catalog_countries,,realbi.catalog_countries,THOR, COMPRESSED, OVERWRITE);


IMPORT hpccsystems.covid19.scrape.Files as Files;

#WORKUNIT('name', 'hpccsystems_covid19_scraped_compare');

global_cpr := ASSERT(JOIN(Files.dailyGlobal,Files.global_update_ds,
                  LEFT.date = ( RIGHT.date - 1),
                  TRANSFORM({RECORDOF(RIGHT), UNSIGNED cumcases,  UNSIGNED cumdeaths, UNSIGNED cdiff, UNSIGNED ddiff},
                            SELF.date := LEFT.date,
                            SELF.cdiff := ABS(LEFT.cumcases - RIGHT.total_cases),
                            SELF.ddiff := ABS(LEFT.cumdeaths - RIGHT.total_deaths),
                            SELF := LEFT,
                            SELF := RIGHT
                  )),
                  cdiff <= 1000 AND ddiff <= 1000,
                  'Warning: Gobal daily cases gap > 1,000 on '+ date) ;
OUTPUT(global_cpr , NAMED('global_daily_compare'));

/*
world_cumConfirmed_cpr := ASSERT(JOIN(Files.dailyGlobal, Files.world_cumconfirmed_ds ,
                              LEFT.date = RIGHT.date, 
                              TRANSFORM({RECORDOF(RIGHT), UNSIGNED cumcases, INTEGER diff},
                              SELF := LEFT, SELF := RIGHT ,
                              SELF.diff := ABS(LEFT.cumcases - RIGHT.confirmed))),
                              diff <= 1000,
                              'Warning: Diff of World Cumulative Cases > 1,000 on '+ date) ;
OUTPUT(SORT(world_cumconfirmed_cpr, -date) , NAMED('world_cumconfirmed_cpr'));

world_newCases_cpr := ASSERT(JOIN(Files.dailyGlobal, Files.world_newCases_ds ,
                                  LEFT.date = RIGHT.date, 
                                  TRANSFORM({RECORDOF(RIGHT), UNSIGNED lnnewcases, INTEGER diff},
                                  SELF.lnnewcases := LEFT.newcases,
                                  SELF.newCases := RIGHT.newcases ,
                                  SELF.diff := ABS(LEFT.newcases - RIGHT.newCases),
                                  SELF := LEFT)),
                                  diff <= 1000,
                                  'Warning: Diff of World New Cases > 1,000 on '+ date) ;
OUTPUT(SORT(world_newCases_cpr, -date) , NAMED('world_newCases_cpr'));
 
country_cumdeaths_cpr      := ASSERT(JOIN(Files.dailyCountries_confirmed, Files.country_cumdeaths_ds,
                                    LEFT.location = RIGHT.country,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.deaths := RIGHT.deaths,
                                    SELF.lncases := LEFT.cumdeaths,
                                    SELF.diff := ABS(LEFT.cumdeaths - RIGHT.deaths),
                                    SELF := RIGHT)),
                                    diff <= 1000,
                                    'Warning: Diff of ' + country +'\'s Cumulative Deaths > 1,000') ;
OUTPUT(SORT(country_cumdeaths_cpr, -diff) , NAMED('country_cumdeaths_cpr'));       

country_cumconfirmed_cpr   := ASSERT(JOIN(Files.dailyCountries_confirmed, Files.country_cumconfirmed_ds,
                                    LEFT.location = RIGHT.country,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.confirmed := RIGHT.confirmed,
                                    SELF.lncases := LEFT.cumcases,
                                    SELF.diff := ABS(LEFT.cumcases - RIGHT.confirmed),
                                    SELF := RIGHT)),                                    
                                    diff <= 1000,
                                    'Warning: Diff of ' + country +'\'s Cumulative Cases > 1,000') ;; 
OUTPUT(SORT(country_cumconfirmed_cpr, -diff) , NAMED('country_cumconfirmed_cpr'));    

state_cumdeaths_cpr        := ASSERT(JOIN(Files.dailyStates_confirmed , Files.state_cumdeaths_ds,
                                    LEFT.location = RIGHT.state,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.deaths := RIGHT.deaths,
                                    SELF.lncases := LEFT.cumdeaths,
                                    SELF.diff := ABS(LEFT.cumdeaths - RIGHT.deaths),
                                    SELF := RIGHT)),                                    
                                    diff <= 500,
                                    'Warning: Diff of ' + State +'\'s Cumulative Deaths > 500') ;;
OUTPUT(SORT(state_cumdeaths_cpr, -diff) , NAMED('state_cumdeaths_cpr') );      


us_cumdeaths_cpr           := JOIN(Files.dailyCountries(location = 'US') , Files.us_cumdeaths_ds,
                                    LEFT.date = RIGHT.date,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.deaths := RIGHT.deaths,
                                    SELF.lncases := LEFT.cumcases,
                                    SELF.diff := ABS(LEFT.cumcases - RIGHT.deaths),
                                    SELF := RIGHT));
// OUTPUT(SORT(us_cumdeaths_cpr, -date) , NAMED('us_cumdeaths_cpr'));   

us_cumconfirmed_cpr        := JOIN(Files.dailyCountries(location = 'US'),Files.us_cumconfirmed_ds,
                                    LEFT.date = RIGHT.date,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.confirmed := RIGHT.confirmed,
                                    SELF.lncases := LEFT.cumcases,
                                    SELF.diff := ABS(LEFT.cumcases - RIGHT.confirmed),
                                    SELF := RIGHT));
// OUTPUT(SORT(us_cumconfirmed_cpr, -date)  , NAMED('us_cumconfirmed_cpr'));    

us_county_cumdeaths_cpr           := JOIN(Files.dailyCounties_confirmed , Files.county_cumdeaths_ds,
                                    LEFT.location = RIGHT.county,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.deaths := RIGHT.deaths,
                                    SELF.lncases := LEFT.cumdeaths,
                                    SELF.diff := ABS(LEFT.cumdeaths - RIGHT.deaths),
                                    SELF := RIGHT), RIGHT ONLY);
// OUTPUT(SORT(us_county_cumdeaths_cpr , -diff)  , NAMED('us_county_cumdeaths_cpr'));   

us_county_cumConfirmed_cpr           := JOIN(Files.dailyCounties_confirmed , Files.county_cumConfirmed_ds,
                                    LEFT.location = RIGHT.county,
                                    TRANSFORM({RECORDOF(RIGHT), UNSIGNED lncases, INTEGER diff},
                                    SELF.confirmed := RIGHT.confirmed,
                                    SELF.lncases := LEFT.cumcases,
                                    SELF.diff := ABS(LEFT.cumcases - RIGHT.confirmed),
                                    SELF := RIGHT), RIGHT ONLY);
// OUTPUT(SORT(us_county_cumConfirmed_cpr, -diff)  , NAMED('us_county_cumConfirmed_cpr') );   
*/

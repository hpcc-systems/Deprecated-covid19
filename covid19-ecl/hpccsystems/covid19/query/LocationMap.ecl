#WORKUNIT('name', 'hpccsystems_covid19_query_location_map');

IMPORT hpccsystems.covid19.file.public.LevelMeasures as measures;
IMPORT STD;

_level := 1:STORED('level'); //1-country , 2-state and 3-county
_level1_location := 'US':STORED('level1_location');
_level2_location := 'GEORGIA':STORED('level2_location');
_level3_location := 'GEORGIA':STORED('level3_location');

latestDate := MAX(measures.level1_stats, date);


MeasuresLayout := RECORD
    STRING location,
    STRING location_code,
    unsigned4 date,
    STRING date_string,
    REAL8 cases,
    REAL8 new_cases,
    REAL8 deaths,
    REAL8 new_deaths,
    REAL8 active,
    REAL8 recovered,
    REAL8 cases_per_capita,
    REAL8 deaths_per_capita,                      
    REAL8 period_new_cases,
    REAL8 period_new_deaths,
    REAL8 period_active,
    REAL8 period_recovered,
    STRING status,
    STRING period_string,
    REAL8 cr,
    REAL8 mr,
    REAL8 R,
    REAL8 sd_indicator,
    REAL8 med_indicator,
    REAL8 cfr,
    REAL8 heat_index,
    REAL8 status_numb,
    REAL8 infection_count,
    REAL8 sti,
    REAL8 ewi,
    REAL8 contagion_risk
END;

MeasuresSummaryLayout := RECORD
    MeasuresLayout,
    STRING commentary
END;


//Summary will be 1 level below the detail
summaryStats := CASE(_level , 1 => measures.level0_stats(date=latestDate), 
                              2 => measures.level1_stats(country=_level1_location and date=latestDate), 
                              3 => measures.level2_stats(country=_level1_location and level2 = _level2_location and date=latestDate),
                              4 => measures.level3_stats(country=_level1_location and level2 = _level2_location and level3 = _level3_location and date=latestDate));
summaryMetrics := CASE(_level , 1 => measures.level0_metrics(period=1), 
                              2 => measures.level1_metrics(country=_level1_location and period=1), 
                              3 => measures.level2_metrics(country=_level1_location and level2 = _level2_location and period=1),
                              4 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and level3 = _level3_location and period=1));

summary := JOIN(summaryStats, summaryMetrics,
          LEFT.location=RIGHT.location,
          TRANSFORM (MeasuresSummaryLayout,
                      SELF.location := LEFT.location,
                      SELF.location_code := LEFT.location,
                      SELF.date := LEFT.date,
                      SELF.date_string := Std.Date.DateToString(LEFT.date , '%B %e, %Y'),
                      SELF.cases := LEFT.cumcases,
                      SELF.new_cases := LEFT.newcases,
                      SELF.deaths := LEFT.cumdeaths,
                      SELF.new_deaths := LEFT.newdeaths,
                      SELF.active := LEFT.active,
                      SELF.recovered := LEFT.recovered,
                      SELF.cases_per_capita := RIGHT.cases_per_capita,
                      SELF.deaths_per_capita := RIGHT.deaths_per_capita,
                      SELF.status := RIGHT.istate,
                      SELF.status_numb := CASE(RIGHT.istate, 
                                        'Initial' => 0, 
                                        'Recovered' => 1, 
                                        'Recovering' => 2,
                                        'Stabilized' => 3,
                                        'Stabilizing' => 4,
                                        'Emerging' => 5,
                                        'Spreading' => 6,
                                        'Regressing' => 7, 0),
                      SELF.period_string := Std.Date.DateToString(RIGHT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(RIGHT.enddate , '%B %e, %Y'),
                      SELF.cr := RIGHT.cr,
                      SELF.mr := RIGHT.mr,
                      SELF.R := RIGHT.R,
                      SELF.sd_indicator := RIGHT.sdIndicator,
                      SELF.med_indicator := RIGHT.medIndicator,
                      SELF.cfr := RIGHT.cfr, 
                      SELF.sti := RIGHT.sti,
                      SELF.ewi := RIGHT.ewi,
                      SELF.contagion_risk := RIGHT.contagionRisk,
                      SELF.heat_index := RIGHT.heatIndex,
                      SELF.infection_count := RIGHT.infectionCount,
                      SELF.period_new_cases := RIGHT.newCases;
                      SELF.period_new_deaths := RIGHT.newDeaths;
                      SELF.period_recovered := RIGHT.recovered;
                      SELF.period_active := RIGHT.active;
                      SELF.commentary := RIGHT.commentary                             
                      ));
OUTPUT(summary,ALL,NAMED('summary'));//This should be exactly one record



listStats := CASE(_level , 1 => measures.level1_stats(date=latestDate), 
                           2 => measures.level2_stats(country=_level1_location and date=latestDate), 
                           3 => measures.level3_stats(country=_level1_location and level2 = _level2_location and date=latestDate),
                           4 => measures.level3_stats(country=_level1_location and level2 = _level2_location and level3 = _level3_location and date=latestDate));
listMetrics := CASE(_level , 1 => measures.level1_metrics(period=1), 
                             2 => measures.level2_metrics(country=_level1_location and period=1), 
                             3 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and period=1),
                             4 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and level3 = _level3_location and period=1));

list := JOIN(listStats, listMetrics,
          LEFT.location=RIGHT.location,
          TRANSFORM (MeasuresLayout,
                      SELF.location := LEFT.location,
                      SELF.location_code := LEFT.fips,
                      SELF.date := LEFT.date,
                      SELF.date_string := Std.Date.DateToString(LEFT.date , '%B %e, %Y'),
                      SELF.cases := LEFT.cumcases,
                      SELF.new_cases := LEFT.newcases,
                      SELF.deaths := LEFT.cumdeaths,
                      SELF.new_deaths := LEFT.newdeaths,
                      SELF.active := LEFT.active,
                      SELF.recovered := LEFT.recovered,
                      SELF.cases_per_capita := RIGHT.cases_per_capita,
                      SELF.deaths_per_capita := RIGHT.deaths_per_capita,
                      SELF.status := RIGHT.istate,
                      SELF.status_numb := CASE(RIGHT.istate, 
                                        'Initial' => 0, 
                                        'Recovered' => 1, 
                                        'Recovering' => 2,
                                        'Stabilized' => 3,
                                        'Stabilizing' => 4,
                                        'Emerging' => 5,
                                        'Spreading' => 6,
                                        'Regressing' => 7, 0),
                      SELF.period_string := Std.Date.DateToString(RIGHT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(RIGHT.enddate , '%B %e, %Y'),
                      SELF.cr := RIGHT.cr,
                      SELF.mr := RIGHT.mr,
                      SELF.R := RIGHT.R,
                      SELF.sd_indicator := RIGHT.sdIndicator,
                      SELF.med_indicator := RIGHT.medIndicator,
                      SELF.cfr := RIGHT.cfr, 
                      SELF.sti := RIGHT.sti,
                      SELF.ewi := RIGHT.ewi,
                      SELF.contagion_risk := RIGHT.contagionRisk,
                      SELF.heat_index := RIGHT.heatIndex,
                      SELF.infection_count := RIGHT.infectionCount,
                      SELF.period_new_cases := RIGHT.newCases;
                      SELF.period_new_deaths := RIGHT.newDeaths;
                      SELF.period_recovered := RIGHT.recovered;
                      SELF.period_active := RIGHT.active;                          
                      ));
OUTPUT(list,ALL,NAMED('list'));//This will be the list of all the locations given a parent location        



maxDs := TABLE(list, {date, 
                      cases_max := MAX(GROUP, cases),
                      new_cases_max := MAX(GROUP, period_new_cases),
                      deaths_max := MAX(GROUP, deaths),
                      new_deaths_max := MAX(GROUP, period_new_deaths),
                      cases_per_capita_max := MAX(GROUP, cases_per_capita),
                      deaths_per_capita_max := MAX(GROUP, deaths_per_capita)
                      }, date);      

OUTPUT(maxDs,ALL,NAMED('max'));        

hotList := TOPN(listMetrics,  10, -heatindex);

OUTPUT(TABLE(hotList, {location, commentary}),,NAMED('hot_list'));  


metricsWeeklyTrend := CASE(_level , 1 => measures.level0_metrics, 
                           2 => measures.level1_metrics(country=_level1_location), 
                           3 => measures.level2_metrics(country=_level1_location and level2 = _level2_location),
                           4 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and level3 = _level3_location));

OUTPUT(TABLE(metricsWeeklyTrend, {STRING period_string := Std.Date.DateToString(startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(enddate , '%B %e, %Y'), 
                                  r, newcases, newdeaths}),,NAMED('metrics_weekly_trend'));                             

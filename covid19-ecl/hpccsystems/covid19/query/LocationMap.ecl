#WORKUNIT('name', 'hpccsystems_covid19_query_location_map');

IMPORT hpccsystems.covid19.file.public.LevelMeasures as measures;
IMPORT STD;

_period := 1:STORED('period');
_level := 1:STORED('level'); //1-country , 2-state and 3-county
_level1_location := 'US':STORED('level1_location');
_level2_location := 'GEORGIA':STORED('level2_location');
_level3_location := 'GEORGIA':STORED('level3_location');

_trendPeriods := 10:STORED('trend_periods');


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
    REAL8 contagion_risk,
    REAL8 immune_pct,
    REAL8 ifr;
    REAL8 vacc_total_dist;
    REAL8 vacc_total_admin;
    REAL8 vacc_total_people;
    REAL8 vacc_people_complete;
    REAL8 vacc_period_dist;
    REAL8 vacc_period_admin;
    REAL8 vacc_period_people;
    REAL8 vacc_period_complete;
    REAL8 vacc_complete_pct;
    REAL8 vacc_admin_pct;
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
summaryMetrics := CASE(_level , 1 => measures.level0_metrics(period=_period), 
                              2 => measures.level1_metrics(country=_level1_location and period=_period), 
                              3 => measures.level2_metrics(country=_level1_location and level2 = _level2_location and period=_period),
                              4 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and level3 = _level3_location and period=_period));

summary := PROJECT(summaryMetrics,
          TRANSFORM (MeasuresSummaryLayout,
                    SELF.location := LEFT.location,
                    SELF.location_code := IF(_level=3,LEFT.fips,LEFT.location),
                    SELF.date := LEFT.enddate,
                    SELF.date_string := Std.Date.DateToString(LEFT.enddate , '%B %e, %Y'),
                    SELF.cases := LEFT.cases,
                    SELF.new_cases := LEFT.newcasesdaily,
                    SELF.deaths := LEFT.deaths,
                    SELF.new_deaths := LEFT.newdeathsdaily,
                    SELF.active := LEFT.active,
                    SELF.recovered := LEFT.recovered,
                    SELF.cases_per_capita := LEFT.cases_per_capita,
                    SELF.deaths_per_capita := LEFT.deaths_per_capita,
                    SELF.status := LEFT.istate,
                    SELF.status_numb := CASE(LEFT.istate, 
                                    'Initial' => 0, 
                                    'Recovered' => 1, 
                                    'Recovering' => 2,
                                    'Stabilized' => 3,
                                    'Stabilizing' => 4,
                                    'Emerging' => 5,
                                    'Spreading' => 6,
                                    'Regressing' => 7, 0),
                    SELF.period_string := Std.Date.DateToString(LEFT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(LEFT.enddate , '%B %e, %Y'),
                    SELF.cr := LEFT.cr,
                    SELF.mr := LEFT.mr,
                    SELF.R := LEFT.R,
                    SELF.sd_indicator := LEFT.sdIndicator,
                    SELF.med_indicator := LEFT.medIndicator,
                    SELF.cfr := LEFT.cfr, 
                    SELF.sti := LEFT.sti,
                    SELF.ewi := LEFT.ewi,
                    SELF.immune_pct := LEFT.immunePct,
                    SELF.ifr := LEFT.ifr,
                    SELF.contagion_risk := LEFT.contagionRisk,
                    SELF.heat_index := LEFT.heatIndex,
                    SELF.infection_count := LEFT.infectionCount,
                    SELF.period_new_cases := LEFT.newCases;
                    SELF.period_new_deaths := LEFT.newDeaths;
                    SELF.period_recovered := LEFT.recovered;
                    SELF.period_active := LEFT.active;  
                    SELF.commentary := LEFT.commentary;
                    SELF.vacc_total_dist := LEFT.vacc_total_dist; 
                    SELF.vacc_total_admin := LEFT.vacc_total_admin; 
                    SELF.vacc_total_people :=LEFT.vacc_total_people; 
                    SELF.vacc_people_complete := LEFT.vacc_people_complete; 
                    SELF.vacc_period_dist := LEFT.vacc_period_dist; 
                    SELF.vacc_period_admin := LEFT.vacc_period_admin; 
                    SELF.vacc_period_people := LEFT.vacc_period_people; 
                    SELF.vacc_period_complete := LEFT.vacc_period_complete; 
                    SELF.vacc_complete_pct := LEFT.vacc_complete_pct; 
                    SELF.vacc_admin_pct := LEFT.vacc_admin_pct;                           
                      ));
OUTPUT(summary,ALL,NAMED('summary'));//This should be exactly one record


listStats := CASE(_level , 1 => measures.level1_stats(date=latestDate), 
                           2 => measures.level2_stats(country=_level1_location and date=latestDate), 
                           3 => measures.level3_stats(country=_level1_location and level2 = _level2_location and date=latestDate),
                           DATASET([], RECORDOF(measures.level3_stats)));
listMetrics := CASE(_level , 1 => measures.level1_metrics(period=_period), 
                             2 => measures.level2_metrics(country=_level1_location and period=_period), 
                             3 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and period=_period), 
                             DATASET([], RECORDOF(measures.level3_metrics)));

list := PROJECT(listMetrics,

          TRANSFORM (MeasuresLayout,
                    SELF.location := LEFT.location,
                    SELF.location_code := IF(_level=3,LEFT.fips,LEFT.location),
                    SELF.date := LEFT.enddate,
                    SELF.date_string := Std.Date.DateToString(LEFT.enddate , '%B %e, %Y'),
                    SELF.cases := LEFT.cases,
                    SELF.new_cases := LEFT.newcasesdaily,
                    SELF.deaths := LEFT.deaths,
                    SELF.new_deaths := LEFT.newdeathsdaily,
                    SELF.active := LEFT.active,
                    SELF.recovered := LEFT.recovered,
                    SELF.cases_per_capita := LEFT.cases_per_capita,
                    SELF.deaths_per_capita := LEFT.deaths_per_capita,
                    SELF.status := LEFT.istate,
                    SELF.status_numb := CASE(LEFT.istate, 
                                    'Initial' => 0, 
                                    'Recovered' => 1, 
                                    'Recovering' => 2,
                                    'Stabilized' => 3,
                                    'Stabilizing' => 4,
                                    'Emerging' => 5,
                                    'Spreading' => 6,
                                    'Regressing' => 7, 0),
                    SELF.period_string := Std.Date.DateToString(LEFT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(LEFT.enddate , '%B %e, %Y'),
                    SELF.cr := LEFT.cr,
                    SELF.mr := LEFT.mr,
                    SELF.R := LEFT.R,
                    SELF.sd_indicator := LEFT.sdIndicator,
                    SELF.med_indicator := LEFT.medIndicator,
                    SELF.cfr := LEFT.cfr, 
                    SELF.sti := LEFT.sti,
                    SELF.ewi := LEFT.ewi,
                    SELF.immune_pct := LEFT.immunePct,
                    SELF.ifr := LEFT.ifr,
                    SELF.contagion_risk := LEFT.contagionRisk,
                    SELF.heat_index := LEFT.heatIndex,
                    SELF.infection_count := LEFT.infectionCount,
                    SELF.period_new_cases := LEFT.newCases;
                    SELF.period_new_deaths := LEFT.newDeaths;
                    SELF.period_recovered := LEFT.recovered;
                    SELF.period_active := LEFT.active;    
                    SELF.vacc_total_dist := LEFT.vacc_total_dist; 
                    SELF.vacc_total_admin := LEFT.vacc_total_admin; 
                    SELF.vacc_total_people :=LEFT.vacc_total_people; 
                    SELF.vacc_people_complete := LEFT.vacc_people_complete; 
                    SELF.vacc_period_dist := LEFT.vacc_period_dist; 
                    SELF.vacc_period_admin := LEFT.vacc_period_admin; 
                    SELF.vacc_period_people := LEFT.vacc_period_people; 
                    SELF.vacc_period_complete := LEFT.vacc_period_complete; 
                    SELF.vacc_complete_pct := LEFT.vacc_complete_pct; 
                    SELF.vacc_admin_pct := LEFT.vacc_admin_pct;                        
                      ));
OUTPUT(list,ALL,NAMED('list'));//This will be the list of all the locations given a parent location        



maxDs := TABLE(list, {date, 
                      cases_max := MAX(GROUP, cases),
                      new_cases_max := MAX(GROUP, period_new_cases),
                      deaths_max := MAX(GROUP, deaths),
                      new_deaths_max := MAX(GROUP, period_new_deaths),
                      cases_per_capita_max := MAX(GROUP, cases_per_capita),
                      deaths_per_capita_max := MAX(GROUP, deaths_per_capita),
                      vacc_distributed_max := MAX(GROUP, vacc_total_dist),
                      }, date);      

OUTPUT(maxDs,ALL,NAMED('max'));        

//hotList := TOPN(listMetrics,  10, -heatindex);
hotList := listMetrics( heatindex >= 1);

OUTPUT(TABLE(SORT(hotList, -heatindex), {location, commentary}),,NAMED('hot_list'));  


periodTrend := CASE(_level , 1 => measures.level0_metrics (period >= _period), 
                           2 => measures.level1_metrics(period >= _period and country=_level1_location), 
                           3 => measures.level2_metrics(period >= _period and country=_level1_location and level2 = _level2_location),
                           4 => measures.level3_metrics(period >= _period and country=_level1_location and level2 = _level2_location and level3 = _level3_location));

periodTrendSelect := SORT(CHOOSEN(periodTrend, _trendPeriods),-period);
OUTPUT(TABLE(periodTrendSelect, {STRING period_string := Std.Date.DateToString(enddate , '%b %e'), 
                                  r, REAL8 new_cases := newcases, REAL8 new_deaths := newdeaths}),,NAMED('period_trend_column'));       


periodTrendGrouped := NORMALIZE(periodTrendSelect, 2, TRANSFORM (
      {STRING period_string,
       STRING measure,
       REAL value},
       SELF.period_string := Std.Date.DateToString(LEFT.enddate , '%b %e'),
       SELF.measure := CASE (COUNTER, 1 => 'New Cases', 2 => 'New Deaths', 'Unknown'),
       SELF.value := CASE (COUNTER, 1 => LEFT.newcases, 2 => LEFT.newdeaths, 0)
));

OUTPUT(periodTrendGrouped,ALL,NAMED('period_trend_grouped'));

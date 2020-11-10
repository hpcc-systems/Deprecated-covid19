#WORKUNIT('name', 'hpccsystems_covid19_query_range_map');

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
    REAL8 period_new_cases,
    REAL8 period_new_deaths,
    REAL8 period_active,
    REAL8 period_recovered,
    STRING status,
    UNSIGNED period,
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
    REAL8 contagion_risk,
    REAL8 cases_per_capita,
    REAL8 deaths_per_capita,
    REAL8 cases,
    REAL8 deaths,
    REAL8 immune_pct,
    REAL8 ifr;
    REAL8 ewi
END;

summaryMetrics := CASE(_level , 1 => measures.level0_metrics, 
                              2 => measures.level1_metrics(country=_level1_location ), 
                              3 => measures.level2_metrics(country=_level1_location and level2 = _level2_location),
                              4 => measures.level3_metrics(country=_level1_location and level2 = _level2_location and level3 = _level3_location));


metrics := CASE(_level , 1 => measures.level1_metrics, 
                             2 => measures.level2_metrics(country=_level1_location), 
                             3 => measures.level3_metrics(country=_level1_location and level2 = _level2_location), 
                             DATASET([], RECORDOF(measures.level3_metrics)));

rangeMetrics := PROJECT(metrics (endDate > 20200318),          
                            TRANSFORM (MeasuresLayout,
                                        SELF.period := LEFT.period,                    
                                        SELF.period_string := Std.Date.DateToString(LEFT.startdate , '%B %e, %Y') + ' - ' + Std.Date.DateToString(LEFT.enddate , '%B %e, %Y'),
                                        SELF.location := LEFT.location,
                                        SELF.location_code := IF(_level=3,LEFT.fips,LEFT.location),
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
                                        SELF.cases_per_capita := LEFT.cases_per_capita;
                                        SELF.deaths_per_capita := LEFT.deaths_per_capita;
                                        SELF.cases := LEFT.cases;
                                        SELF.deaths := LEFT.deaths;                       
                                        ));

OUTPUT(SORT(rangeMetrics, -period, location),ALL,NAMED('metrics')); 

OUTPUT(SORT(TABLE(summaryMetrics, {period,commentary}), -period),ALL,NAMED('summary'));




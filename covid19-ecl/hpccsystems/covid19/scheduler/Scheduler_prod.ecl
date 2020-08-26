IMPORT Std;
IMPORT $.Utils.KafkaUtils AS KUtils;
IMPORT $.Utils.SOAPUtils AS SUtils;

//ActionType: RUN: Run Thor Job; PUBLISH: Publish Roxie Query
RunOrPublishByName(STRING wuJobName, STRING ActionType = 'PUBLISH') := FUNCTION
    ast := ASSERT(ActionType = 'RUN' OR ActionType = 'PUBLISH', 'WARNING: ActionType not exists', FAIL);
    
    runResults := SUtils.RunCompiledWorkunitByName
        (
            wuJobName,
            waitForCompletion := TRUE,
            username := SUtils.username,
            userPW := SUtils.userPW
        );
    
    publishResults := SUtils.PublishCompiledWorkunitByName
        (
            wuJobName,
            username := SUtils.username,
            userPW := SUtils.userPW
        );
    wuid := IF(ActionType = 'RUN', runResults[1].wuid, publishResults[1].wuid);
    // Logging
    logStartAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': running ' + wuJobName);
    // logEndAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': success: ' + IF(wuid <> '', 'true', 'false'));
    // Kafka message
    guid :=  DATASET('~covid19::kafka::guid', {STRING s}, FLAT)[1].s;
    sendMsg := KUtils.sendMsg(wuid := wuid,instanceid := guid, msg := 'Prod Cluster: sending message with instanceid ' + guid );   
    RETURN SEQUENTIAL(ast, logStartAction, sendMsg);
    // RETURN SEQUENTIAL(ast, logStartAction, logEndAction);

END;



thingsToDo := ORDERED

    (
        KUtils.genInstanceID;
        RunOrPublishByName('hpccsystems_covid19_removeQueryFiles' , 'RUN');
        RunOrPublishByName('hpccsystems_covid19_spray' , 'RUN');
        RunOrPublishByName('JohnHopkinsClean' , 'RUN');
        RunOrPublishByName('CountiesFIPSClean' , 'RUN');
        RunOrPublishByName('global_metrics', 'RUN');
        RunOrPublishByName('metrics_by_country', 'RUN');
        RunOrPublishByName('metrics_by_us_states', 'RUN');
        RunOrPublishByName('metrics_by_us_county', 'RUN');
        RunOrPublishByName('FormatWeeklyMetrics', 'RUN');
        RunOrPublishByName('hpccsystems_covid19_query_counties_map');
        RunOrPublishByName('hpccsystems_covid19_query_countries_map');
        RunOrPublishByName('hpccsystems_covid19_query_daily_metrics');
        RunOrPublishByName('hpccsystems_covid19_query_metrics_catalog');
        RunOrPublishByName('hpccsystems_covid19_query_metrics_grouped');
        RunOrPublishByName('hpccsystems_covid19_query_metrics_period');
        RunOrPublishByName('hpccsystems_covid19_query_states_map');
        RunOrPublishByName('hpccsystems_covid19_query_location_metrics'); 
        // RunOrPublishByName('hpccsystems_covid19_scraped_spray' , 'RUN');
        // RunOrPublishByName('hpccsystems_covid19_scraped_Compare' , 'RUN');
             
    );

thingsToDo : WHEN(CRON('45 8,23 * * *'));
// thingsToDo;
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
    wuid := IF(wuJobName = 'scheduler', WORKUNIT, IF(ActionType = 'RUN', runResults[1].wuid, publishResults[1].wuid));
    // Logging
    logStartAction := Std.System.Log.AddWorkunitInformation(Std.Date.SecondsToString(Std.Date.CurrentSeconds()) + ': running ' + wuJobName);
    // Kafka message
    guid :=  DATASET('~covid19::kafka::guid', {STRING s}, FLAT)[1].s;
    sendMsg := KUtils.sendMsg(broker := kutils.prod_defaultbroker, appid := kutils.prod_applicationId, wuid := wuid, dataflowid := kutils.prod_DataflowId_v2, instanceid := guid, msg := 'Prod Cluster: Sending message with instanceid ' + guid );   
    RETURN SEQUENTIAL(ast, logStartAction, sendMsg);

END;


thingsToDo := 
ORDERED
// SEQUENTIAL
    (

    //   PARALLEL(
        KUtils.genInstanceID;
        RunOrPublishByName('scheduler' , 'RUN');
        // KUtils.sendMsg(broker := kutils.prod_defaultbroker, appid := kutils.prod_applicationId, wuid := WORKUNIT, dataflowid := kutils.prod_DataflowId_v2, instanceid := guid, msg := 'Prod Cluster: Scheduler sending message with instanceid ' + guid );   
        RunOrPublishByName('hpccsystems_covid19_spray' , 'RUN');
        RunOrPublishByName('hpccsystems_covid19_removeQueryFiles_v2' , 'RUN');
        // );

        RunOrPublishByName('JohnHopkinsClean' , 'RUN');
        RunOrPublishByName('Ingest_JH_data', 'RUN');
        RunOrPublishByName('Produce_Daily_Stats', 'RUN');
        RunOrPublishByName('Produce_Weekly_Metrics', 'RUN');
        RunOrPublishByName('hpccsystems_covid19_query_location_map'); 
        RunOrPublishByName('hpccsystems_covid19_query_range_map');               
    );
// thingsToDo : WHEN(CRON('30 0-23/6 * * *'));
// thingsToDo : WHEN(CRON('30 7,10 * * *'));
thingsToDo;
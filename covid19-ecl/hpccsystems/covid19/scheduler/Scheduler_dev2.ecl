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
    //wuid W002
    sendMsg := KUtils.sendMsg(wuid := wuid, dataflowid := kutils.DataflowId_v2, instanceid := guid, msg := 'Test Cluster: Sending message with instanceid ' + guid );   
    RETURN SEQUENTIAL(ast, logStartAction, sendMsg);
END;

thingsToDo := ORDERED

    (
        KUtils.genInstanceID;   
        RunOrPublishByName('scheduler' , 'RUN');
        // KUtils.sendMsg(wuid := WORKUNIT, dataflowid := kutils.DataflowId_v2, instanceid :=DATASET('~covid19::kafka::guid', {STRING s}, FLAT)[1].s, msg := 'Test Cluster: Scheduler sending message' );   
        RunOrPublishByName('hpccsystems_covid19_spray' , 'RUN');
        RunOrPublishByName('JohnHopkinsClean' , 'RUN');
        RunOrPublishByName('Ingest_JH_data', 'RUN');
        RunOrPublishByName('Produce_Daily_Stats', 'RUN');
        RunOrPublishByName('Produce_Weekly_Metrics', 'RUN');       
        RunOrPublishByName('hpccsystems_covid19_query_location_map');     
        RunOrPublishByName('hpccsystems_covid19_query_range_map');   
    );

// thingsToDo : WHEN(CRON('30 0-23/6 * * *'));
thingsToDo;
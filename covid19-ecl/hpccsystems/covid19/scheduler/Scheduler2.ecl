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
    // Kafka message
    guid :=  DATASET('~covid19::kafka::guid', {STRING s}, FLAT)[1].s;
    sendMsg := KUtils.sendMsg(wuid := wuid,instanceid := guid, msg := 'Sending message with instanceid ' + guid );   
    // RETURN SEQUENTIAL(ast, logStartAction, sendMsg);
    RETURN SEQUENTIAL(ast, logStartAction);

END;

thingsToDo := ORDERED

    (
        // KUtils.genInstanceID;
        RunOrPublishByName('hpccsystems_covid19_spray' , 'RUN');
        RunOrPublishByName('JohnHopkinsClean' , 'RUN');
        RunOrPublishByName('Ingest_JH_data', 'RUN');
        RunOrPublishByName('Produce_Daily_Stats', 'RUN');
        RunOrPublishByName('Produce_Weekly_Metrics', 'RUN');            
    );

// thingsToDo : WHEN(CRON('59 0-23/5 * * *'));
thingsToDo;
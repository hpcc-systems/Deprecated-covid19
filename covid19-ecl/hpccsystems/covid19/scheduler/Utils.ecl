IMPORT Std;
IMPORT Kafka;


EXPORT Utils := MODULE
  /**
  * Module containing code for executing a compiled workunit by name.
  * The execution action can be either RUN on THOR cluster or PUBLISH
  * on Roxie cluster.
  * Acknowledgement: 
  * Origin of most part of SOAPUtils Module is form Dan Camper's work
  * https://github.com/dcamper/Useful_ECL
  */
  EXPORT SOAPUtils  := MODULE

      EXPORT username := '';
      EXPORT userPW := '';
      SHARED CreateAuthHeaderValue(STRING username, STRING userPW) := IF
          (
              TRIM(username, ALL) != '',
              'Basic ' + Std.Str.EncodeBase64((DATA)(TRIM(username, ALL) + ':' + TRIM(userPW, LEFT, RIGHT))),
              ''
          );

      SHARED CreateESPURL(STRING explicitURL) := FUNCTION
          trimmedURL := TRIM(explicitURL, ALL);
          myESPURL := IF(trimmedURL != '', trimmedURL, Std.File.GetEspURL()) + '/WsWorkunits/ver_=1.74';

          RETURN myESPURL;
      END;

      EXPORT RunArgLayout := RECORD
          STRING      name    {XPATH('Name')};
          STRING      value   {XPATH('Value')};
      END;

      EXPORT RunResultsLayout := RECORD
          STRING  wuid    {XPATH('Wuid')};
          STRING  state   {XPATH('State')};
          STRING  results {XPATH('Results')};
      END;

      EXPORT PublishResultsLayout := RECORD
          STRING  wuid    {XPATH('Wuid')};
          STRING  results {XPATH('results')};
          STRING  QuerySet {XPATH('QuerySet')};
          STRING  QueryName {XPATH('QueryName')};
          STRING  QueryId {XPATH('QueryId')};
      END;

      EXPORT RunCompiledWorkunitByName(STRING jobName,
                                      STRING espURL = '',
                                      DATASET(RunArgLayout) runArguments = DATASET([], RunArgLayout),
                                      BOOLEAN waitForCompletion = FALSE,
                                      STRING username = '',
                                      STRING userPW = '',
                                      UNSIGNED2 timeoutInSeconds = 0) := FUNCTION
          myESPURL := CreateESPURL(espURL);
          auth := CreateAuthHeaderValue(username, userPW);

          QueryResultsLayout := RECORD
              STRING  rWUID       {XPATH('Wuid')};
              STRING  rCluster    {XPATH('Cluster')};
          END;

          // Find the latest compiled version of a workunit that matches the
          // given jobName
          queryResults := SOAPCALL
              (
                  myESPURL,
                  'WUQuery',
                  {
                      STRING pJobname {XPATH('Jobname')} := jobName;
                      STRING pState {XPATH('State')} := 'compiled';                    
                  },
                  DATASET(QueryResultsLayout),
                  XPATH('WUQueryResponse/Workunits/ECLWorkunit'),
                  HTTPHEADER('Authorization', auth),
                  TIMEOUT(60), ONFAIL(SKIP)
              );
          latestWUID := TOPN(queryResults, 1, -rWUID)[1];

          // Call the found workunit with the arguments provided
          runResults := SOAPCALL
              (
                  myESPURL,
                  'WURun',
                  {
                      STRING pWUID {XPATH('Wuid')} := latestWUID.rWUID;
                      STRING pCluster {XPATH('Cluster')} := latestWUID.rCluster;
                      STRING pWait {XPATH('Wait')} := IF(waitForCompletion, '-1', '0');
                      STRING pCloneWorkunit {XPATH('CloneWorkunit')} := '1';
                      DATASET(RunArgLayout) pRunArgs {XPATH('Variables/NamedValue')} := runArguments;
                  },
                  DATASET(RunResultsLayout),
                  XPATH('WURunResponse'),
                  HTTPHEADER('Authorization', auth),
                  TIMEOUT(timeoutInSeconds), ONFAIL(SKIP)
              );

          RETURN IF(EXISTS(queryResults), runResults, DATASET([], RunResultsLayout));
      END;

      EXPORT publishCompiledWorkunitByName(STRING jobName,
                                      STRING espURL = '',
                                      STRING username = '',
                                      STRING userPW = '') := FUNCTION
          myESPURL := CreateESPURL(espURL);
          auth := CreateAuthHeaderValue(username, userPW);

          QueryResultsLayout := RECORD
              STRING  rWUID       {XPATH('Wuid')};
              STRING  rCluster    {XPATH('Cluster')};
          END;

          // Find the latest compiled version of a workunit that matches the
          // given jobName
          queryResults := SOAPCALL
              (
                  Std.File.GetEspURL() + '/WsWorkunits/',
                  'WUQuery',
                  {
                      STRING pJobname {XPATH('Jobname')} := jobName;
                      STRING pState {XPATH('State')} := 'compiled';
                      STRING pCluster {XPATH('Cluster')} := 'roxie';
                  },
                  DATASET(QueryResultsLayout),
                  XPATH('WUQueryResponse/Workunits/ECLWorkunit'),
                  HTTPHEADER('Authorization', auth),
                  TIMEOUT(60), ONFAIL(SKIP)
              );

          
          latestWUID := TOPN(queryResults, 1, -rWUID)[1];

          // Publish the found workunit
          publishResults := SOAPCALL
              (
                  Std.File.GetEspURL() + '/WsWorkunits/',
                  'WUPublishWorkunit',
                  {
                      STRING      targetCluster               {XPATH('Cluster')} := 'roxie';
                      STRING      jobname                     {XPATH('JobName')} := jobName;
                      STRING      WUID                        {XPATH('Wuid')} := latestWUID.rWUID;
                      UNSIGNED4   activate                    {XPATH('Activate')} := 1;
                  },
                  DATASET(PublishResultsLayout),
                  XPATH('WUPublishWorkunitResponse'),
                  HTTPHEADER('Authorization', auth)
              );

          RETURN IF(EXISTS(queryResults), publishResults, DATASET([], PublishResultsLayout));
      END;
  
      EXPORT removeFiles(INTEGER ver = 1) := FUNCTION
        files_list := STD.File.LogicalFileList( );
        Filenames0 := files_list( STD.STR.FIND(cluster, 'myroxie') <> 0);
        Filenames := IF(ver = 1, Filenames0( REGEXFIND( 'level', name) = FALSE), Filenames0( REGEXFIND( 'level', name) = TRUE));
        RETURN APPLY(Filenames,STD.FILE.DeleteLogicalFile('~'+Filenames.name));
    END;
    

     EXPORT deleteQueries( STRING espURL = '',
                            STRING username = '',
                            STRING userPW = '',
                            INTEGER ver = 1) := FUNCTION

        ver2Queries := ['hpccsystems_covid19_query_location_map'];
        myESPURL := CreateESPURL(espURL);
        auth := CreateAuthHeaderValue(username, userPW);

        QueryResultLayout := RECORD
            STRING  rWUID       {XPATH('Wuid')};
            STRING  rID         {XPATH('Id')};
            STRING  rNAME       {XPATH('Name')};
        END;

        queryResults := SOAPCALL
            (
                myESPURL,
                'WUListQueries',
                {
                    STRING Activated {XPATH('Activated')} := '1';                 
                },
                DATASET(QueryResultLayout),
                XPATH('WUListQueriesResponse/QuerysetQueries/QuerySetQuery'),
                HTTPHEADER('Authorization', auth),
                TIMEOUT(60), ONFAIL(SKIP)
            );

        deleteResultLayout := RECORD
            STRING  rQueryId       {XPATH('QueryId')};
            STRING  rSuspended     {XPATH('Suspended')};
            STRING  rSuccess       {XPATH('Success')};
            STRING  rCode          {XPATH('Code')};
            STRING  rMessage       {XPATH('Message')};
        END;


        ActionLayout := RECORD
            STRING rQueryID {XPATH('QueryId')};
            // STRING rSuspended {XPATH('ClientState/Suspended')};
        END;

        queries2Delete0 := PROJECT(queryResults, TRANSFORM({ActionLayout, STRING queryName} , SELF.rQueryID := LEFT.rID, SELF.Queryname := STD.Str.SplitWords(LEFT.rID, '.')[1]));
        queries2Delete1 := IF(ver = 1,queries2Delete0(queryName NOT IN ver2Queries), queries2Delete0(queryName IN ver2Queries ));
        queries2Delete := PROJECT(queries2Delete1 , TRANSFORM(ActionLayout , SELF:= LEFT));

        deleteResults := SOAPCALL
            (
                myESPURL,
                'WUQuerysetQueryAction',
                {
                    STRING pAction {XPATH('Action')} := 'Delete';
                    STRING pQuerySetName {XPATH('QuerySetName')} := 'roxie';
                    DATASET(ActionLayout) pNames {XPATH('Queries/Query')} := queries2delete;
                },
                DATASET(deleteResultLayout),
                XPATH('WUQuerysetActionResponse/Results/Result'),
                HTTPHEADER('Authorization', auth),
                TIMEOUT(60), ONFAIL(SKIP)
            );
        RETURN deleteResults;
    END;
  END;



  EXPORT KafkaUtils := MODULE

      EXPORT guidFilePath := '~covid19::kafka::guid';
      EXPORT defaultGUID :=  DATASET(guidFilePath, {STRING s}, FLAT)[1].s;
      EXPORT defaultTopic := 'Dataflow';

// Test workflows
      EXPORT applicationId:= '029d69e4-4a24-439a-a1da-42dfc9575eab';
      EXPORT DataflowId_v2 := '6e8ed8f9-ab3b-42e4-bec5-b2c5208f2f80';
      EXPORT DataflowId_v1 := 'dfd51c4b-90b1-4ee8-af72-01b56173f002';
      EXPORT defaultBroker := '10.0.0.4:19092';

// Prod workflows

      EXPORT prod_applicationId:= '826df5ad-5b10-4484-9f5e-0879166d7944';
      EXPORT prod_DataflowId_v2 := 'd7db10f0-2b36-4507-811e-b8d2267ead70';
      EXPORT prod_DataflowId_v1 := 'c4485927-67ce-4439-9263-44fd07bc3285';
      EXPORT prod_defaultBroker := '18.224.242.220:9092';


      EXPORT l_json := RECORD
        STRING applicationid;
        STRING dataflowId;
        STRING wuid;
        STRING instanceId;
        STRING msg;
      END;

      EXPORT genInstanceID := FUNCTION
          guid := STD.Date.Today() + '' + STD.Date.CurrentTime(True);
          guidDS := DATASET(ROW({guid}, {STRING s}));
          RETURN OUTPUT( guidDS, , guidFilePath, OVERWRITE);
      END;

      EXPORT sendMsg(
                    STRING broker = defaultBroker,
                    STRING topic = defaultTopic,
                    STRING appID = applicationId,
                    STRING dataflowid = Dataflowid_v1,
                    STRING wuid = WORKUNIT,
                    STRING instanceid = defaultGUID,
                    STRING msg = '') := FUNCTION


      j :=  '{' + TOJSON(ROW({appID, dataflowId, wuid, instanceid, msg},l_json)) + '}';
      kafkaMsg := DATASET([{j}], {STRING line});

      p := kafka.KafkaPublisher( topic, broker );
      sending := p.PublishMessage(kafkaMsg[1].line);
      o := OUTPUT(kafkaMsg );

      RETURN WHEN(sending,o);
    END;

  END;
END;
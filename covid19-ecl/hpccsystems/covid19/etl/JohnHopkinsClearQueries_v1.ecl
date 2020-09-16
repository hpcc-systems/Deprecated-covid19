IMPORT $.^.scheduler.Utils.SOAPUtils AS SUtils;

#WORKUNIT('name', 'hpccsystems_covid19_removeQueryFiles_v1');
//Remove all roxie related files
step1 := SUtils.deleteQueries(ver := 1);
step2 := SUtils.removeFiles(ver := 1);

SEQUENTIAL(EVALUATE(step1),
           step2);

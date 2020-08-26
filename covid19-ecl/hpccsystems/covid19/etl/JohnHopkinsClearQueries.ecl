IMPORT $.^.scheduler.Utils.SOAPUtils AS SUtils;

#WORKUNIT('name', 'hpccsystems_covid19_removeQueryFiles');
//Remove all roxie related files
step1 := SUtils.deleteQueries();
step2 := SUtils.removeFiles();

SEQUENTIAL(EVALUATE(step1),
           step2);

IMPORT $.^.scheduler.Utils.SOAPUtils AS SUtils;

#WORKUNIT('name', 'hpccsystems_covid19_removeQueryFiles_v2');
//Remove all roxie related files
step1 := SUtils.deleteQueries( ver := 2);
step2 := SUtils.removeFiles( ver := 2);

SEQUENTIAL(EVALUATE(step1),
           step2);

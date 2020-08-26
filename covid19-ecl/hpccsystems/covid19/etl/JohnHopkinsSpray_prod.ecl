IMPORT STD;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV1 as jhv1;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV2 as jhv2;
IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 

#WORKUNIT('name', 'hpccsystems_covid19_spray');
#WORKUNIT('protect', TRUE);

// Define attributes for spray
today := STD.Date.Today();
yesterday :=  today -1;
tempSuperFileName := '~hpccsystems::covid19::file::raw::JohnHopkins::V2::temp';
lzip:= '172.31.42.168';
srcPath := '/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/JohnHopkins/V2/';
scopeName := '~hpccsystems::covid19::file::raw::JohnHopkins::V2::';
l_incoming := RECORD
    STRING name;
    STRING logicalPath;
    UNSIGNED4 newdate;
    UNSIGNED4 modified;
END;


// Remove Previously created SuperFiles
Step0 := IF(STD.File.SuperFileExists(tempSuperFileName),STD.File.DeleteSuperFile(tempSuperFileName));

// Read today's new files on Landing Zone 
incomingDS := STD.File.RemoteDirectory( lzip,  SrcPath, '*.csv');
incomingFiles := PROJECT(incomingDS, 
                                TRANSFORM( l_incoming,
                                          SELF.logicalPath :=  scopeName + LEFT.name,
                                          SELF.newdate := Std.Date.FromStringToDate(
                                                                        LEFT.name[1..10],
                                                                        '%m-%d-%Y'),
                                          SELF.modified := Std.Date.FromStringToDate(
                                                                        LEFT.modified[1..10],
                                                                        '%Y-%m-%d'),
                                          SELF := LEFT));
newFiles := incomingFiles(modified = today OR modified = yesterday);


//Spray incoming files
sprayfiles := NOTHOR(APPLY(newFiles,  
                            STD.File.SprayDelimited
                            (
                                lzIP,
                                SrcPath+ name,
                                destinationGroup := 'mythor',
                                destinationLogicalName :=logicalPath,
                                allowOverwrite := TRUE,
                                recordStructurePresent := TRUE
                            )));
step1 := SprayFiles;
// Record execution data and time
step2 := OUTPUT( STD.Date.Today() + ' ' +  STD.Date.CurrentTime(True), NAMED('DateTime'));
// Check all the incoming files
step3 := OUTPUT(newFiles, NAMED('newFiles'));


// Excute step by step 
ACTIONS := IF(EXISTS(newFiles),
            SEQUENTIAL(
                        STEP0,
                        STEP1,
                        STEP2,
                        step3
                      ),
            OUTPUT('No Incoming Files'));

ACTIONS;
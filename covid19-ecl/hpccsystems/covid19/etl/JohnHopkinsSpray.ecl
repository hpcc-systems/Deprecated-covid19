IMPORT STD;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV1 as jhv1;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV2 as jhv2;
IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 

#WORKUNIT('name', 'hpccsystems_covid19_spray');
#WORKUNIT('protect', TRUE);

// Define attributes for spray
today := STD.Date.Today();
yesterday :=  STD.Date.AdjustDate(today, 0, 0, -1);
tempSuperFileName := '~hpccsystems::covid19::file::raw::JohnHopkins::V2::temp';
lzip:= '10.0.0.4';

srcPath_JH := '/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/JohnHopkins/V2/';
scopeName_JH := '~hpccsystems::covid19::file::raw::JohnHopkins::V2::';

srcPath_OWID := '/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/';
scopeName_OWID := '~hpccsystems::covid19::file::raw::owid::v2::';


l_incoming := RECORD
    STRING name;
    STRING LZPath;
    STRING logicalPath;
    UNSIGNED4 newdate;
    UNSIGNED4 modified;
END;


// Remove Previously created SuperFiles
Step0 := IF(STD.File.SuperFileExists(tempSuperFileName),STD.File.DeleteSuperFile(tempSuperFileName));

// Read today's new files on Landing Zone 
incomingJH := STD.File.RemoteDirectory( lzip,  SrcPath_JH, '*.csv');
// OUTPUT(incomingjh);

incomingOWID := STD.FILE.RemoteDirectory(lzip, SrcPath_OWID, '*vaccinations.csv');
// OUTPUT(incomingowid);




incomingFiles_JH := PROJECT(incomingJH, 
                                TRANSFORM( l_incoming,
                                          SELF.lzPath := SrcPath_JH+ LEFT.name,
                                          SELF.logicalPath :=  scopeName_JH + LEFT.name,
                                          SELF.newdate := Std.Date.FromStringToDate(
                                                                        LEFT.name[1..10],
                                                                        '%m-%d-%Y'),
                                          SELF.modified := Std.Date.FromStringToDate(
                                                                        LEFT.modified[1..10],
                                                                        '%Y-%m-%d'),
                                          SELF := LEFT));

incomingFiles_OWID := PROJECT(incomingOWID, 
                                TRANSFORM( l_incoming,
                                          SELF.lzPath := SrcPath_OWID+ LEFT.name,
                                          SELF.logicalPath :=  scopeName_OWID + LEFT.name,
                                          SELF.modified := Std.Date.FromStringToDate(
                                                                        LEFT.modified[1..10],
                                                                        '%Y-%m-%d'),
                                          SELF.newdate := SELF.modified,
                                          SELF := LEFT));

incomingFiles := incomingFiles_JH + incomingFiles_OWID;                                         
newFiles := incomingFiles(modified = today OR modified = yesterday);
// newFiles;

//Spray incoming files
sprayfiles := NOTHOR(APPLY(newFiles,  
                            STD.File.SprayDelimited
                            (
                                lzIP,
                                lzPath,
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
            ASSERT(COUNT(newFiles)>0, 'No Incoming Files'));

ACTIONS;

import $.^.scheduler.utils;
utils.runOrPublishByName('hpccsystems_covid19_spray', 'RUN');
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV1 as jhv1;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV2 as jhv2;
IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 

IMPORT Std; 


scopeName := 'hpccsystems::covid19::file::raw::JohnHopkins::V2';
tempSuperFileName := '~hpccsystems::covid19::file::raw::JohnHopkins::V2::temp';



processJHClean := FUNCTION

    v1CleanDs := PROJECT(jhv1.ds, 
                                TRANSFORM
                                    (
                                        jh.layout,
                                        SELF.fips := '',
                                        SELF.admin2:= '';
                                        SELF.state := Std.Str.ToUpperCase(LEFT.state);
                                        SELF.country := Std.Str.ToUpperCase(LEFT.country);
                                        SELF.geo_lat := (DECIMAL9_6)LEFT.geo_lat,
                                        SELF.geo_long := (DECIMAL9_6)LEFT.geo_long,
                                        SELF.update_date := Std.Date.FromStringToDate(LEFT.last_update[..10], '%Y-%m-%d'),
                                        SELF.confirmed := (UNSIGNED4)LEFT.confirmed,
                                        SELF.deaths := (UNSIGNED4)LEFT.deaths,
                                        SELF.recovered := (UNSIGNED4)LEFT.recovered,
                                        SELF.active := 0,
                                        SELF.combined_key:= ''
                                    )
                            );  





    tempJhV2 := DATASET(tempSuperFileName, jhv2.layout, CSV(HEADING(1)));        
    
    //IF (LENGTH(LEFT.fips) = 4, '0' + LEFT.fips, LEFT.fips),

    v2Clean := PROJECT(tempJhV2, 
                                TRANSFORM
                                    (
                                        jh.layout,
                                        SELF.fips  := IF (LENGTH(LEFT.fips) = 4, '0' + LEFT.fips, LEFT.fips),
                                        SELF.admin2 := Std.Str.ToUpperCase(LEFT.admin2), 
                                        SELF.state := Std.Str.ToUpperCase(LEFT.state),
                                        SELF.country := IF(LEFT.country='Korea, South','SOUTH KOREA',Std.Str.ToUpperCase(LEFT.country)),
                                        SELF.geo_lat := (DECIMAL9_6)LEFT.geo_lat,
                                        SELF.geo_long := (DECIMAL9_6)LEFT.geo_long,
                                        dtStr := LEFT.fileName[LENGTH(LEFT.fileName)-13..LENGTH(LEFT.fileName)-4];
                                        SELF.update_date :=  Std.Date.FromStringToDate(dtStr, '%m-%d-%Y');
                                        SELF.confirmed := (UNSIGNED4)LEFT.confirmed,
                                        SELF.deaths := (UNSIGNED4)LEFT.deaths,
                                        SELF.recovered := (UNSIGNED4)LEFT.recovered,
                                        SELF.active := (UNSIGNED4)LEFT.active,
                                        SELF.combined_key := Std.Str.ToUpperCase(LEFT.combined_key)
                                    )
                        );  



    world := SORT(v2Clean + v1CleanDs, -update_date);


    us := world(country='US');

    return SEQUENTIAL (OUTPUT(world,,jh.worldFilePath, THOR, COMPRESSED, OVERWRITE), 
                      OUTPUT(us,,jh.usFilePath, THOR, COMPRESSED, OVERWRITE));
    

END;

SEQUENTIAL(
NOTHOR(SEQUENTIAL(
        STD.File.DeleteSuperFile(tempSuperFileName),
        STD.File.CreateSuperFile(tempSuperFileName),
        STD.File.StartSuperFileTransaction(),
        APPLY(STD.File.LogicalFileList(scopeName + '*'),STD.File.AddSuperFile(tempSuperFileName,'~'+name)),
        STD.File.FinishSuperFileTransaction())),
        
        processJHClean);




// latestDt := MAX(us, update_date);

// OUTPUT(TABLE(us(update_date=latestDt), {update_date, REAL total_cases:= SUM(GROUP, confirmed)}, update_date),,NAMED('total_cases_world'));
// OUTPUT(TABLE(world(update_date=latestDt), {update_date, REAL total_cases:= SUM(GROUP, confirmed)}, update_date),,NAMED('total_cases_us'));



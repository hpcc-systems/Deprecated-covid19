IMPORT hpccsystems.covid19.file.raw.IndiaPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.IndiaPopulation as popClean;

IMPORT Std;

cleanedPop := PROJECT
    (
       popRaw.ds(birth_place = 'Total Population'), 
       TRANSFORM
       (
         popClean.layout,                          
            area0 := STD.Str.ToUpperCase(STD.STR.FindReplace(LEFT.area_name[9..], '&', 'AND'));
            area1 := TRIM(REGEXREPLACE('[^ A-Z]', area0, ''), LEFT, RIGHT);
            SELF.area_name := MAP(area1 = 'DADRA AND NAGAR HAVELI' => 'DADRA NAGAR HAVELI',
                                  area1 = 'DAMAN AND DIU' => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',
                                  area1 = 'NCT OF DELHI' => 'DELHI',
                                  area1 = 'LAKSHADWEEP' => 'LADAKH',
                                  area1 = 'LAKSHADWEEP' => 'LADAKH',
                                  area1),
            SELF := LEFT
       ) 
    );       

TELANGANADS := DATASET(1, TRANSFORM(popclean.layout,
                                       SELF.area_name := 'TELANGANA',
                                       SELF.state := '36',
                                       SELF.total_persons := 35193978,
                                       SELF.Total_Males := 0,
                                       SELF.Total_Females := 0,
                                       SELF.Rural_Persons := 0,
                                       SELF.Rural_Males := 0,
                                       SELF.Rural_Females := 0,
                                       SELF.Urban_Persons := 0,
                                       SELF.Urban_Males := 0,
                                       SELF.Urban_Females := 0));
AndhraPradeshDS := DATASET(1, TRANSFORM(popclean.layout,
                                       SELF.area_name := 'ANDHRA PRADESH',
                                       SELF.state := '37',
                                       SELF.total_persons := 49386799 ,
                                       SELF.Total_Males := 0,
                                       SELF.Total_Females := 0,
                                       SELF.Rural_Persons := 0,
                                       SELF.Rural_Males := 0,
                                       SELF.Rural_Females := 0,
                                       SELF.Urban_Persons := 0,
                                       SELF.Urban_Males := 0,
                                       SELF.Urban_Females := 0));     
rst :=   cleanedPop(area_name <> '' AND area_name <> 'ANDHRA PRADESH') + TELANGANADS +  AndhraPradeshDS ;         

OUTPUT(rst ,,popclean.filePath, THOR, COMPRESSED, OVERWRITE);
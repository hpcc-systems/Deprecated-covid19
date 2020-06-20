
IMPORT STD;
IMPORT hpccsystems.covid19.file.raw.WorldPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.WorldPopulation as popClean;


cleanPop0_popgender := PROJECT(popRaw.ds_popgender(time = '2019'),
                   TRANSFORM(popClean.layout_popgender,
                   SELF.Location   := TRIM(STD.Str.ToUpperCase(LEFT.Location), LEFT, RIGHT),
                   SELF.time       := (INTEGER) LEFT.time,
                   SELF.popMale    := (INTEGER) (LEFT.PopMale  )  * 1000,
                   SELF.popFemale  := (INTEGER) (LEFT.PopFemale)  * 1000,
                   SELF.PopTotal   := (INTEGER) (LEFT.PopTotal )  * 1000,
                   SELF.popDensity := (REAL)LEFT.PopDensity * 1000,
                   SELF := LEFT
                   ));

cleanPop1_popgender := PROJECT(cleanPop0_popgender,
        TRANSFORM(RECORDOF(LEFT),
        SELF.LOCATION:= IF(STD.STR.FIND(LEFT.location, 'D\'IVOIRE') <> 0, 'COTE D\'IVOIRE ', 
                           MAP(LEFT.location = 'UNITED STATES OF AMERICA' => 'US',
                           LEFT.location = 'VIET NAM' => 'VIETNAM',
                           LEFT.location = 'VENEZUELA (BOLIVARIAN REPUBLIC OF)' => 'VENEZUELA',
                           LEFT.location = 'SYRIAN ARAB REPUBLIC' => 'SYRIA',
                           LEFT.location = 'REPUBLIC OF KOREA' => 'SOUTH KOREA',
                           LEFT.location = 'RUSSIAN FEDERATION' => 'RUSSIA',
                           LEFT.location = 'REPUBLIC OF MOLDOVA' => 'MOLDOVA',
                           LEFT.location = 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC' => 'LAOS',
                           LEFT.location = 'BOLIVIA (PLURINATIONAL STATE OF)' => 'BOLIVIA',
                           LEFT.location = 'BRUNEI DARUSSALAM' => 'BRUNEI',
                           LEFT.location = 'CHINA, TAIWAN PROVINCE OF CHINA' => 'TAIWAN*',
                           LEFT.location = 'BRUNEI DARUSSALAM' => 'BRUNEI',
                           LEFT.location = 'IRAN (ISLAMIC REPUBLIC OF)' => 'IRAN',
                           LEFT.location = 'UNITED REPUBLIC OF TANZANIA' => 'TANZANIA',
                           LEFT.location = 'DEMOCRATIC REPUBLIC OF THE CONGO' => 'CONGO (KINSHASA)',
                           LEFT.location = 'CONGO' => 'CONGO (BRAZZAVILLE)',
                           LEFT.location = 'MYANMAR' => 'BURMA',
                           LEFT.location = 'DOMINICA' => 'DOMENICA',
                           LEFT.location)),
        SELF := LEFT
        ) );  

others := DATASET([{'','WEST BANK AND GAZA',2018,'','','4569087',''},
                {'','KOSOVO',2020,'','','1810366',''}], popClean.layout_popgender);

OUTPUT(cleanPop1_popgender + others,, popClean.filepath_popgender, THOR, COMPRESSED, OVERWRITE );





cleanPop0_popage := PROJECT(popRaw.ds_popage(time = '2019'),
                   TRANSFORM(popClean.layout_popage,
                   SELF.Location   := TRIM(STD.Str.ToUpperCase(LEFT.Location), LEFT, RIGHT),
                   SELF.time       := (INTEGER) LEFT.time,
                   SELF.popMale    := (INTEGER) (LEFT.PopMale  )  * 1000,
                   SELF.popFemale  := (INTEGER) (LEFT.PopFemale)  * 1000,
                   SELF.PopTotal   := (INTEGER) (LEFT.PopTotal )  * 1000,
                   SELF := LEFT
                   ));
cleanPop1_popage := PROJECT(cleanPop0_popage,
        TRANSFORM(RECORDOF(LEFT),
        SELF.LOCATION:= IF(STD.STR.FIND(LEFT.location, 'D\'IVOIRE') <> 0, 'COTE D\'IVOIRE ', 
                           MAP(LEFT.location = 'UNITED STATES OF AMERICA' => 'US',
                           LEFT.location = 'VIET NAM' => 'VIETNAM',
                           LEFT.location = 'VENEZUELA (BOLIVARIAN REPUBLIC OF)' => 'VENEZUELA',
                           LEFT.location = 'SYRIAN ARAB REPUBLIC' => 'SYRIA',
                           LEFT.location = 'REPUBLIC OF KOREA' => 'SOUTH KOREA',
                           LEFT.location = 'RUSSIAN FEDERATION' => 'RUSSIA',
                           LEFT.location = 'REPUBLIC OF MOLDOVA' => 'MOLDOVA',
                           LEFT.location = 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC' => 'LAOS',
                           LEFT.location = 'BOLIVIA (PLURINATIONAL STATE OF)' => 'BOLIVIA',
                           LEFT.location = 'BRUNEI DARUSSALAM' => 'BRUNEI',
                           LEFT.location = 'CHINA, TAIWAN PROVINCE OF CHINA' => 'TAIWAN*',
                           LEFT.location = 'BRUNEI DARUSSALAM' => 'BRUNEI',
                           LEFT.location = 'IRAN (ISLAMIC REPUBLIC OF)' => 'IRAN',
                           LEFT.location = 'UNITED REPUBLIC OF TANZANIA' => 'TANZANIA',
                           LEFT.location = 'DEMOCRATIC REPUBLIC OF THE CONGO' => 'CONGO (KINSHASA)',
                           LEFT.location = 'CONGO' => 'CONGO (BRAZZAVILLE)',
                           LEFT.location = 'MYANMAR' => 'BURMA',
                           LEFT.location = 'DOMINICA' => 'DOMENICA',
                           LEFT.location)),
        SELF := LEFT
        ) );  
OUTPUT(cleanPop1_popage ,, popClean.filepath_popage , THOR, COMPRESSED, OVERWRITE);


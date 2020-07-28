IMPORT hpccsystems.covid19.file.raw.AustraliaPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.AustraliaPopulation as popClean;

IMPORT Std;


cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (popClean.layout,
            SELF.State_and_territory := STD.Str.ToUpperCase(TRIM(LEFT.State_and_territory, LEFT, RIGHT));
            pop := (UNSIGNED) STD.Str.FindReplace(LEFT.population_at_31_Dec_2019, ' ', '');
            SELF.Population  :=  pop   * 1000;
            change :=  (DECIMAL) STD.Str.FindReplace(LEFT.Change_over_previous_year__000, ' ', '');
            SELF.Change_over_previous_year  := change * 1000 ;
            SELF.Change_over_previous_year_percentage  := (DECIMAL) LEFT.Change_over_previous_year__;
       ) 
    );       

OUTPUT(cleanedPop, , popclean.filePath, THOR, COMPRESSED, OVERWRITE);
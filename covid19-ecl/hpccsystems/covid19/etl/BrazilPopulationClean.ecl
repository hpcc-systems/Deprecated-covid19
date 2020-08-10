IMPORT hpccsystems.covid19.file.raw.BrazilPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.BrazilPopulation as popClean;

IMPORT Std;


fclean(STRING s) := FUNCTION
  s0 := STD.Str.FindReplace(s, '&aacute;', 'a');
  s1 := STD.Str.FindReplace(s0, '&iacute;', 'i');
  s2 := STD.Str.FindReplace(s1, '&atilde;', 'a');
  s3 := STD.Str.FindReplace(s2, '&ocirc;', 'o');
  s4 := STD.Str.ToUpperCase(TRIM(s3, LEFT, RIGHT));
  RETURN s4;
END;

cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (popClean.layout,
              SELF.state  := fclean(LEFT.FU),
              SELF.Code  := LEFT.code;
              SELF.Area_km2_2019  := LEFT.area___km2__2019_;
              SELF.Population  := LEFT.population_estimate___people__2019_;
              SELF.Demographic_density_inhab_km2_2010  := LEFT.demographic_density___inhab_km2__2010_;
              SELF.Enrollment_in_primary_education_2018  := LEFT.enrollment_in_primary_education___enrollments__2018_;
              SELF.Realized_revenue_R$_1000_2017  := LEFT.realized_revenue___r$__1000___2017_;
              SELF.Committed_expenditure_R$_1000_2017  := LEFT.committed_expenditure___r$__1000___2017_;
              SELF.Monthly_household_income_per_capita_R$_2019  := LEFT.monthly_household_income_per_capita___r$__2019_;
              SELF.Total_vehicles_vehicles_2018  := LEFT.total_vehicles___vehicles__2018_;
       ) 
    );       

OUTPUT(cleanedPop, , popclean.filePath, THOR, COMPRESSED, OVERWRITE);


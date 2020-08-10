EXPORT BrazilPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::Brazilpopulation::v1::brazilstatepopulation.csv';  
                       
  EXPORT layout := RECORD
    STRING FU;
    STRING Code;
    STRING Demonym;
    STRING Governor__2019_;
    STRING Capital__2010_;
    DECIMAL Area___km2__2019_;
    UNSIGNED Population_Estimate___people__2019_;
    DECIMAL Demographic_density___inhab_km2__2010_;
    UNSIGNED Enrollment_in_primary_education___enrollments__2018_;
    DECIMAL Realized_revenue___R$__1000___2017_;
    DECIMAL Committed_expenditure___R$__1000___2017_;
    DECIMAL Monthly_household_income_per_capita___R$__2019_;
    UNSIGNED Total_vehicles___vehicles__2018_;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
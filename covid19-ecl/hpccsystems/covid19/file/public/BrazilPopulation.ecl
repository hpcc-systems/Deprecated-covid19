EXPORT BrazilPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::public::brazilpopulation::v1::population.flat';  
                       

  EXPORT layout := RECORD
    STRING state;
    STRING Code;
    DECIMAL Area_km2_2019;
    UNSIGNED Population;
    DECIMAL Demographic_density_inhab_km2_2010;
    UNSIGNED Enrollment_in_primary_education_2018;
    DECIMAL Realized_revenue_R$_1000_2017;
    DECIMAL Committed_expenditure_R$_1000_2017;
    DECIMAL Monthly_household_income_per_capita_R$_2019;
    UNSIGNED Total_vehicles_vehicles_2018;
  END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
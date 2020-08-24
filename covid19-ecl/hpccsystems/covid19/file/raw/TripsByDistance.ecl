EXPORT tripsByDistance := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::bts::v1::trips_By_Distance.csv';  
                       

  EXPORT layout := RECORD
    STRING Level;
    STRING Date;
    UNSIGNED2 State_FIPS;
    STRING State_Postal_Code;
    UNSIGNED4 County_FIPS;
    STRING County_Name;
    UNSIGNED Population_Staying_at_Home;
    UNSIGNED Population_Not_Staying_at_Home;
    UNSIGNED Number_of_Trips;
    UNSIGNED Number_of_Trips__1;
    UNSIGNED Number_of_Trips_1_3;
    UNSIGNED Number_of_Trips_3_5;
    UNSIGNED Number_of_Trips_5_10;
    UNSIGNED Number_of_Trips_10_25;
    UNSIGNED Number_of_Trips_25_50;
    UNSIGNED Number_of_Trips_50_100;
    UNSIGNED Number_of_Trips_100_250;
    UNSIGNED Number_of_Trips_250_500;
    UNSIGNED Number_of_Trips___500;
END;

  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  

END;
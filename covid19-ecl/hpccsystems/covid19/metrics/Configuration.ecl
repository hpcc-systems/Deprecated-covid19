EXPORT Configuration := MODULE
  EXPORT InfectionPeriod := 10; // The duration of the infections period of the disease (in days)
  EXPORT PeriodDays := 7; // The number of days in the analysis period.
  EXPORT ScaleFactor := 5;  // Scale factor for Heat Index.  Lower will give more hot spots.
  EXPORT MinActDefault := 20; // Minimum cases to be considered emerging, by default.
  EXPORT MinActPer100k := 30; // Minimum active per 100K population to be considered emerging.
  EXPORT InfectedConfirmedRatio := 5.0; // The ration of Total Cases (Asymptomatic, Sub-cliinical, Confirmed Clinical) to Clinical Cases.
                                        // Calibrated by early antibody testing (rough estimate), and ILI Surge statistics.
  EXPORT FilterMaxGrowthFactor := 5; // The maximum implied change in R to allow in one day, and inverse of the
                                          // maximum daily reduction (in terms of R).
  EXPORT LocDelim := '-';  // Delimiter to use between location terms.
END;
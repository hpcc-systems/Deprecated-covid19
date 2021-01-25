IMPORT Std.Date;
Date_t := Date.Date_t;

EXPORT Types2 := MODULE
  // Infection State Enumerated Values
  EXPORT iState_t := ENUM(Unknown = 0, Emerging = 1, Spreading = 2, Stabilizing = 3, Stabilized = 4, Recovering = 5, Recovered = 6, Regressing = 7);
  // Format for metric information
  EXPORT metric_t := DECIMAL9_2;
  // Format for count information
  EXPORT count_t := INTEGER8;
  // Daily Covid Record
  EXPORT InputRec := RECORD
    STRING fips := ''; //will be needed to map counties
    STRING Country;
    STRING Level2;  // State / Region, etc.  Can be blank for Country level inputs
    STRING Level3; // County, District, etc.  Can be blank for State / Country level inputs
    Date_t date;
    count_t cumCases; // Cumulative confirmed cases
    count_t cumDeaths; // Cumulative deaths
    count_t cumHosp := 0; // Cumulative number hospitalized
    count_t tested := 0; // Cumulative number tested
    count_t positive := 0; // Cumulative positive tests
    count_t negative := 0; // Cumulative negative tests
    count_t population := 0; // Location population
    UDECIMAL11_8  latitude := 0;  // Location Latitude
    UDECIMAL11_8  longitude := 0; // Location Longitude
    count_t vacc_total_dist := 0; // Total Vaccines Distributed
    count_t vacc_total_admin := 0; // Total Vaccines Administered
    count_t vacc_total_people := 0; // Total People Vaccinated
    count_t vacc_people_complete := 0; // People Fully Vaccinated
  END;
  // Extended Stats Record
  EXPORT statsRec := RECORD(InputRec)
    STRING Location; // Combination of Location levels e.g. US,COLORADO,LARIMER
    UNSIGNED id := 0;
    UNSIGNED period := 0;
    count_t prevCases := 0; // Previous day's cumCases
    count_t newCases := 0; // Today's new cases
    count_t prevDeaths := 0; // Previous day's cumDeaths
    count_t newDeaths := 0; // Today's new deaths
    count_t active := 0; // Number of active infections per SIR model
    count_t prevActive := 0; // Yesterday's active infections
    count_t recovered := 0; // Number of recoverd cases per SIR model
    REAL cases7dma := 0; // 7-day moving average of new cases
    REAL deaths7dma := 0; // 7-day moving average of new deaths
    DECIMAL5_3 cfr := 0; // Case Fatality Rate (CFR)
    count_t adjCumCases := 0; // Alternate cumCases based on smoothed data
    count_t adjCumDeaths := 0; // Alternate cumDeaths based on smoothed data
    count_t adjPrevCases := 0; // Previous day's adjCumCases
    count_t adjPrevDeaths := 0; // Previous day's adjCumDeaths
    INTEGER caseAdjustment := 0;  // The amount by which cases were adjusted
    INTEGER deathsAdjustment := 0; // The amount by which cases were adjusted
    count_t vacc_daily_dist := 0; // New vaccines distributed
    count_t vacc_daily_admin := 0; // Newly administered vaccines
    count_t vacc_daily_people := 0; // People vaccinated today 
    count_t vacc_daily_complete := 0; // People Fully Vaccinated Today
  END;
  // Metrics Record
  EXPORT metricsRec := RECORD
    STRING fips;
    STRING location;
    UNSIGNED period := 1;
    Date_t startDate;
    Date_t endDate;
    STRING iState := 'Initial';
    count_t cases;
    count_t deaths;
    count_t active;
    metric_t cR := 0;
    metric_t mR := 0;
    metric_t R := 0;
    metric_t sdIndicator := 0;
    metric_t medIndicator := 0;
    DECIMAL8_3 heatIndex := 0;
    DECIMAL5_3 cfr;
    count_t infectionCount := 1;
    metric_t immunePct := 0;
    count_t newCases;
    count_t newDeaths;
    count_t newCasesDaily;
    count_t newDeathsDaily;
    count_t recovered;
    metric_t cases_per_capita := 0; // Per 100,000
    metric_t deaths_per_capita := 0; // Per 100,000
    metric_t cmRatio := 0;
    metric_t dcR := 0;
    metric_t dmR := 0;
    metric_t weeksToPeak := 0;
    count_t peakCases := 0;
    count_t peakDeaths := 0;
    UNSIGNED periodDays;
    STRING commentary := '';
    metric_t cR_old := 0;
    STRING prevState := '';
    metric_t sti := 0; // Short term indicator
    metric_t ewi := 0; // Early warning indicator
    BOOLEAN wasRecovering := FALSE;
    date_t surgeStart := 0;
    DECIMAL5_3 currCFR := 0;
    DECIMAL5_3 ifr := 0; // Infection Fatality Rate
    DECIMAL5_3 currIFR := 0; // Current (non-cumulative) IFR
    DECIMAL5_3 contagionRisk := 0; // Risk of catching the disease
    count_t population :=0;
    STRING Country;
    STRING Level2;  // State / Region, etc.  Can be blank for Country level inputs
    STRING Level3; // County, District, etc.  Can be blank for State / Country level inputs
    count_t vacc_total_dist := 0; // Total Vaccines Distributed
    count_t vacc_total_admin := 0; // Total Vaccines Administered
    count_t vacc_total_people := 0; // Total People Vaccinated
    count_t vacc_people_complete := 0; // People Fully Vaccinated
    count_t vacc_period_dist := 0; // New vaccines distributed
    count_t vacc_period_admin := 0; // Newly administered vaccines
    count_t vacc_period_people := 0; // People newly vaccinated 
    count_t vacc_period_complete := 0; // People newly Fully Vaccinated
    metric_t vacc_complete_pct := 0.0; // Percent of population fully vaccinated
    metric_t vacc_admin_pct := 0.0; // Percent of distributed doses administered
  END;
  EXPORT metricsEvolRec := RECORD(metricsRec)
    UNSIGNED asOfDate;
  END;

  // Population Record
  EXPORT populationRec := RECORD
      STRING location;
      count_t population;
  END;
  // Hot Spot Report format
  EXPORT hsFormat := RECORD
    STRING location;
    UNSIGNED currRank;
    UNSIGNED prevRank;
    INTEGER rankImprove;
    STRING iState;
    metric_t cR;
    metric_t mR;
    metric_t R;
    metric_t sdIndicator;
    metric_t medIndicator;
    count_t activeCases;
    count_t deaths;
    count_t newCases;
    count_t newDeaths;
    DECIMAL6_3 heatIndex;
    metric_t hiImprove;
    count_t infectionCount;
    STRING commentary;
  END;
  EXPORT summaryRec := RECORD(statsRec)
    metric_t cR := 0;
    metric_t mR := 0;
    metric_t R := 0;
    metric_t sdIndicator := 0;
    metric_t medIndicator := 0;
    DECIMAL8_3 heatIndex := 0;
    DECIMAL5_3 iMort;
    count_t infectionCount := 1;
    count_t weeklyNewCases;
    count_t weeklyNewDeaths;
  END;
END;
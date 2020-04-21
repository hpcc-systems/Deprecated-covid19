IMPORT Std;

EXPORT CTP := MODULE

  EXPORT dailyFilePath := '~hpccsystems::covid19::file::public::ctp::daily.csv';  

  EXPORT dailyLayout := RECORD
    Std.Date.Date_t  date;
    STRING2 state_code;
    UNSIGNED4 positive;
    UNSIGNED4 negative;
    UNSIGNED4 pending;
    UNSIGNED4 hospitalizedCurrently;
    UNSIGNED4 hospitalizedCumulative;
    UNSIGNED4 inIcuCurrently;
    UNSIGNED4 onVentilatorCurrently;
    UNSIGNED4 onVentilatorCummilative;
    UNSIGNED4 recoverd;
    STRING50 hash;
    STRING50 date_checked;
    UNSIGNED4 death;
    UNSIGNED4 hospitalized;
    UNSIGNED4 total;
    UNSIGNED4 totalTestresults;
    UNSIGNED4 posNeg;
    STRING10 fips;
    UNSIGNED4 deathIncrease;
    UNSIGNED4 hospitalizedIncrease;
    UNSIGNED4 negativeIncrease;
    UNSIGNED4 positiveIncrease;
    UNSIGNED4 totalTestResultsIncrease;
    STRING state;
  END;

  EXPORT daily := DATASET(dailyFilePath, dailyLayout, CSV(HEADING(1)));  

  EXPORT metricsFilePath := '~hpccsystems::covid19::file::public::ctp::metrics.flat';

  EXPORT metricsLayout := RECORD
    Std.Date.Date_t  date;
    STRING state;
    UNSIGNED4 positive;
    UNSIGNED4 neagtive;
    DECIMAL8_2 positivePercent;
  END;

  EXPORT metrics := DATASET(metricsFilePath, metricsLayout, THOR); 

END;
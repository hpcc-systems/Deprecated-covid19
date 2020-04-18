IMPORT Std;

EXPORT CTP := MODULE

  EXPORT dailyFilePath := '~hpccsystems::covid19::file::raw::ctp::daily.csv';  

//date,state,positive,negative,pending,hospitalizedCurrently,hospitalizedCumulative,inIcuCurrently,
//inIcuCumulative,onVentilatorCurrently,onVentilatorCumulative,recovered,hash,dateChecked,death,hospitalized,total,
//totalTestResults,posNeg,fips,deathIncrease,hospitalizedIncrease,negativeIncrease,positiveIncrease,totalTestResultsIncrease	

  EXPORT dailyLayout := RECORD
    Std.Date.Date_t  date;
    STRING2 state_code;
    UNSIGNED4 positive;
    UNSIGNED4 negative;
    UNSIGNED4 pending;
    UNSIGNED4 hospitalizedCurrently;
    UNSIGNED4 hospitalizedCumulative;
    UNSIGNED4 inIcuCurrently;
    UNSIGNED4 inIcuCumulative;
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
  END;

  EXPORT daily := DATASET(dailyFilePath, dailyLayout, CSV(HEADING(1)));  

END;
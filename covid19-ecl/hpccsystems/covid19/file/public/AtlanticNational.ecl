EXPORT atlanticNational := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::public::atlantic::national.flat';
EXPORT layout := RECORD
    UNSIGNED4 date;
    UNSIGNED death;
    UNSIGNED deathIncrease;
    UNSIGNED inIcuCumulative;
    UNSIGNED inIcuCurrently;
    UNSIGNED hospitalizedIncrease;
    UNSIGNED hospitalizedCurrently;
    UNSIGNED hospitalizedCumulative;
    UNSIGNED negative;
    UNSIGNED negativeIncrease;
    UNSIGNED onVentilatorCumulative;
    UNSIGNED onVentilatorCurrently;
    UNSIGNED posNeg;
    UNSIGNED positive;
    UNSIGNED positiveIncrease;
    UNSIGNED recovered;
    UNSIGNED states;
    UNSIGNED totalTestResults;
    UNSIGNED totalTestResultsIncrease;
END;

EXPORT ds := DATASET(filepath, Layout, FLAT);

END;
EXPORT atlanticStates := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::public::atlantic::states.flat';
EXPORT layout := RECORD
    UNSIGNED4 date;
    STRING4 state;
    STRING4 dataQualityGrade;
    UNSIGNED death;
    UNSIGNED deathConfirmed;
    UNSIGNED deathIncrease;
    UNSIGNED deathProbable;
    UNSIGNED hospitalized;
    UNSIGNED hospitalizedCumulative;
    UNSIGNED hospitalizedCurrently;
    UNSIGNED hospitalizedIncrease;
    UNSIGNED inIcuCumulative;
    UNSIGNED inIcuCurrently;
    UNSIGNED negative;
    UNSIGNED negativeIncrease;
    UNSIGNED negativeTestsAntibody;
    UNSIGNED negativeTestsPeopleAntibody;
    UNSIGNED negativeTestsViral;
    UNSIGNED onVentilatorCumulative;
    UNSIGNED onVentilatorCurrently;
    UNSIGNED pending;
    UNSIGNED positive;
    UNSIGNED positiveCasesViral;
    UNSIGNED positiveIncrease;
    UNSIGNED positiveScore;
    UNSIGNED positiveTestsAntibody;
    UNSIGNED positiveTestsAntigen;
    UNSIGNED positiveTestsPeopleAntibody;
    UNSIGNED positiveTestsPeopleAntigen;
    UNSIGNED positiveTestsViral;
    UNSIGNED recovered;
    UNSIGNED totalTestEncountersViral;
    UNSIGNED totalTestEncountersViralIncrease;
    UNSIGNED totalTestResults;
    UNSIGNED totalTestResultsIncrease;
    UNSIGNED totalTestsAntibody;
    UNSIGNED totalTestsAntigen;
    UNSIGNED totalTestsPeopleAntibody;
    UNSIGNED totalTestsPeopleAntigen;
    UNSIGNED totalTestsPeopleViral;
    UNSIGNED totalTestsPeopleViralIncrease;
    UNSIGNED totalTestsViral;
    UNSIGNED totalTestsViralIncrease;
END;

EXPORT ds := DATASET(filepath, Layout, FLAT);

END;
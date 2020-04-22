IMPORT Std.Date;
Date_t := Date.Date_t;

EXPORT Types := MODULE
    // Infection State Enumerated Values
    EXPORT iState_t := ENUM(Unknown = 0, Emerging = 1, Spreading = 2, Stabilizing = 3, Stabilized = 4, Recovering = 5, Recovered = 6, Regressing = 7);
    // Format for metric information
    EXPORT metric_t := DECIMAL5_2;
    // Daily Covid Record
    EXPORT statsRec := RECORD
        STRING Location;
        Date_t date;
        UNSIGNED cumCases; // Cumulative confirmed cases
        UNSIGNED cumDeaths; // Cumulative deaths
        UNSIGNED cumHosp := 0; // Cumulative number hospitalized
        UNSIGNED tested := 0; // Cumulative number tested
        UNSIGNED positive := 0; // Cumulative positive tests
        UNSIGNED negative := 0; // Cumulative negative te&sts
    END;
    // Metrics Record
    EXPORT metricsRec := RECORD
        STRING location;
        UNSIGNED period := 1;
        Date_t startDate;
        Date_t endDate;
        STRING iState := 'Initial';
        UNSIGNED cases;
        UNSIGNED deaths;
        UNSIGNED active;
        metric_t cR;
        metric_t mR;
        metric_t sdIndicator := 0;
        metric_t medIndicator := 0;
        DECIMAL6_3 heatIndex := 0;
        DECIMAL5_3 iMort;
        metric_t immunePct := 0;
        UNSIGNED newCases;
        UNSIGNED newDeaths;
        UNSIGNED recovered;
        metric_t cases_per_capita := 0;
        metric_t deaths_per_capita := 0;
        metric_t cmRatio;
        metric_t dcR := 0;
        metric_t dmR := 0;
        metric_t weeksToPeak := 0;
        UNSIGNED periodDays;
        UNSIGNED population :=0;
    END;
    // Extended Stats Record
    EXPORT statsExtRec := RECORD(statsRec)
        UNSIGNED id;
        INTEGER period := 1;
        UNSIGNED prevCases := 0;
        UNSIGNED newCases := 0;
        UNSIGNED prevDeaths := 0;
        UNSIGNED newDeaths := 0;
        REAL periodCGrowth := 0;
        REAL periodMGrowth := 0;
        UNSIGNED active := 0;
        UNSIGNED prevActive := 0;
        UNSIGNED recovered := 0;
        REAL iMort := 0;
    END;
    // Population Record
    EXPORT populationRec := RECORD
        STRING location;
        UNSIGNED population;
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
        metric_t sdIndicator;
        metric_t medIndicator;
        UNSIGNED activeCases;
        UNSIGNED deaths;
        DECIMAL6_3 heatIndex;
        metric_t hiImprove;
    END;
END;
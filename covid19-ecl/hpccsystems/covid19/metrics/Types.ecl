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
        DECIMAL8_2 cumCases; // Cumulative confirmed cases
        DECIMAL8_2 cumDeaths; // Cumulative deaths
        DECIMAL8_2 cumHosp := 0; // Cumulative number hospitalized
        DECIMAL8_2 tested := 0; // Cumulative number tested
        DECIMAL8_2 positive := 0; // Cumulative positive tests
        DECIMAL8_2 negative := 0; // Cumulative negative te&sts
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
        metric_t cR := 0;
        metric_t mR := 0;
        metric_t sdIndicator := 0;
        metric_t medIndicator := 0;
        DECIMAL6_3 heatIndex := 0;
        DECIMAL5_3 iMort;
        metric_t immunePct := 0;
        DECIMAL8_2 newCases;
        DECIMAL8_2 newDeaths;
        DECIMAL8_2 recovered;
        metric_t cases_per_capita := 0;
        metric_t deaths_per_capita := 0;
        metric_t cmRatio := 0;
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
        DECIMAL8_2 prevCases := 0;
        DECIMAL8_2 newCases := 0;
        DECIMAL8_2 prevDeaths := 0;
        DECIMAL8_2 newDeaths := 0;
        REAL periodCGrowth := 0;
        REAL periodMGrowth := 0;
        DECIMAL8_2 active := 0;
        DECIMAL8_2 prevActive := 0;
        DECIMAL8_2 recovered := 0;
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
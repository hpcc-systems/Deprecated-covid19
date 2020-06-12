IMPORT Std.Date;
Date_t := Date.Date_t;

EXPORT Types := MODULE
    // Infection State Enumerated Values
    EXPORT iState_t := ENUM(Unknown = 0, Emerging = 1, Spreading = 2, Stabilizing = 3, Stabilized = 4, Recovering = 5, Recovered = 6, Regressing = 7);
    // Format for metric information
    EXPORT metric_t := DECIMAL5_2;
		// Format for count information
		EXPORT count_t := INTEGER8;
    // Daily Covid Record
    EXPORT statsRec := RECORD
        STRING fips := '';//will be needed to map counties
        STRING Location;
        Date_t date;
        count_t cumCases; // Cumulative confirmed cases
        count_t cumDeaths; // Cumulative deaths
        count_t cumHosp := 0; // Cumulative number hospitalized
        count_t tested := 0; // Cumulative number tested
        count_t positive := 0; // Cumulative positive tests
        count_t negative := 0; // Cumulative negative tessts
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
				date_t surgeStart := '';
				DECIMAL5_3 currCFR := 0;
        count_t population :=0;
    END;
		EXPORT metricsEvolRec := RECORD(metricsRec)
			UNSIGNED asOfDate;
		END;
    // Extended Stats Record
    EXPORT statsExtRec := RECORD(statsRec)
        UNSIGNED id;
        INTEGER period := 1;
        count_t prevCases := 0;
        count_t newCases := 0;
        count_t prevDeaths := 0;
        count_t newDeaths := 0;
        metric_t periodCGrowth := 0;
        metric_t periodMGrowth := 0;
        count_t active := 0;
        count_t prevActive := 0;
        count_t recovered := 0;
        DECIMAL5_3 cfr := 0;
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
IMPORT $.Types;

metricsRec := Types.metricsRec;
hsFormat := Types.hsFormat;

minHI := 1.0; // Minimum Heat Index to Include

metricsE := RECORD(metricsRec)
    UNSIGNED rank;
END;

EXPORT DATASET(hsFormat) HotSpotsRpt(DATASET(metricsRec) metrics) := FUNCTION
    metrics1 := SORT(metrics, period, -heatIndex, location);
    metrics2 := GROUP(metrics1, period);
    metrics3 := PROJECT(metrics2, TRANSFORM(metricsE, SELF.rank := COUNTER, SELF := LEFT));
    hs0 := JOIN(metrics3(period=1), metrics3(period=2), LEFT.location = RIGHT.location,
                    TRANSFORM(hsFormat,
                        SELF.currRank := LEFT.rank,
                        SELF.prevRank := RIGHT.rank,
                        SELF.rankImprove := IF(RIGHT.rank > 0, LEFT.rank - RIGHT.rank, 0),
                        SELF.activeCases := LEFT.active,
                        SELF.hiImprove := IF(RIGHT.heatIndex > 0, RIGHT.heatIndex - LEFT.heatIndex, 0),
                        SELF := LEFT), LEFT OUTER);
    hs := SORT(hs0(heatIndex >= minHI), currRank);
    RETURN hs;
END;
IMPORT hpccsystems.covid19.metrics.Types2 as Types;

EXPORT LevelMeasures := MODULE
    
    //Stats

    EXPORT level0_stats_path := '~hpccsystems::covid19::file::public::stats::level0.flat';
    EXPORT level1_stats_path := '~hpccsystems::covid19::file::public::stats::level1.flat';
    EXPORT level2_stats_path := '~hpccsystems::covid19::file::public::stats::level2.flat';
    EXPORT level3_stats_path := '~hpccsystems::covid19::file::public::stats::level3.flat';

    EXPORT level0_stats := DATASET(level0_stats_path,Types.statsRec, THOR);
    EXPORT level1_stats := DATASET(level1_stats_path,Types.statsRec, THOR);
    EXPORT level2_stats := DATASET(level2_stats_path,Types.statsRec, THOR);
    EXPORT level3_stats := DATASET(level3_stats_path,Types.statsRec, THOR);

    //Metrics

    EXPORT level0_metrics_path := '~hpccsystems::covid19::file::public::metrics::level0.flat';
    EXPORT level1_metrics_path := '~hpccsystems::covid19::file::public::metrics::level1.flat';
    EXPORT level2_metrics_path := '~hpccsystems::covid19::file::public::metrics::level2.flat';
    EXPORT level3_metrics_path := '~hpccsystems::covid19::file::public::metrics::level3.flat';

    EXPORT level0_metrics := DATASET(level0_metrics_path,Types.metricsRec, THOR);
    EXPORT level1_metrics := DATASET(level1_metrics_path,Types.metricsRec, THOR);
    EXPORT level2_metrics := DATASET(level2_metrics_path,Types.metricsRec, THOR);
    EXPORT level3_metrics := DATASET(level3_metrics_path,Types.metricsRec, THOR);
END;
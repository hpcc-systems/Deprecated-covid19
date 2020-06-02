IMPORT hpccsystems.covid19.metrics.Types as types;

EXPORT DailyMetrics := MODULE
  
    EXPORT statesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_state.flat';
    EXPORT countriesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_country.flat';
    EXPORT countiesPath := '~hpccsystems::covid19::file::public::metrics::daily_by_us_county.flat';  
    EXPORT worldPath := '~hpccsystems::covid19::file::public::metrics::daily_global.flat';


    EXPORT states := DATASET(statesPath, types.statsExtRec, THOR);
    EXPORT counties := DATASET(countiesPath, types.statsExtRec, THOR);
    EXPORT countries := DATASET(countriesPath, types.statsExtRec, THOR);
    EXPORT world := DATASET(worldPath, types.statsExtRec, THOR);

END;
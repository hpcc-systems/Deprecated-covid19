IMPORT hpccsystems.covid19.file.raw.CTP as raw;
IMPORT hpccsystems.covid19.file.public.CTP as public;
IMPORT hpccsystems.covid19.utils.CatalogUSStates as utils;

OUTPUT(raw.daily);

clean := TABLE(raw.daily, {raw.daily, state := Utils.toState(state_code)});

OUTPUT(clean,,public.dailyFilePath, THOR, COMPRESSED, OVERWRITE);

metrics := TABLE(clean, {date, state, positive, negative, DECIMAL8_2 positivePercent := positive/MAX(1,positive+negative) * 100});

OUTPUT(metrics,,public.metricsFilePath,THOR, COMPRESSED, OVERWRITE);
IMPORT hpccsystems.covid19.file.raw.CTP as raw;
IMPORT hpccsystems.covid19.file.public.CTP as public;
IMPORT hpccsystems.covid19.utils.CatalogUSStates as utils;

OUTPUT(raw.daily);

clean := TABLE(raw.daily, {raw.daily, state := Utils.toState(state_code)});

OUTPUT(clean,,public.dailyFilePath, THOR, COMPRESSED, OVERWRITE);
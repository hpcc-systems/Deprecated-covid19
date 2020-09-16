IMPORT hpccsystems.covid19.file.raw.AtlanticStates as raw;
IMPORT hpccsystems.covid19.file.public.AtlanticStates as public;

ds := raw.ds;
OUTPUT(ds, , public.filepath, OVERWRITE, COMPRESSED);
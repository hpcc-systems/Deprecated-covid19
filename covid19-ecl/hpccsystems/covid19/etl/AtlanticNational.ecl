IMPORT hpccsystems.covid19.file.raw.AtlanticNational as raw;
IMPORT hpccsystems.covid19.file.public.AtlanticNational as public;

ds := raw.ds;
OUTPUT(ds, , public.filepath, OVERWRITE, COMPRESSED);
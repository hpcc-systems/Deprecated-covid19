IMPORT hpccsystems.covid19.file.raw.CountiesFIPS as fipsRaw;
IMPORT hpccsystems.covid19.file.public.CountiesFIPS as fipsClean;

OUTPUT(fipsRaw.ds,ALL);

clean := PROJECT (fipsRaw.ds,
                    TRANSFORM(
                        fipsClean.layout,
                        SELF.fips := IF (LENGTH(LEFT.fips) = 4, '0' + LEFT.fips, LEFT.fips),
                        SELF:= LEFT
                    )); 

OUTPUT(clean,,fipsClean.path,THOR,COMPRESSED, OVERWRITE);

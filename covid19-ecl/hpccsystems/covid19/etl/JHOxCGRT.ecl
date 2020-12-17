IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 
IMPORT hpccsystems.covid19.file.public.OxCGRT as ox; 
IMPORT hpccsystems.covid19.file.public.JHOxCGRT as jhOx; 

//OUTPUT(ox.ds);
worldDs := JOIN(jh.worldDs, ox.ds, 
                LEFT.country=RIGHT.countryname and LEFT.update_date=RIGHT.Date, 
                TRANSFORM(jhOx.layout, 
                          SELF := LEFT,
                          SELF := RIGHT), LEFT OUTER);

usDs := JOIN(jh.usDs, ox.ds (countryname = 'US'), 
                LEFT.state=RIGHT.regionname and LEFT.update_date=RIGHT.Date, 
                TRANSFORM(jhOx.layout, 
                          SELF := LEFT,
                          SELF := RIGHT), LEFT OUTER);

//OUTPUT(CHOOSEN(worldDs(StringencyIndex <> 0.0), 5000)); 
OUTPUT(worldDs,,jhOx.worldFilePath,thor,compressed,overwrite);
OUTPUT(usDs,,jhOx.usFilePath,thor,compressed,overwrite);


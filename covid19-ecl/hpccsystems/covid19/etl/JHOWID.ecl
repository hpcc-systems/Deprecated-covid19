IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 
IMPORT hpccsystems.covid19.file.public.OWID as owid; 
IMPORT hpccsystems.covid19.file.public.JHOWID as jhowid; 

OUTPUT(jh.worldDs);
OUTPUT(owid.ds);

worldDs := JOIN(jh.worldDs, owid.ds , 
                LEFT.country=RIGHT.location and LEFT.update_date=RIGHT.date, 
                TRANSFORM(jhowid.layout,                         
                          SELF.total_vaccinations := RIGHT.total_vaccinations,
                          SELF.people_vaccinated := RIGHT.people_vaccinated,
                          SELF.people_fully_vaccinated := RIGHT.people_fully_vaccinated,
                          SELF.daily_vaccinations_raw := RIGHT.daily_vaccinations_raw,
                          SELF.daily_vaccinations := RIGHT.daily_vaccinations,
                          SELF.fips := LEFT.fips,
                          SELF:= LEFT), LEFT OUTER);

OUTPUT(worldDs, , jhowid.worldFilePath, OVERWRITE, COMPRESSED);
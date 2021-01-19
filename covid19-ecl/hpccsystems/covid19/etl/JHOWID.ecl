IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 
IMPORT hpccsystems.covid19.file.public.OWID as owid; 
IMPORT hpccsystems.covid19.file.public.JHOWID as jhowid; 



worldDs := JOIN(jh.worldDs, owid.worldDs , 
                LEFT.country=RIGHT.location and LEFT.update_date=RIGHT.date, 
                TRANSFORM(jhowid.layout,                         
                          SELF.people_vaccinated := RIGHT.people_vaccinated,
                          SELF.people_fully_vaccinated := RIGHT.people_fully_vaccinated,
                          SELF.daily_vaccinations_raw:= RIGHT.daily_vaccinations_raw,
                          SELF.daily_vaccinations:= RIGHT.daily_vaccinations,
                          SELF:= LEFT), LEFT OUTER);

appendUSDs := JOIN(worldDs, owid.usDs , 
                LEFT.country='US' and LEFT.admin2='UNASSIGNED' and LEFT.state=RIGHT.location and LEFT.update_date=RIGHT.date, 
                TRANSFORM(jhowid.layout,                         
                          SELF.people_vaccinated := RIGHT.people_vaccinated,
                          SELF.people_fully_vaccinated := RIGHT.people_fully_vaccinated,
                          SELF.daily_vaccinations_raw:= RIGHT.daily_vaccinations_raw,
                          SELF.daily_vaccinations:= RIGHT.daily_vaccinations,
                          SELF:= LEFT), LEFT OUTER);                          

OUTPUT(appendUSDs(update_date > 20200315), , jhowid.worldFilePath, OVERWRITE, COMPRESSED);
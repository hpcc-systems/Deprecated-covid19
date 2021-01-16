IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 
IMPORT hpccsystems.covid19.file.public.OWID as owid; 

EXPORT JHOWID:= MODULE 
    
    EXPORT worldFilePath := '~hpccsystems::covid19::file::public::jhowid::world.flat';


    EXPORT Layout := RECORD
        jh.layout;
        UNSIGNED total_vaccinations;
        UNSIGNED people_vaccinated;
        UNSIGNED people_fully_vaccinated;
        UNSIGNED daily_vaccinations_raw;
        UNSIGNED daily_vaccinations;
    END;    

    EXPORT worldDs := DATASET(worldFilePath, Layout, flat);
    

END;  
IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 
IMPORT hpccsystems.covid19.file.public.OxCGRT as ox; 

EXPORT JHOxCGRT := MODULE 
    
    EXPORT worldFilePath := '~hpccsystems::covid19::file::public::jhoxcgrt::v1::world.flat';
    EXPORT usFilePath := '~hpccsystems::covid19::file::public::jhoxcgrt::v1::us.flat';

    EXPORT Layout := RECORD
       jh.layout;
       ox.layout;
    END;
    
    EXPORT worldDs := DATASET(worldFilePath, Layout, flat);
    EXPORT usDs := DATASET(usFilePath, Layout, flat);
END;    
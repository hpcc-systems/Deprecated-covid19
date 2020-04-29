IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh;
IMPORT Std;

world := DATASET('~hpccsystems::covid19::file::public::JohnHopkins::world.flat', jh.layout, THOR);  
us := DATASET('~hpccsystems::covid19::file::public::JohnHopkins::us.flat', jh.layout, THOR);  

world_cases := TABLE(world (update_date > 20200326), {update_date, country, total := SUM(GROUP, confirmed), REAL new_cases:= 0}, country, update_date);


OUTPUT(CHOOSEN(world_cases,10000),,NAMED('world'));
world_stats := JOIN(world_cases, world_cases, LEFT.country=RIGHT.country and LEFT.update_date=Std.Date.AdjustDate(RIGHT.update_date,0,0,1), 
                    TRANSFORM(RECORDOF(LEFT),
                              SELF.new_cases := LEFT.total-RIGHT.total,
                              SELF := LEFT), LEFT OUTER);
new_cases := SUM(world_stats (update_date=20200428), new_cases);

OUTPUT(new_cases,NAMED('new_cases'));

OUTPUT(CHOOSEN(world_stats,10000),,NAMED('world_new_cases_table'));
OUTPUT(CHOOSEN(TABLE(us (update_date > 20200426), {update_date, country, total := SUM(GROUP, confirmed)}, country, update_date),10000),,NAMED('us'));
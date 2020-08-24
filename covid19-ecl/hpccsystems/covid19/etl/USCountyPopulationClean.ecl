
IMPORT hpccsystems.covid19.file.raw.USCountyPopulation as popRaw;
IMPORT hpccsystems.covid19.file.public.USCountyPopulation as popClean;

IMPORT Std;

excluded := ['DUKES COUNTY' , 'NANTUCKET COUNTY'];

cleanedPop := PROJECT
    (
       popRaw.ds, 
       TRANSFORM
       (
         popClean.layout,
         SELF.FIPS := LEFT.STATE + LEFT.COUNTY,                        
         SELF.STATE := Std.Str.ToUpperCase(LEFT.STATE),
         SELF.COUNTY := Std.Str.ToUpperCase(LEFT.COUNTY),
         SELF.STNAME := Std.Str.ToUpperCase(LEFT.STNAME),
         SELF.CTYNAME := Std.Str.ToUpperCase(LEFT.CTYNAME),
         SELF.CENSUS2010POP   := (INTEGER) LEFT.CENSUS2010POP  ,
         SELF.POPESTIMATE2010 := (INTEGER) LEFT.POPESTIMATE2010,
         SELF.POPESTIMATE2011 := (INTEGER) LEFT.POPESTIMATE2011,
         SELF.POPESTIMATE2012 := (INTEGER) LEFT.POPESTIMATE2012,
         SELF.POPESTIMATE2013 := (INTEGER) LEFT.POPESTIMATE2013,
         SELF.POPESTIMATE2014 := (INTEGER) LEFT.POPESTIMATE2014,
         SELF.POPESTIMATE2015 := (INTEGER) LEFT.POPESTIMATE2015,
         SELF.POPESTIMATE2016 := (INTEGER) LEFT.POPESTIMATE2016,
         SELF.POPESTIMATE2017 := (INTEGER) LEFT.POPESTIMATE2017,
         SELF.POPESTIMATE2018 := (INTEGER) LEFT.POPESTIMATE2018,
         SELF.POPESTIMATE2019 := (INTEGER) LEFT.POPESTIMATE2019,
          ) 
    );       

//roll-up Bronx, Queens, Kings, Richmond and New York City as New York City. The FIPS code would be 36061. 
boroughNames := ['BRONX COUNTY', 'KINGS COUNTY', 'QUEENS COUNTY', 'RICHMOND COUNTY', 'NEW YORK COUNTY'];
boroughs := cleanedPop(state = '36' AND ctyname in boroughNames );

DUKESAndNANTUCKETPop := SUM(cleanedPop(ctyname  IN excluded),popestimate2019 );
DUKESAndNANTUCKETPop;

DUKESAndNANTUCKET := DATASET(1,
                             TRANSFORM(popClean.layout,
                             SELF.FIPS := '25007', 
                             SELF.state := '25',
                             SELF.stname := 'MASSACHUSETTS',
                             SELF.county := '007', 
                             SELF. ctyname := 'DUKES AND NANTUCKET',
                             SELF.popestimate2019 := DUKESAndNANTUCKETPop));

popClean.layout rollTrans(popClean.layout l, DATASET(popClean.layout) r) :=TRANSFORM
          SELF.FIPS            := r(ctyname = 'NEW YORK COUNTY')[1].FIPS,
          SELF.county          := r(ctyname = 'NEW YORK COUNTY')[1].county,
          SELF.ctyname         := r(ctyname = 'NEW YORK COUNTY')[1].ctyname,
          SELF.CENSUS2010POP   := SUM(R, CENSUS2010POP  ),
          SELF.POPESTIMATE2010 := SUM(R, POPESTIMATE2010),
          SELF.POPESTIMATE2011 := SUM(R, POPESTIMATE2011),
          SELF.POPESTIMATE2012 := SUM(R, POPESTIMATE2012),
          SELF.POPESTIMATE2013 := SUM(R, POPESTIMATE2013),
          SELF.POPESTIMATE2014 := SUM(R, POPESTIMATE2014),
          SELF.POPESTIMATE2015 := SUM(R, POPESTIMATE2015),
          SELF.POPESTIMATE2016 := SUM(R, POPESTIMATE2016),
          SELF.POPESTIMATE2017 := SUM(R, POPESTIMATE2017),
          SELF.POPESTIMATE2018 := SUM(R, POPESTIMATE2018),
          SELF.POPESTIMATE2019 := SUM(R, POPESTIMATE2019),
          SELF := L;
END;
NYCounty := ROLLUP(GROUP(boroughs, state), GROUP, rollTrans(LEFT, ROWS(LEFT)));

nonBoroughs := cleanedPop - boroughs;



OUTPUT(nonBoroughs(CTYNAME  NOT IN  excluded) + NYCounty + DUKESAndNANTUCKET ,,popclean.filePath, THOR, COMPRESSED, OVERWRITE);




// Clean poplulation data with age and gender info
cleanedPop_agegender := PROJECT
    (
       popRaw.ds_agegender(year = '11' AND AGEGRP <> '0'), 
       TRANSFORM
       (
         popClean.layout_agegender,
         SELF.YEAR := '2018',
         SELF.FIPS := LEFT.STATE + LEFT.COUNTY,                        
         SELF.STATE := Std.Str.ToUpperCase(LEFT.STATE),
         SELF.COUNTY := Std.Str.ToUpperCase(LEFT.COUNTY),
         SELF.STNAME := Std.Str.ToUpperCase(LEFT.STNAME),
         SELF.CTYNAME := Std.Str.ToUpperCase(LEFT.CTYNAME),
         SELF:= LEFT
          ) 
    );       

// OUTPUT(cleanedPop_agegender ,,popclean.filePath_agegender, THOR, COMPRESSED, OVERWRITE);





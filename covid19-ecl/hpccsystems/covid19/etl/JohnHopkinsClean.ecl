IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV1 as jhv1;
IMPORT hpccsystems.covid19.file.raw.JohnHopkinsV2 as jhv2;
IMPORT hpccsystems.covid19.file.public.JohnHopkins as jh; 

IMPORT Std; 

                                    // formattedDate := Std.Date.FromStringToDate(LEFT.last_update[..10], '%Y-%m-%d');
                                    // SELF.update_date := IF(formattedDate != 0, formattedDate, Std.Date.FromStringToDate(LEFT.last_update[..7], '%m/%d/%Y')),

v1CleanDs := PROJECT(jhv1.ds, 
                            TRANSFORM
                                (
                                    jh.layout,
                                    SELF.fips := '',
                                    SELF.admin2:= '';
                                    SELF.state := Std.Str.ToUpperCase(LEFT.state);
                                    SELF.country := Std.Str.ToUpperCase(LEFT.country);
                                    SELF.geo_lat := (DECIMAL9_6)LEFT.geo_lat,
                                    SELF.geo_long := (DECIMAL9_6)LEFT.geo_long,
                                    SELF.update_date := Std.Date.FromStringToDate(LEFT.last_update[..10], '%Y-%m-%d'),
                                    SELF.confirmed := (UNSIGNED4)LEFT.confirmed,
                                    SELF.deaths := (UNSIGNED4)LEFT.deaths,
                                    SELF.recovered := (UNSIGNED4)LEFT.recovered,
                                    SELF.active := 0,
                                    SELF.combined_key:= ''
                                )
      				    );  

v2CleanDs := PROJECT(jhv2.ds, 
                            TRANSFORM
                                (
                                    jh.layout,
                                    SELF.fips  := LEFT.fips,
                                    SELF.admin2 := Std.Str.ToUpperCase(LEFT.admin2), 
                                    SELF.state := Std.Str.ToUpperCase(LEFT.state),
                                    SELF.country := IF(LEFT.country='Korea, South','SOUTH KOREA',Std.Str.ToUpperCase(LEFT.country)),
                                    SELF.geo_lat := (DECIMAL9_6)LEFT.geo_lat,
                                    SELF.geo_long := (DECIMAL9_6)LEFT.geo_long,
                                    SELF.update_date := Std.Date.FromStringToDate(LEFT.last_update[..10], '%Y-%m-%d'),
                                    SELF.confirmed := (UNSIGNED4)LEFT.confirmed,
                                    SELF.deaths := (UNSIGNED4)LEFT.deaths,
                                    SELF.recovered := (UNSIGNED4)LEFT.recovered,
                                    SELF.active := (UNSIGNED4)LEFT.active,
                                    SELF.combined_key := Std.Str.ToUpperCase(LEFT.combined_key)
                                )
      				);  

clean := SORT(v2CleanDs + v1CleanDs, -update_date);

OUTPUT(clean,,jh.worldFilePath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(clean(country='US'),,jh.usFilePath, THOR, COMPRESSED, OVERWRITE);



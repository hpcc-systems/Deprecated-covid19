EXPORT WeeklyMetrics := MODULE
  
EXPORT statesPath := '~hpccsystems::covid19::file::public::metrics::weekly_by_state.flat';
EXPORT worldPath := '~hpccsystems::covid19::file::public::metrics::weekly_by_country.flat';
EXPORT countiesPath := '~hpccsystems::covid19::file::public::metrics::weekly_by_us_county.flat';  

export inputLayout := RECORD 
  string location;
  unsigned8 period;
  unsigned4 startdate;
  unsigned4 enddate;
  string istate;
  unsigned8 cases;
  unsigned8 deaths;
  unsigned8 active;
  decimal5_2 cr;
  decimal5_2 mr;
  decimal5_2 sdindicator;
  decimal5_2 medindicator;
  decimal6_3 heatindex;
  decimal5_3 imort;
  decimal5_2 immunepct;
  unsigned8 newcases;
  unsigned8 newdeaths;
  unsigned8 recovered;
  decimal5_2 cases_per_capita;
  decimal5_2 deaths_per_capita;
  decimal5_2 cmratio;
  decimal5_2 dcr;
  decimal5_2 dmr;
  decimal5_2 weekstopeak;
  unsigned8 perioddays;
  unsigned8 population;
END;

export layout := RECORD
    inputLayout;
    string parentLocation := '';//counties
END;

EXPORT GroupedLayout := RECORD
    string location;
    string locationstatus;
    unsigned8 period;
    unsigned4 startdate;
    unsigned4 enddate;
    unsigned8 perioddays;
    STRING50  measure := ''; 
    DECIMAL8_2     value := 0; 
END;

EXPORT LocationLayout := RECORD
    string location;
END;

EXPORT CatalogLayout := RECORD
    STRING50 id;
    STRING50 title;
end;  

EXPORT states := DATASET(statesPath, inputLayout, THOR);
EXPORT world := DATASET(worldPath, inputLayout, THOR); 
EXPORT counties := DATASET(countiesPath, inputLayout, THOR);


EXPORT statesGroupedPath := '~hpccsystems::covid19::file::public::metrics::states_grouped.flat';
EXPORT statesAllPath := '~hpccsystems::covid19::file::public::metrics::states_all.flat';
EXPORT statesLocationsCatalogPath := '~hpccsystems::covid19::file::public::metrics::states_locations_catalog.flat';
EXPORT statesDefaultLocationsPath := '~hpccsystems::covid19::file::public::metrics::states_locations_default.flat';
EXPORT statesPeriodsCatalogPath := '~hpccsystems::covid19::file::public::metrics::states_periods_catalog.flat';

EXPORT statesGrouped := DATASET(statesGroupedPath, GroupedLayout, THOR);
EXPORT statesAll := DATASET(statesAllPath, Layout, THOR);
EXPORT statesLocationsCatalog := DATASET(statesLocationsCatalogPath,CatalogLayout , THOR);
EXPORT statesDefaultLocations := DATASET(statesDefaultLocationsPath,LocationLayout, THOR);
EXPORT statesPeriodsCatalog := DATASET(statesPeriodsCatalogPath,CatalogLayout, THOR);


EXPORT worldGroupedPath := '~hpccsystems::covid19::file::public::metrics::world_grouped.flat';
EXPORT worldAllPath := '~hpccsystems::covid19::file::public::metrics::world_all.flat';
EXPORT worldLocationsCatalogPath := '~hpccsystems::covid19::file::public::metrics::world_locations_catalog.flat';
EXPORT worldDefaultLocationsPath := '~hpccsystems::covid19::file::public::metrics::world_locations_default.flat';
EXPORT worldPeriodsCatalogPath := '~hpccsystems::covid19::file::public::metrics::world_periods_catalog.flat';

EXPORT worldGrouped := DATASET(worldGroupedPath, GroupedLayout, THOR);
EXPORT worldAll := DATASET(worldAllPath, Layout, THOR);
EXPORT worldLocationsCatalog := DATASET(worldLocationsCatalogPath,CatalogLayout , THOR);
EXPORT worldDefaultLocations := DATASET(worldDefaultLocationsPath,LocationLayout, THOR);
EXPORT worldPeriodsCatalog := DATASET(worldPeriodsCatalogPath,CatalogLayout, THOR);


EXPORT countiesGroupedPath := '~hpccsystems::covid19::file::public::metrics::counties_grouped.flat';
EXPORT countiesAllPath := '~hpccsystems::covid19::file::public::metrics::counties_all.flat';
EXPORT countiesLocationsCatalogPath := '~hpccsystems::covid19::file::public::metrics::counties_locations_catalog.flat';
EXPORT countiesDefaultLocationsPath := '~hpccsystems::covid19::file::public::metrics::counties_locations_default.flat';
EXPORT countiesPeriodsCatalogPath := '~hpccsystems::covid19::file::public::metrics::counties_periods_catalog.flat';

EXPORT countiesGrouped := DATASET(countiesGroupedPath, GroupedLayout, THOR);
EXPORT countiesAll := DATASET(countiesAllPath, Layout, THOR);
EXPORT countiesLocationsCatalog := DATASET(countiesLocationsCatalogPath,CatalogLayout , THOR);
EXPORT countiesDefaultLocations := DATASET(countiesDefaultLocationsPath,LocationLayout, THOR);
EXPORT countiesPeriodsCatalog := DATASET(countiesPeriodsCatalogPath,CatalogLayout, THOR);



end;
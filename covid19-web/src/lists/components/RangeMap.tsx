import React, {useEffect, useRef, useState} from "react";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";
import OlRangeMap from "../../components/OlRangeMap";

interface RangeMapProps {
    locations: any;
    heatMapType: string;
    selectHandler: (name: string) => void;
}

const RangeMap = (props: RangeMapProps) => {
    const query = useRef(new QueryData('hpccsystems_covid19_query_range_map'));
    const [data, setData] = useState<any>(new Map());
    const [maxData, setMaxData] = useState<any>({});
    const [geoFileInfo, setGeoFileInfo] = useState<any>({});

    useEffect(() => {
        console.log("heat map type: " + props.heatMapType);
    }, [props.heatMapType])

    useEffect(() => {
        let filters = new Map();

        filters.set('level', props.locations.level);
        filters.set('level1_location', props.locations.level1);
        filters.set('level2_location', props.locations.level2);
        filters.set('level3_location', props.locations.level3);

        query.current.initData(filters).then(() => {
            let periodNewCasesMax = 0;
            let periodNewDeathsMax = 0;
            let casesPerCapitaMax = 0;
            let deathsPerCapitaMax = 0;
            let casesMax = 0;
            let deathsMax = 0;

            let data = query.current.getData('metrics');

            let mapData = new Map();
            data.forEach((item: any) => {
                let periodData = mapData.get(item.period);

                if (!periodData) {
                    let periodMap = new Map();
                    //console.log(item.period + " - Item period")
                    periodData = {"period": item.period_string, "map": periodMap}
                    mapData.set(item.period, {"period": item.period_string, "map": periodMap});
                }

                let locations;
                if (item.location_code) {
                    locations = item.location_code.split('-');
                } else {
                    locations = item.location.split('-');
                }

                periodData.map.set(locations[locations.length - 1], item);

                casesMax = item.cases > casesMax? item.cases: casesMax;
                deathsMax = item.deaths > deathsMax? item.deaths: deathsMax;
                periodNewCasesMax = item.period_new_cases > periodNewCasesMax? item.period_new_cases: periodNewCasesMax;
                periodNewDeathsMax = item.period_new_deaths > periodNewDeathsMax? item.period_new_deaths: periodNewDeathsMax;
                casesPerCapitaMax = item.cases_per_capita > casesPerCapitaMax? item.cases_per_capita: casesPerCapitaMax;
                deathsPerCapitaMax = item.deaths_per_capita > deathsPerCapitaMax? item.deaths_per_capita: deathsPerCapitaMax;
            });

            setData(mapData);

            setMaxData({"casesMax": casesMax,
                              "deathsMax": deathsMax,
                              "periodNewCasesMax": periodNewCasesMax,
                              "periodNewDeathsMax": periodNewDeathsMax,
                              "casesPerCapitaMax": casesPerCapitaMax,
                              "deathsPerCapitaMax": deathsPerCapitaMax})

            setGeoFileInfo(Catalog.maps.get(props.locations.location));

            console.log("Range map - " + props.locations.location);
        });

    }, [props.locations]);

    return (
        <div style={{overflow: 'auto'}}>


        </div>
    );
}

export default RangeMap;
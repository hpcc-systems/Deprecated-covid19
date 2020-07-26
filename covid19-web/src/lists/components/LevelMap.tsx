import React, {useEffect, useRef, useState} from "react";
import OlMap from "../../components/OlMap";


function useStateRef(initialValue) {
    const [value, setValue] = useState(initialValue);

    const ref = useRef(value);

    useEffect(() => {
        ref.current = value;
    }, [value]);

    return [value, setValue, ref];
}

export default function LevelMap(props) {

    const [heatMapType, setHeatMapType, heatMapTypeRef] = useStateRef('contagion_risk');
    const listData = useRef(new Map());

    useEffect(() => {
        listData.current = props.listData;
    }, [props]);

    function olToolTipHandler(name) {
        return "";
    }

    function olColorHandler(name) {
        if (!name) return '#a1a080';
        // let row = props.listData.get(name.toUpperCase());
        let row = listData.current.get(name.toUpperCase());
        if (row) {
            let d = 0;
            switch (heatMapTypeRef.current) {
                case 'cases':
                    d = row.cases / Math.max(1, props.maxData.cases_max);
                    break;
                case 'new_cases':
                    d = row.period_new_cases / Math.max(1, props.maxData.newCasesMax);
                    break;
                case 'deaths':
                    d = row.deaths / Math.max(1, props.maxData.deathsMax);
                    break;
                case 'new_deaths':
                    d = row.period_new_deaths / Math.max(1, props.maxData.newDeathsMax);
                    break;
                case 'cases_per_capita':
                    d = row.cases_per_capita / Math.max(1, props.maxData.casesPerCapitaMax);
                    console.log('cases per capita')
                    break;
                case 'deaths_per_capita':
                    d = row.deaths_per_capita / Math.max(1, props.maxData.deathsPerCapitaMax);
                    break;
                case 'contagion_risk':
                    d = row.contagion_risk;
                    return d >= 0.5 ? '#a50026' :
                        d >= 0.25 ? '#d73027' :
                            d >= 0.15 ? '#fdae61' :
                                d >= 0.05 ? '#fee08b' :
                                    d > 0.01 ? '#66bd63' :
                                        '#1a9850';
                case 'status':
                    d = row.status_numb;
                    if (d >= 6) {
                        return '#a50026'
                    } else if (d === 5) {
                        return '#d73027'
                    } else if (d === 4) {
                        return '#fdae61'
                    } else if (d === 3) {
                        return '#fee08b'
                    } else if (d === 2) {
                        return '#66bd63'
                    } else {
                        return '#1a9850'
                    }

            }

            return d >= 0.9 ? '#a50026' :
                d > 0.6 ? '#d73027' :
                    d > 0.4 ? '#fdae61' :
                        d > 0.2 ? '#fee08b' :
                            d > 0.1 ? '#66bd63' :
                                '#1a9850';
        } else return '#1a9850';
    }

    function olSelectHandler(name) {
        return "";
    }


    return (
        <OlMap toolTipHandler={(name) => olToolTipHandler(name)} colorHandler={(name) => olColorHandler(name)}
               selectHandler={(name) => olSelectHandler(name)} geoFile={'countries.geojson'} zoom={2}
               geoLat={0} geoLong={0} geoKeyField={'name'}
               secondaryGeoFile={''}
               height={'750px'}/>
    )
}

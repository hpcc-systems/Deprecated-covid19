import React, {useEffect, useRef, useState} from "react";
import OlMap from "../../components/OlMap";
import {Button, Layout, Popover, Radio, Tabs} from "antd";
import Catalog from "../../utils/Catalog";
import RangeMap from "./RangeMap";
import LevelList from "./LevelList";
import SummaryMeasures from "./SummaryMeasures";
import PeriodTrends from "./PeriodTrends";
import HotList from "./HotList";


function useStateRef(initialValue: any) {
    const [value, setValue] = useState(initialValue);

    const ref = useRef(value);

    useEffect(() => {
        ref.current = value;
    }, [value]);

    return [value, setValue, ref];
}

interface LevelMapProps {
    mapData: any;
    listData: any;
    maxData: any;
    locationAlias: string;
    selectHandler: (name: string) => void;
    location: string;
    levelLocations: any;
    summaryData: any;
    locationUUID: string;
    periodTrendsColumnData: any;
    periodTrendsGroupedData: any;
    hotListData: any;
}


const LevelMap = (props: LevelMapProps) => {

    const [heatMapType, setHeatMapType, heatMapTypeRef] = useStateRef('contagion_risk');
    const mapData = useRef(new Map());
    const maxData = useRef<any>([]);
    const [geoFileInfo, setGeoFileInfo] = useState<any>({});
    const [mapTabKey, setMapTabKey] = useState<string>("1");

    useEffect(() => {
        mapData.current = props.mapData;
        maxData.current = props.maxData;
        // setHeatMapType('contagion_risk');
    }, [props.mapData, props.maxData]);

    useEffect(() => {
        setGeoFileInfo(Catalog.maps.get(props.location));

        console.log('Location change ' + props.location);
    }, [props.location]);

    function olToolTipHandler(name: string) {
        let row = mapData.current.get(name.toUpperCase());
        //console.log('Tooltip Location ' + name.toUpperCase() + ' row - ' + row);
        if (row) {
            return makeTooltip(name, row);
        } else {
            return ""
        }
    }

    function rangeMap() {
        if (mapTabKey === "1") {
            return null;
        } else {
            return <RangeMap locations={props.levelLocations} heatMapType={heatMapType}/>;
        }
    }

    function olColorHandler(name: string) {
        if (!name) return '#a1a080';

        let row = mapData.current.get(name.toUpperCase());

        //console.log('Color location: ' + name.toUpperCase() +  ' -- ' + name.length + '  ' + row);

        if (row) {
            let d = 0;
            switch (heatMapTypeRef.current) {
                case 'cases':
                    d = row.cases / Math.max(1, maxData.current.cases_max);
                    break;
                case 'new_cases':
                    d = row.period_new_cases / Math.max(1, maxData.current.new_cases_max);
                    break;
                case 'deaths':
                    d = row.deaths / Math.max(1, maxData.current.deaths_max);
                    break;
                case 'new_deaths':
                    d = row.period_new_deaths / Math.max(1, maxData.current.new_deaths_max);
                    break;
                case 'cases_per_capita':
                    d = row.cases_per_capita / Math.max(1, 1000);
                    break;
                case 'deaths_per_capita':
                    d = row.deaths_per_capita / Math.max(1, 60);
                    break;
                case 'contagion_risk':
                    d = row.contagion_risk;
                    return d >= 0.5 ? '#a50026' :
                        d >= 0.25 ? '#d73027' :
                            d >= 0.15 ? '#fdae61' :
                                d >= 0.05 ? '#fee08b' :
                                    d > 0 ? '#66bd63' :
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
        } else return '#2b2b2b';
    }

    function olMeasureHandler(name: string) {
        if (!name) return '';

        let row = mapData.current.get(name.toUpperCase());

        //console.log('Color location: ' + name.toUpperCase() +  ' -- ' + name.length + '  ' + row);

        if (row) {
            let d = '';
            switch (heatMapTypeRef.current) {
                case 'cases':
                    d = formatNumber(row.cases);
                    break;
                case 'new_cases':
                    d = formatNumber(row.period_new_cases);
                    break;
                case 'deaths':
                    d = formatNumber(row.deaths);
                    break;
                case 'new_deaths':
                    d = formatNumber(row.period_new_deaths);
                    break;
                case 'cases_per_capita':
                    d = formatNumber(row.cases_per_capita);
                    break;
                case 'deaths_per_capita':
                    d = formatNumber(row.deaths_per_capita);
                    break;
                case 'contagion_risk':
                    d = Math.round(row.contagion_risk * 100) +
                        "%";
                    break;
                case 'status':
                    d = '' //d = row.status ;
            }

            return d;
        } else return '';
    }


    function olSelectHandler(name: string) {

        return props.selectHandler(name.toUpperCase());

    }

    const formatNumber: any = (value: any) => {
        if (value) {
            return value.toLocaleString();
        } else {
            return '0';
        }
    }

    const makeTooltip = (name: string, row: any): string => {
        return "<div style='padding: 5px; border: 1px solid black; background: darkslategray'><table style='color: whitesmoke;'>" +
            "<tr>" +
            "<td colspan='2' style='font-weight: bold'>"
            + row.location +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td>" +
            "Contagion Risk:" +
            "</td>" +
            "<td><b>" +
            Math.round(row.contagion_risk * 100) +
            "%</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td>" +
            "Infection State:" +
            "</td>" +
            "<td><b>" +
            row.status +
            "</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td>" +
            "R:" +
            "</td>" +
            "<td><b>" +
            row.r +
            "</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td >" +
            "Weekly New Cases:" +
            "</td>" +
            "<td><b>" +
            formatNumber(row.period_new_cases) +
            "</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td style='padding-right: 10px'>" +
            "Weekly New Deaths:" +
            "</td>" +
            "<td><b>" +
            formatNumber(row.period_new_deaths) +
            "</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td>" +
            "Total Cases:" +
            "</td>" +
            "<td><b>" +
            formatNumber(row.cases) + '  (' + row.cases_per_capita + ' per 100K)' +
            "</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td>" +
            "Total Deaths:" +
            "</td>" +
            "<td><b>" +
            formatNumber(row.deaths) + '  (' + row.deaths_per_capita + ' per 100K)' +
            "</b></td>" +
            "</tr>" +
            "<tr>" +
            "<td colspan='2' style='font-style: italic;color: black'>"
            + "Please click on the map for more details" +
            "</td>" +
            "</tr>" +
            "</table></div>"
    }


    //Scale
    const renderScaleTitle = () => {
        switch (heatMapType) {
            case 'cases':
                return 'Legend for Total Cases';
            case 'deaths':
                return 'Legend for Total Deaths';
            case 'new_cases':
                return 'Legend for New Cases';
            case 'new_deaths':
                return 'Legend for New Deaths';
            case 'cases_per_capita':
                return 'Legend for Cases/100K';
            case 'deaths_per_capita':
                return 'Legend for Deaths/100K';
            case 'status':
                return 'Legend for Infection State';
            default:
                return '';
        }
    }

    const renderScale = () => {

        function contagionScale() {
            return <div style={{width: 250, paddingLeft: 10}}>
                <table>
                    <tbody>
                    <tr style={{}}>
                        <td>LT 1 %</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#1a9850"}}/>
                        </td>
                    </tr>
                    <tr style={{}}>
                        <td>1-4 %</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#66bd63"}}/>
                        </td>
                    </tr>
                    <tr style={{}}>
                        <td>5-15 %</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fee08b"}}/>
                        </td>
                    </tr>
                    <tr style={{}}>
                        <td>15-24 %</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fdae61"}}/>
                        </td>
                    </tr>
                    <tr style={{}}>
                        <td>25-50 %</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#d73027"}}/>
                        </td>
                    </tr>
                    <tr style={{}}>
                        <td>GT or = 50 %</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#a50026"}}/>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        }

        function statusScale() {

            return <div style={{width: 250, paddingLeft: 10}}>
                <table cellPadding={5}>
                    <tbody>
                    <tr style={{}}>
                        <td>Initial or Recovered</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#1a9850"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>Recovering</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#66bd63"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>Stabilized</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fee08b"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>Stabilizing</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fdae61"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>Emerging</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#d73027"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>Spreading</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#a50026"}}/>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        }

        function format(d: number) {
            return Math.trunc(d).toLocaleString();
        }


        function statsScale(d: number, label: string) {
            return <div style={{width: 250, paddingLeft: 10}}>
                <table cellPadding={5}>
                    <tbody>
                    <tr style={{}}>
                        <td>Less than {format(d * 0.1)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#1a9850"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.1 + 1)} to {format(d * 0.2)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#66bd63"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.2 + 1)} to {format(d * 0.4)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fee08b"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.4 + 1)} to {format(d * 0.6)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fdae61"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.6 + 1)} to {format(d * 0.9)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#d73027"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>Greater than {format(d * 0.9)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#a50026"}}/>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        }


        switch (heatMapType) {
            case 'cases':
                return statsScale(maxData.current.cases_max, 'Cases');
            case 'new_cases':
                return statsScale(maxData.current.new_cases_max, 'New Cases');
            case 'deaths':
                return statsScale(maxData.current.deaths_max, 'Deaths');
            case 'new_deaths':
                return statsScale(maxData.current.new_deaths_max, 'New Deaths');
            case 'cases_per_capita':
                return statsScale(1000, 'Cases/100K');
            case 'deaths_per_capita':
                return statsScale(60, 'Deaths/100K');
            case 'status':
                return statusScale()
            case 'contagion_risk':
                return contagionScale()
        }
    }

    //console.log(props.location + ' - ' + props.mapData.size );

    if (mapData.current.size !== 0 && geoFileInfo) {
        return (

            <Layout>
                <Layout.Content>

                    <div style={{fontSize: 16, fontWeight: 'bold', paddingBottom: 5}}>Maps</div>
                    <Radio.Group onChange={(e) => setHeatMapType(e.target.value)}
                                 value={heatMapType} buttonStyle="outline" style={{fontSize: 11, fontWeight: "bold"}}>

                        <Radio.Button value={'contagion_risk'}>Contagion Risk</Radio.Button>
                        <Radio.Button value={'status'}>Infection State</Radio.Button>
                        <Radio.Button value={'new_cases'}>Weekly New Cases</Radio.Button>
                        <Radio.Button value={'new_deaths'}>Weekly New Deaths</Radio.Button>
                        <Radio.Button value={'cases_per_capita'}>Cases/100K</Radio.Button>
                        <Radio.Button value={'deaths_per_capita'}>Deaths/100K</Radio.Button>
                        <Radio.Button value={'cases'}>Cases</Radio.Button>
                        <Radio.Button value={'deaths'}>Deaths</Radio.Button>
                        <Popover content={renderScale()} title={renderScaleTitle()}>
                            <Button type={"link"}>Legend</Button>
                        </Popover>
                    </Radio.Group>

                    <div style={{height: 5}}/>

                    <Tabs defaultActiveKey="1" onChange={(key) => setMapTabKey(key)}>
                        <Tabs.TabPane tab="Current" key="1">
                            <div style={{fontSize: 14, fontWeight: 'bold', paddingBottom: 7}}>Zoom to view more details
                                or click on a location to view details.
                            </div>
                            <OlMap toolTipHandler={(name) => olToolTipHandler(name)}
                                   colorHandler={(name) => olColorHandler(name)}
                                   measureHandler={(name) => olMeasureHandler(name)}
                                   selectHandler={(name) => olSelectHandler(name)} geoFile={geoFileInfo.file}
                                   zoom={geoFileInfo.zoom}
                                   geoLat={geoFileInfo.lat} geoLong={geoFileInfo.long}
                                   colorKeyField={geoFileInfo.colorKeyField}
                                   selectKeyField={geoFileInfo.selectKeyField}
                                   secondaryGeoFile={geoFileInfo.secondaryFile}
                                   height={'800px'}/>
                            <div id={"list"} style={{height: 5}}/>
                            <LevelList data={props.listData} location={props.locationUUID}
                                       selectHandler={(name) => olSelectHandler(name)}/>
                            <div id={"summary_stats"} style={{height: 10}}/>
                            <SummaryMeasures summaryData={props.summaryData}/>

                            <div id={"trends"} style={{height: 10}}/>
                            <PeriodTrends columnData={props.periodTrendsColumnData}
                                          groupedData={props.periodTrendsGroupedData}/>
                            <div id={"hot_spots"} style={{height: 10}}/>
                            <HotList data={props.hotListData} selectHandler={(name) => olSelectHandler(name)}/>
                        </Tabs.TabPane>

                        <Tabs.TabPane tab="Historical" key="2">
                            {rangeMap()}
                        </Tabs.TabPane>
                    </Tabs>

                </Layout.Content>


            </Layout>

        )
    } else {
        return (<Layout>
                <div id={"list"} style={{height: 5}}/>
                <LevelList data={props.listData} location={props.locationUUID}
                           selectHandler={(name) => olSelectHandler(name)}/>
                <div id={"summary_stats"} style={{height: 10}}/>
                <SummaryMeasures summaryData={props.summaryData}/>

                <div id={"trends"} style={{height: 10}}/>
                <PeriodTrends columnData={props.periodTrendsColumnData} groupedData={props.periodTrendsGroupedData}/>
                <div id={"hot_spots"} style={{height: 10}}/>
                <HotList data={props.hotListData} selectHandler={(name) => olSelectHandler(name)}/>
            </Layout>
        );
    }
}

export default LevelMap;

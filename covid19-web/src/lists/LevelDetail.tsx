import React, {useEffect, useRef, useState} from "react";
import {Button, Layout, Popover, Radio, Select as DropdownSelect, Skeleton, Space, Tabs} from "antd";
import {QueryData} from "../components/QueryData";
import {
    CaretLeftFilled,
    CaretRightFilled,
    LeftCircleFilled,
    LeftOutlined,
    PauseCircleFilled,
    RightCircleFilled,
    StepBackwardFilled,
    StepForwardFilled
} from '@ant-design/icons';
import MetricsTerms from "./MetricsTerms";
import Catalog from "../utils/Catalog";
import useStateRef from "../utils/UseStateRef";
import OlRangeMap from "../components/OlRangeMap";
import PeriodTrends from "./components/PeriodTrends";
import SummaryMeasures from "./components/SummaryMeasures";
import HotList from "./components/HotList";
import LevelList from "./components/LevelList";
import TextArea from "antd/es/input/TextArea";
import VaccineMeasures from "./components/VaccineMeasures";


const LevelDetail = () => {
    const queryLocation = useRef(new QueryData('hpccsystems_covid19_query_location_map'));
    const queryRange = useRef(new QueryData('hpccsystems_covid19_query_range_map'));

    const [location, setLocation] = useState<string>('');
    const locationStack = useRef<any>([]);

    //Data
    const [summaryData, setSummaryData] = useState<any>([]);
    const [maxData, setMaxData] = useState<any>([]);
    const [listData, setListData] = useState<any>([]);
    const [mapData, setMapData] = useState<any>(new Map());
    const [mapSummary, setMapSummary] = useState<any>(new Map());
    const [periodTrendsColumnData, setPeriodTrendsColumnData] = useState<any>([]);
    const [periodTrendsGroupedData, setPeriodTrendsGroupedData] = useState<any>([]);
    const [hotListData, setHotListData] = useState<any>([]);
    const [loading, setLoading] = useState<boolean>(true);
    const [locationUUID, setLocationUUID] = useState<string>('');
    const [geoFileInfo, setGeoFileInfo] = useState<any>({});
    const [heatMapType, setHeatMapType] = useState('contagion_risk');
    const [period, setPeriod, periodRef] = useStateRef("");
    const [timerOn, setTimerOn, timerOnRef] = useStateRef(false);

    const scrollLayout = useRef<any | null>(null);

    useEffect(() => {
        setLocation("THE WORLD");
        setPeriod("1");
    }, [setPeriod])

    useEffect(() => {
        function getLocationUUID() {
            let uuid: string = 'THE WORLD';
            if (locationStack.current.length >= 1) {
                uuid += '-' + locationStack.current[0];
            }
            if (locationStack.current.length >= 2) {
                uuid += '-' + locationStack.current[1];
            }
            if (locationStack.current.length >= 3) {
                uuid += '-' + locationStack.current[2];
            }
            return uuid;
        }

        if (!location) return;


        let filters = new Map();

        filters.set('level', locationStack.current.length + 1);
        if (locationStack.current.length >= 1)
            filters.set('level1_location', locationStack.current[0]);
        if (locationStack.current.length >= 2)
            filters.set('level2_location', locationStack.current[1]);
        if (locationStack.current.length >= 3)
            filters.set('level3_location', locationStack.current[2]);

        queryRange.current.initData(filters).then(() => {
            let periodNewCasesMax = 0;
            let periodNewDeathsMax = 0;
            let casesPerCapitaMax = 0;
            let deathsPerCapitaMax = 0;
            let casesMax = 0;
            let deathsMax = 0;

            let metrics = queryRange.current.getData('metrics');
            let summary = queryRange.current.getData('summary');

            let mapData = new Map();
            metrics.forEach((item: any) => {
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

                casesMax = item.cases > casesMax ? item.cases : casesMax;
                deathsMax = item.deaths > deathsMax ? item.deaths : deathsMax;
                periodNewCasesMax = item.period_new_cases > periodNewCasesMax ? item.period_new_cases : periodNewCasesMax;
                periodNewDeathsMax = item.period_new_deaths > periodNewDeathsMax ? item.period_new_deaths : periodNewDeathsMax;
                casesPerCapitaMax = item.cases_per_capita > casesPerCapitaMax ? item.cases_per_capita : casesPerCapitaMax;
                deathsPerCapitaMax = item.deaths_per_capita > deathsPerCapitaMax ? item.deaths_per_capita : deathsPerCapitaMax;
            });

            let mapSummary = new Map();
            summary.forEach((item: any) => {
                mapSummary.set(item.period, item.commentary);
            });

            //console.log("Map - " + getLocationUUID());
            setMaxData({
                "casesMax": casesMax,
                "deathsMax": deathsMax,
                "periodNewCasesMax": periodNewCasesMax,
                "periodNewDeathsMax": periodNewDeathsMax,
                "casesPerCapitaMax": casesPerCapitaMax,
                "deathsPerCapitaMax": deathsPerCapitaMax
            })

            setMapData(mapData);
            setMapSummary(mapSummary);

            setGeoFileInfo(Catalog.maps.get(getLocationUUID()));

            console.log("cases max: " + casesMax);
            console.log("cases max: " + deathsMax);
            console.log("cases max: " + periodNewCasesMax);


        });

    }, [location]);


    useEffect(() => {
        if (period.length === 0) return;

        function getLocationUUID() {
            let uuid: string = 'THE WORLD';
            if (locationStack.current.length >= 1) {
                uuid += '-' + locationStack.current[0];
            }
            if (locationStack.current.length >= 2) {
                uuid += '-' + locationStack.current[1];
            }
            if (locationStack.current.length >= 3) {
                uuid += '-' + locationStack.current[2];
            }
            return uuid;
        }

        setLoading(true);

        //Get the data
        let filters = new Map();
        filters.set('period', period);

        filters.set('level', locationStack.current.length + 1);
        if (locationStack.current.length >= 1)
            filters.set('level1_location', locationStack.current[0]);
        if (locationStack.current.length >= 2)
            filters.set('level2_location', locationStack.current[1]);
        if (locationStack.current.length >= 3)
            filters.set('level3_location', locationStack.current[2]);//NOTE: This is the max level supported. For US, it is the county level
        queryLocation.current.initData(filters).then(() => {
            let summary = queryLocation.current.getData('summary');

            if (summary.length > 0) {

                summary.forEach((item: any) => {
                    setSummaryData(item);
                });

            }


            let list = queryLocation.current.getData('list');

            setListData(list);//The list only shown if there is no map
            setPeriodTrendsColumnData(queryLocation.current.getData('period_trend_column'));
            setPeriodTrendsGroupedData(queryLocation.current.getData('period_trend_grouped'));
            setHotListData(queryLocation.current.getData('hot_list'));

            setLocationUUID(getLocationUUID());


            setLoading(false);

        })

    }, [period, location]);


    const pushLocation = (location: any) => {

        locationStack.current.push(location);
        setLocation(location);

    }

    const popLocation = () => {
        console.log("Pop location: " + locationStack.current[locationStack.current.length - 1]);

        locationStack.current.pop();
        if (locationStack.current.length === 0) {
            setLocation("THE WORLD");
        } else {

            setLocation(locationStack.current[locationStack.current.length - 1]);
        }

    }

    function selectHandler(name: string) {
        console.log('location selection ' + name.toUpperCase());

        pushLocation(name.toUpperCase());
    }

    const renderPeriodSelectors = () => {
        const items: any = [];
        mapData.forEach((value: any, key: any, map: any) => {
            //console.log(key);
            items.push(<DropdownSelect.Option key={key} value={key}>{value.period}</DropdownSelect.Option>);
        });

        if (items.length === 0) {
            items.push(<DropdownSelect.Option key={"1"} value={"1"}>Loading...</DropdownSelect.Option>);
        }
        return items;
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
                return statsScale(maxData.casesMax, 'Cases');
            case 'new_cases':
                return statsScale(maxData.periodNewCasesMax, 'New Cases');
            case 'deaths':
                return statsScale(maxData.deathsMax, 'Deaths');
            case 'new_deaths':
                return statsScale(maxData.periodNewDeathsMax, 'New Deaths');
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


    const nextPeriod = () => {
        let p = period.valueOf();
        p++;
        if (mapData.get(p.toString())) {
            setPeriod(p.toString());
            //props.periodHandler(p.toString());
        }
    }

    const previousPeriod = () => {
        let p = period.valueOf();
        p--;
        if (mapData.get(p.toString())) {
            setPeriod(p.toString());
            //props.periodHandler(p.toString());
        }
    }

    function sleep(ms: number) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async function pause() {
        setTimerOn(false);
    }

    async function forward() {
        setTimerOn(true);
        await playPeriods();
        setTimerOn(false);
    }

    async function backward() {
        setTimerOn(true);
        await playPeriodsReverse();
        setTimerOn(false);
    }

    async function playPeriods() {
        let p = periodRef.current.valueOf();
        p--;
        if (mapData.get(p.toString())) {
            setPeriod(p.toString());
            //props.periodHandler(p.toString());
            await sleep(1000);
            if (timerOnRef.current) {
                await playPeriods();
            }
        }
    }

    async function playPeriodsReverse() {
        let p = periodRef.current.valueOf();
        p++;
        if (mapData.get(p.toString())) {
            setPeriod(p.toString());
            //props.periodHandler(p.toString());
            await sleep(1000);
            if (timerOnRef.current) {
                await playPeriodsReverse();
            }
        }
    }

    function startPeriod() {
        setPeriod((mapData.size).toString());
        //props.periodHandler((props.data.size).toString());
    }

    function endPeriod() {
        setPeriod("1");
        //props.periodHandler("1");
    }

    function summary(period: string) {
        if (mapSummary.get(period)) {
            return mapSummary.get(period);
        } else {
            return "Loading...";
        }
    }

    return (
        <Layout>
            <div style={{textAlign: "center"}}>

                <Button href={"#commentary"} type={"link"} className={"anchor-btn"}>Commentary/Top</Button>
                <Button href={"#map"} type={"link"} className={"anchor-btn"}>Map</Button>
                <Button href={"#summary_stats"} type={"link"} className={"anchor-btn"}>Stats</Button>
                <Button href={"#trends"} type={"link"} className={"anchor-btn"}>Trends</Button>
                <Button href={"#hot_spots"} type={"link"} className={"anchor-btn"}>Hot Spots</Button>
                <Popover key={'popover_metrics_terms'} title={"Metrics Terms"} content={<MetricsTerms/>}
                         trigger={"click"}><Button type={"link"} className={"anchor-btn"}>METRICS
                    TERMS</Button></Popover>

                <Button onClick={() => popLocation()} style={{height: 25}} icon={<LeftOutlined/>}
                        shape={"round"} type={"primary"} className={"anchor-btn"}
                        disabled={locationStack.current.length === 0}>{"BACK"}</Button>
            </div>
            <div style={{paddingLeft: 10, paddingBottom: 10, fontSize: 16, fontWeight: 'bold'}}>
                <Space>
                    {locationUUID}
                    <DropdownSelect value={period} style={{width: 300, paddingTop: 2}}
                                    onChange={(value) => setPeriod(value)} loading={loading}>
                        {renderPeriodSelectors()}
                    </DropdownSelect>
                    <Button title={"Previous Period"} disabled={timerOn || (period === (mapData.size).toString())}
                            shape="circle" icon={<LeftCircleFilled/>}
                            onClick={() => nextPeriod()}/>
                    <Button title={"Next Period"} disabled={timerOn || (period === "1")} shape="circle"
                            icon={<RightCircleFilled/>}
                            onClick={() => previousPeriod()}/>
                    <Button title={"First Period"} disabled={timerOn} icon={<StepBackwardFilled/>}
                            onClick={() => startPeriod()}/>
                    <Button title={"Play Reverse"} disabled={timerOn || (period === (mapData.size).toString())}
                            icon={<CaretLeftFilled/>}
                            onClick={() => backward()}/>
                    <Button title={"Play Forward"} disabled={timerOn || (period === "1")} icon={<CaretRightFilled/>}
                            onClick={() => forward()}/>
                    <Button title={"Pause"} disabled={!timerOn} icon={<PauseCircleFilled/>} onClick={() => pause()}/>
                    <Button title={"Last/Current Period"} disabled={timerOn} icon={<StepForwardFilled/>}
                            onClick={() => endPeriod()}/>
                </Space>
            </div>
            <div style={{overflow: 'auto', paddingLeft: 10, paddingRight: 10, paddingTop: 10}}
                 ref={(e) => (scrollLayout.current = e)}>
                {/*<Spin spinning={loading} delay={250}>*/}
                <div id={"commentary"} style={{height: 0}}/>
                <TextArea rows={4} style={{fontSize: 14}} value={summary(period)} readOnly={true}/>

                <Layout.Content>
                    <div id={"map"}/>
                    {geoFileInfo &&
                    <Tabs>

                        <Tabs.TabPane tab={"Map"} key={"Map"}>
                            <Radio.Group onChange={(e) => setHeatMapType(e.target.value)}
                                         value={heatMapType} buttonStyle="outline"
                                         style={{fontSize: 11, fontWeight: "bold"}}>

                                <Radio.Button value={'contagion_risk'}>Contagion Risk</Radio.Button>
                                <Radio.Button value={'status'}>Infection State</Radio.Button>
                                <Radio.Button value={'new_cases'}>Weekly New Cases</Radio.Button>
                                <Radio.Button value={'new_deaths'}>Weekly New Deaths</Radio.Button>
                                <Radio.Button value={'cases_per_capita'}>Cases/100K</Radio.Button>
                                <Radio.Button value={'deaths_per_capita'}>Deaths/100K</Radio.Button>
                                <Radio.Button value={'cases'}>Cases</Radio.Button>
                                <Radio.Button value={'deaths'}>Deaths</Radio.Button>
                                <Radio.Button value={'vaccine_percent_complete'}>% Population Vaccinated</Radio.Button>
                                <Popover content={renderScale()} title={renderScaleTitle()}>
                                    <Button type={"link"}>Legend</Button>
                                </Popover>
                            </Radio.Group>

                            <div style={{height: 5}}/>

                            <OlRangeMap geoFile={geoFileInfo.file}
                                        geoLat={geoFileInfo.lat}
                                        geoLong={geoFileInfo.long}
                                        selectKeyField={geoFileInfo.selectKeyField}
                                        colorKeyField={geoFileInfo.colorKeyField}
                                        zoom={geoFileInfo.zoom}
                                        height={'800px'} data={mapData} heatMapType={heatMapType} maxData={maxData}
                                        selectHandler={(name) => selectHandler(name)}
                                        period={period}/>

                        </Tabs.TabPane>
                        <Tabs.TabPane tab={"Data"} key={"Data"}>
                            <Skeleton loading={timerOn}>
                                <LevelList data={listData} location={locationUUID}
                                           selectHandler={(name) => selectHandler(name)}/>
                            </Skeleton>
                        </Tabs.TabPane>


                    </Tabs>
                    }

                    {!geoFileInfo &&
                        <Skeleton loading={timerOn}>
                            <LevelList data={listData} location={locationUUID}
                                       selectHandler={(name) => selectHandler(name)}/>
                        </Skeleton>
                    }

                    <div id={"trends"} style={{height: 10}}/>
                    <PeriodTrends columnData={periodTrendsColumnData} groupedData={periodTrendsGroupedData}/>
                    <div id={"summary_stats"} style={{height: 10}}/>
                    <SummaryMeasures summaryData={summaryData}/>
                    <div id={"vaccine_stats"} style={{height: 10}}/>
                    <VaccineMeasures summaryData={summaryData}/>
                    <div id={"hot_spots"} style={{height: 10}}/>
                    <Skeleton loading={timerOn}>
                        <HotList data={hotListData} selectHandler={(name) => selectHandler(name)}/>
                    </Skeleton>
                </Layout.Content>


                {/*</Spin>*/}
            </div>


        </Layout>

    );


}

export default LevelDetail;


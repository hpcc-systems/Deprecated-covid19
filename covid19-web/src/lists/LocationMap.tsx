import React, {useEffect, useRef, useState} from 'react'

import {Button, Col, Descriptions, Layout, PageHeader, Popover, Radio, Row, Space} from "antd";
import {QueryData} from "../components/QueryData";
import OlMap from "../components/OlMap";
import LocationDetails from "./LocationDetails";
import MetricsTerms from "./MetricsTerms";


interface LocationMapProps {
    title: string;
    description: string;
    geoFile: string;
    geoLat: number;
    geoLong: number;
    geoKeyField: string;
    zoom: number;
    type: string;
}


class SummaryData {
    newCases: number = 0;
    newDeaths: number = 0;
    cases: number = 0;
    deaths: number = 0;
    recovered: number = 0;
    active: number = 0;
    casesMax: number = 0;
    newCasesMax: number = 0;
    deathsMax: number = 0;
    newDeathsMax: number = 0;
    statusMax: number = 0;
    casesPerCapitaMax: number = 0;
    deathsPerCapitaMax: number = 0;
    commentary: string = '';
}

function useStateRef(initialValue: any) {
    const [value, setValue] = useState(initialValue);

    const ref = useRef(value);

    useEffect(() => {
        ref.current = value;
    }, [value]);

    return [value, setValue, ref];
}

export default function LocationMap(props: LocationMapProps) {
    const queryLocationsMap = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_countries_map'));
    const [summaryDataState, setSummaryData, summaryData] = useStateRef(new SummaryData());
    const mapData = useRef<Map<string, any>>(new Map());
    const [heatMapType, setHeatMapType, heatMapTypeRef] = useStateRef('status');

    const [toolTipRow, setToolTipRow] = useState<any>([]);
    const [tooltipVisible, setTooltipVisible] = useState<boolean>(false);


    const [showLocationDetails, setShowLocationDetails] =
        useState<any>({visible: false, location: '', locationType: ''});


    function toMapData(data: any) {
        let mapData: Map<string, any> = new Map();

        if (data) {
            data.forEach((item: any) => {
                mapData.set(item.location_code, item);
            })
        }
        return mapData;
    }

    const mount = () => {
        let queryName = 'hpccsystems_covid19_query_' + props.type + '_map';

        queryLocationsMap.current = new QueryData(queryName);
        queryLocationsMap.current.initData(undefined).then(() => {
            mapData.current = toMapData(queryLocationsMap.current.getData('latest'));
            let summary = queryLocationsMap.current.getData('summary');

            if (summary.length > 0) {

                summary.forEach((item: any) => {
                    let summaryData = new SummaryData();
                    summaryData.newCases = item.new_cases_total;
                    summaryData.newDeaths = item.new_deaths_total;
                    summaryData.cases = item.cases_total;
                    summaryData.active = item.active_total;
                    summaryData.deaths = item.deaths_total;
                    summaryData.recovered = item.recovered_total;
                    summaryData.casesMax = item.cases_max;
                    summaryData.newCasesMax = item.new_cases_max;
                    summaryData.deathsMax = item.deaths_max;
                    summaryData.newDeathsMax = item.new_deaths_max;
                    summaryData.statusMax = item.status_max;
                    summaryData.casesPerCapitaMax = item.cases_per_capita_max;
                    summaryData.deathsPerCapitaMax = item.deaths_per_capita_max;
                    summaryData.commentary = item.commentary;
                    setSummaryData(summaryData);
                })
            } else {
                return '';
            }
        })

        const unmount = () => {
            console.log('unmounted')
            // ...
        }
        return unmount
    }

    useEffect((mount),[]);


    const heatMapTypeChange = (value: any) => {
        setHeatMapType(value);
    }

    const olToolTipHandler = (name: string) => {
        let row: any = mapData.current.get(name.toUpperCase());
        if (row) {
            setToolTipRow(row);
            setTooltipVisible(true);
        } else {
            setToolTipRow([]);
            setTooltipVisible(false);
        }

        return '';
    }
    const formatNumber: any = (value: any) => {
        if (value) {
            return value.toLocaleString();
        } else {
            return '0';
        }
    }

    const renderScaleTitle = () => {
        switch (heatMapType) {
            case 'cases': return 'Legend for Total Cases';
            case 'deaths': return 'Legend for Total Deaths';
            case 'new_cases': return 'Legend for New Cases';
            case 'new_deaths': return 'Legend for New Deaths';
            case 'cases_per_capita': return 'Legend for Cases/100K';
            case 'deaths_per_capita': return 'Legend for Deaths/100K';
            case 'status': return 'Legend for Spreading Model';
            default: return '';
        }
    }

    const renderScale = () => {
        function statusScale() {

            return <div style={{width: 250, paddingLeft: 10}}>
                <table cellPadding={5}>
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
                </table>
            </div>
        }

        function format(d: number) {
            return Math.trunc(d).toLocaleString();
        }

        function statsScale(d: number, label: string) {
            return <div style={{width: 250, paddingLeft: 10}}>
                <table cellPadding={5}>
                    <tr style={{}}>
                        <td>Less than {format(d * 0.1)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#1a9850"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.1 + 1)}  to  {format(d * 0.2)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#66bd63"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.2 + 1)}  to  {format(d * 0.4)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fee08b"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.4 + 1)}  to  {format(d * 0.6)}</td>
                        <td>
                            <div style={{width: 20, height: 20, background: "#fdae61"}}/>
                        </td>
                    </tr>
                    <tr>
                        <td>{format(d * 0.6 + 1)}  to  {format(d * 0.9)}</td>
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

                </table>
            </div>
        }


        switch (heatMapType) {
            case 'cases':
                return statsScale(summaryData.current.casesMax, 'Cases');
            case 'new_cases':
                return statsScale(summaryData.current.newCasesMax, 'New Cases');
            case 'deaths':
                return statsScale(summaryData.current.deathsMax, 'Deaths');
            case 'new_deaths':
                return statsScale(summaryData.current.newDeathsMax, 'New Deaths');
            case 'cases_per_capita':
                return statsScale(summaryData.current.casesPerCapitaMax, 'Cases/100K');
            case 'deaths_per_capita':
                return statsScale(summaryData.current.deathsPerCapitaMax, 'Deaths/100K');
            case 'status':
                return statusScale()
        }

    }

    const renderToolTipHeader = () => {
        let row: any = toolTipRow;
        if (row) {
            return row.location
        } else {
            return ''
        }
    }

    const renderOptionalValue= (value: any) => {
        if (value) {
            return '(' + value + ' per 100K)'
        } else {
            return ''
        }
    }

    const renderToolTip = () => {
        let row: any = toolTipRow;
        if (row) {

            return <div style={{width: 400, paddingLeft: 10}}>
                <Row>
                    <Col span={10}><b>Daily Stats</b></Col>
                    <Col><b>{row.date_string}</b></Col>
                </Row>
                <div style={{height: 20}}/>
                <Row>
                    <Col span={10}>New Cases</Col>
                    <Col span={4}><b>{formatNumber(row.new_cases)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>New Deaths</Col>
                    <Col><b>{formatNumber(row.new_deaths)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Active</Col>
                    <Col><b>{formatNumber(row.active)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Recovered</Col>
                    <Col><b>{formatNumber(row.recovered)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Total Cases</Col>
                    <Col><b>{formatNumber(row.cases)} {renderOptionalValue(row.cases_per_capita)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Total Deaths</Col>
                    <Col><b>{formatNumber(row.deaths)} {renderOptionalValue(row.deaths_per_capita)}</b></Col>
                </Row>

                <div style={{height: 20}}/>

                <Row>
                    <Col span={10}><b>Weekly Metrics</b></Col>
                    <Col><b>{row.period_string}</b></Col>
                </Row>
                <div style={{height: 20}}/>
                <Row>
                    <Col span={10}>Weekly New Cases</Col>
                    <Col span={4}><b>{formatNumber(row.period_new_cases)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Weekly New Deaths</Col>
                    <Col><b>{formatNumber(row.period_new_deaths)}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Infection Rate (R)</Col>
                    <Col><b>{row.r}</b></Col>
                </Row>
                <Row>
                    <Col span={10}>Status</Col>
                    <Col><b>{row.status}</b></Col>
                </Row>
            </div>

        } else {

        }
    }

    const olColorHandler = (name: string) => {
        if (!name) return '#a1a080';
        let row: any = mapData.current.get(name.toUpperCase());

        if (row) {
            let d = 0;
            switch (heatMapTypeRef.current) {
                case 'cases':
                    d = row.cases / Math.max(1, summaryData.current.casesMax);
                    break;
                case 'new_cases':
                    d = row.period_new_cases / Math.max(1, summaryData.current.newCasesMax);
                    break;
                case 'deaths':
                    d = row.deaths / Math.max(1, summaryData.current.deathsMax);
                    break;
                case 'new_deaths':
                    d = row.period_new_deaths / Math.max(1, summaryData.current.newDeathsMax);
                    break;
                case 'cases_per_capita':
                    d = row.cases_per_capita / Math.max(1, summaryData.current.casesPerCapitaMax);
                    console.log('cases per capita')
                    break;
                case 'deaths_per_capita':
                    d = row.deaths_per_capita / Math.max(1, summaryData.current.deathsPerCapitaMax);
                    break;
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

    const olSelectHandler = (name: string) => {
        setTooltipVisible(false);

        if (name === '') {

        } else {
            let row: any = mapData.current.get(name.toUpperCase());
            if (row) {
                setShowLocationDetails({visible: true, location: row['location_code'], locationType: props.type});
                setTooltipVisible(false);
            } else {

            }
        }
    }

    const commentaryDetailHandler = () => {
        // let filters: Map<string, string> = new Map();
        if (props.type === 'states' || props.type === 'counties') {
            setShowLocationDetails({visible: true, location: 'US', locationType: 'countries'});
        } else {
            setShowLocationDetails({visible: true, location: 'The World', locationType: 'world'});
        }
    }

    return (
        <Layout style={{padding: 5}}>
            <PageHeader title={props.title} subTitle={props.description}
                        extra={[<Popover placement={"left"} title={"Metrics Terms"} content={<MetricsTerms/>} trigger={"click"}><Button>Metrics Terms</Button></Popover>,
                                <Button type={"primary"} onClick={() => commentaryDetailHandler()}>Details</Button>]}

            >
                <Descriptions size="small" column={1} bordered>
                    <Descriptions.Item label={<b>Commentary</b>}>{summaryDataState.commentary}</Descriptions.Item>
                </Descriptions>

                <Descriptions size="small" column={2} style={{paddingTop: 5}}>
                    <Descriptions.Item><h5>Data Attribution: John Hopkins University, US Census Bureau, UN DESA</h5></Descriptions.Item>
                    <Descriptions.Item><h5>Filters: Please click and select a location from the chart to view the
                        metrics</h5>
                    </Descriptions.Item>
                </Descriptions>

            </PageHeader>
            <Row>
                <Col span={24}>
                    <Radio.Group onChange={(e) => heatMapTypeChange(e.target.value)}
                                 value={heatMapType}>
                        <Space direction={'horizontal'}>
                            <Radio value={'status'}>Spreading Model</Radio>
                            <Radio value={'new_cases'}>Weekly New Cases</Radio>
                            <Radio value={'new_deaths'}>Weekly New Deaths</Radio>
                            <Radio value={'cases_per_capita'}>Cases/100K</Radio>
                            <Radio value={'deaths_per_capita'}>Deaths/100K</Radio>
                            <Radio value={'cases'}>Total Cases</Radio>
                            <Radio value={'deaths'}>Total Deaths</Radio>
                            <Popover content={renderScale()} title={renderScaleTitle()} >
                                <Button  type={"link"}>Legend</Button>
                            </Popover>
                        </Space>

                    </Radio.Group>
                </Col>
            </Row>

            <Popover content={renderToolTip()} title={renderToolTipHeader()}
                     placement={"rightBottom"} visible={tooltipVisible}>
                <div style={{height: 5}}/>
            </Popover>

            <div onMouseLeave={() => setTooltipVisible(false)}>

                <OlMap toolTipHandler={(name) => olToolTipHandler(name)} colorHandler={(name) => olColorHandler(name)}
                       selectHandler={(name) => olSelectHandler(name)} geoFile={props.geoFile} zoom={props.zoom}
                       geoLat={props.geoLat} geoLong={props.geoLong} geoKeyField={props.geoKeyField}
                       height={'730px'}/>
            </div>

            <LocationDetails show={showLocationDetails}/>

        </Layout>);
}
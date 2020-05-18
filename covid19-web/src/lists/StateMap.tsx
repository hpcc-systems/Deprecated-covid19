import React, {useEffect, useRef, useState} from 'react'
import {Card, Col, Descriptions, Layout, PageHeader, Radio, Row, Space, Statistic, Tabs} from "antd";
import {USStateMap} from "../components/USStateMap";
import {QueryData} from "../components/QueryData";
import {Bar} from "@antv/g2plot";
import {Chart} from "../components/Chart";


interface StateMapProps {
    title: string;
    description: string;
    type: 'states' | 'counties';
    query: string;
    zoomLevel: number;
}


class SummaryData {
    newCases: number = 0;
    newDeaths: number = 0;
    cases: number = 0;
    deaths: number = 0;
    recovered: number = 0;
    active: number = 0;
}

export default function StateMap(props: StateMapProps) {
    const queryStatesMap = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_counties_map'));
    const summaryData = useRef<SummaryData>(new SummaryData());
    const [summaryQueryData, setSummaryQueryData] = useState<any>([]);
    const [mapData, setMapData] = useState<any>([]);
    const [heatMapType, setHeatMapType] = useState<any>('new_cases');
    const [mapToolTip, setMapToolTip] = useState<any>([]);
    const [mapSelectedLocation, setMapSelectedLocation] = useState<string>('');
    const mapSelectedStatus = useRef<boolean>(false);


    function toMapData(data: any, heatMapType: any) {
        let mapData: any = [];
        if (data) {
            data.forEach((item: any) => {
                let a = [];
                a.push(item.location_code);
                //weights
                switch (heatMapType) {
                    case 'new_cases':
                        a.push(item.new_cases > 900? 2000: (item.new_cases > 500? 1000: item.new_cases));
                        break;
                    case 'new_deaths':
                        a.push(item.new_deaths);
                        break;
                    case 'cases':
                        a.push(item.cases);
                        break;
                    case 'deaths':
                        a.push(item.deaths);
                        break;
                    case 'status':
                        a.push(item.status_numb);
                        break;
                    default:
                        a.push(item.new_cases);
                }

                a.push(item.date_string);
                a.push(item.new_cases);
                a.push(item.location);
                a.push(item.new_deaths);
                a.push(item.cases);
                a.push(item.deaths);
                a.push(item.active);
                a.push(item.recovered);

                a.push(item.status);
                a.push(item.period_string);
                a.push(item.cr);
                a.push(item.mr);
                a.push(item.sd_indicator);
                a.push(item.med_indicator);
                a.push(item.imort);
                a.push(item.heat_index);
                mapData.push(a);
            })
        }
        return mapData;
    }


    useEffect(() => {

        queryStatesMap.current = new QueryData(props.query);
        queryStatesMap.current.initData(undefined).then(() => {
            setSummaryQueryData(queryStatesMap.current.getData('summary'));
            setMapData(toMapData(queryStatesMap.current.getData('latest'), 'new_cases'));
        })

    }, [props]);

    useEffect(() => {

        setMapData(toMapData(queryStatesMap.current.getData('latest'), heatMapType));

    }, [heatMapType]);

    useEffect(() => {

        function initSummary() {
            if (summaryQueryData.length > 0) {

                summaryQueryData.forEach((item: any) => {
                    summaryData.current.newCases = item.new_cases_total;
                    summaryData.current.newDeaths = item.new_deaths_total;
                    summaryData.current.cases = item.cases_total;
                    summaryData.current.active = item.active_total;
                    summaryData.current.deaths = item.deaths_total;
                    summaryData.current.recovered = item.recovered_total;
                })
            } else {
                return '';
            }
        }

        initSummary();

    }, [summaryQueryData]);

    const heatMapTypeChange = (value: any) => {
        setHeatMapType(value);
    }

    const mapToolTipHandler = (row: any) => {
        //console.log('Current selected status - ' + mapSelectedStatus.current);
        if (!mapSelectedStatus.current) {
            setMapToolTip(row);
            return `<b>${row.location}</b> 
                    <table>
                        <tr>
                        <td>New Cases</td>
                        <td>${row.new_cases} </td>
                        </tr>
                        <tr>
                        <td>Still Active</td>
                        <td>${row.active} </td>
                        </tr>
                        <tr>
                        <td>Recovered</td>
                        <td>${row.recovered} </td>
                        </tr>
                        <tr>
                        <td>Total Cases</td>
                        <td>${row.cases} </td>
                        </tr>
                        <tr>
                        <td>New Deaths</td>
                        <td style="color: red"><b>${row.new_deaths}</b></td>
                        </tr>
                        <tr>
                        <td>Total Deaths</td>
                        <td style="color: red"><b>${row.deaths}</b></td>
                        </tr>                        
                        <tr>
                        <td>Overall Status</td>
                        <td style="color: cornflowerblue">${row.status}</td>
                        </tr>      
                    </table>
                   `;
        } else {
            return '';
        }
    };

    const mapClickHandler = (row: any, sel: any) => {
        if (sel === true) {
            setMapSelectedLocation(row.location);
            setMapToolTip(row);
            mapSelectedStatus.current = true;
        } else {
            mapSelectedStatus.current = false;
            setMapSelectedLocation('');
        }
    };



    const mapColumns = ["location_code", "weights", "date_string", "new_cases", "location", "new_deaths",
        "cases", "deaths", "active", "recovered", "status", "period", "cr", "mr",
        "sd_indicator", "med_indicator", "imort", "heat_index"];

    const chartModelData = [{"name": "heatIndex", "value": mapToolTip['heat_index']},
        {"name": "iMort", "value": mapToolTip['imort']},
        {"name": "sdIndicator", "value": mapToolTip['sd_indicator']},
        {"name": "medIndicator", "value": mapToolTip['med_indicator']},
        {"name": "mR", "value": mapToolTip['mr']},
        {"name": "cR", "value": mapToolTip['cr']}
    ];

    const chartModel = {
        padding: 'auto',
        title: {
            visible: false,
        },
        forceFit: true,
        label: {
            visible: true,
            style: {
                strokeColor: 'black'
            }
        },
        xAxis: {
            title: {visible: false}
        },
        data: [],
        xField: 'value',
        yField: 'name',
        colorField: 'name',
        color: ['#f0a2a4']
    }

    const chartSummaryData = [{"name": "New Cases", "value": mapToolTip['new_cases']},
        {"name": "Total Cases", "value": mapToolTip['cases']},
        {"name": "New Deaths", "value": mapToolTip['new_deaths']},
        {"name": "Total Deaths", "value": mapToolTip['deaths']},
        {"name": "Total Active", "value": mapToolTip['active']},
        {"name": "Total Recovered", "value": mapToolTip['recovered']}];

    const chartSummary = {
        padding: 'auto',
        title: {
            visible: false,
        },
        forceFit: true,
        label: {
            visible: true,
            style: {
                strokeColor: 'black'
            }
        },
        xAxis: {
            title: {visible: false}
        },
        data: [],
        xField: 'value',
        yField: 'name',
        colorField: 'name',
        color: ['#f0a2a4']

    }

    function getMapToolTipHeader() {
        if (mapToolTip['location']) {
            return mapToolTip['location'];
        } else {
            return 'PLEASE: View the metrics my selecting a state or mouse over'
        }
    }

    return (


        <Layout style={{padding: 5}}>
            <PageHeader title={props.title} subTitle={props.description}
            >
                <Descriptions size="small" column={2}>
                    <Descriptions.Item label="Data Attribution">John Hopkins University, Covid Tracking
                        Project</Descriptions.Item>
                    <Descriptions.Item label="Filters">Please select a state from the chart to view the
                        metrics</Descriptions.Item>
                </Descriptions>
            </PageHeader>
            <Row gutter={16}>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="New Cases"
                            value={summaryData.current.newCases}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="New Deaths"
                            value={summaryData.current.newDeaths}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Active Cases"
                            value={summaryData.current.active}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Recovered Cases"
                            value={summaryData.current.recovered}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Total Cases"
                            value={summaryData.current.cases}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Total Deaths"
                            value={summaryData.current.deaths}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
            </Row>

            <div style={{height: 20}}/>
            <Radio.Group onChange={(e) => heatMapTypeChange(e.target.value)}
                         value={heatMapType}>
                <Space direction={'horizontal'}>
                    <Radio.Button value={'new_cases'}>New Cases</Radio.Button>
                    <Radio.Button value={'new_deaths'}>New Deaths</Radio.Button>
                    <Radio.Button value={'cases'}>Total Cases</Radio.Button>
                    <Radio.Button value={'deaths'}>Total Deaths</Radio.Button>
                    <Radio.Button value={'status'}>Stabilized, Spreading...</Radio.Button>
                </Space>
            </Radio.Group>
            <div style={{height: 20}}/>
            <USStateMap height={'700px'} width={'inherited'}
                        columns={mapColumns}
                        data={mapData} toolTipHandler={(row: any) => mapToolTipHandler(row)}
                        clickHandler={(row: any, sel: any) => mapClickHandler(row, sel)}
                        type={props.type} zoomLevel={props.zoomLevel}/>



            <h3>{getMapToolTipHeader()}</h3>
            <Tabs defaultActiveKey={'summary'}>
                <Tabs.TabPane key={'summary'} tab={'Summary'}>

                    <div style={{height: 20}}/>

                    <Row>
                        <Col span={10}>
                            <h3>Daily Stats</h3>
                        </Col>
                        <Col>
                            {mapToolTip['date_string']}
                        </Col>
                    </Row>

                    <Chart chart={Bar} config={chartSummary} data={chartSummaryData} height={'200px'}/>

                    <div style={{height: 20}}/>

                    <Row>
                        <Col span={10}>
                            <h3>SIR Model</h3>
                        </Col>
                        <Col span={14}>
                            {mapToolTip['period']}
                        </Col>
                    </Row>
                    <Row>
                        <Col span={10}>
                            <h4>Status</h4>
                        </Col>
                        <Col span={14}>
                            {mapToolTip['status']}
                        </Col>
                    </Row>

                    <Chart chart={Bar} config={chartModel} data={chartModelData} height={'200px'}/>
                </Tabs.TabPane>
                <Tabs.TabPane key={'daily_trends'} tab={'Daily Trends'}>

                </Tabs.TabPane>
                <Tabs.TabPane key={'model_trends'} tab={'Model Trends'}>

                </Tabs.TabPane>
            </Tabs>


        </Layout>);
}
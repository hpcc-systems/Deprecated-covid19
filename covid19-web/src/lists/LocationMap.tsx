import React, {useEffect, useRef, useState} from 'react'
import {Button, Card, Col, Descriptions, Layout, Modal, PageHeader, Radio, Row, Space, Statistic, Tabs} from "antd";
import {QueryData} from "../components/QueryData";
import {Bar} from "@antv/g2plot";
import {Chart} from "../components/Chart";
import OlMap from "../components/OlMap";


interface LocationMapProps {
    title: string;
    description: string;
    geoFile: string;
    geoLat: number;
    geoLong: number;
    geoKeyField: string;
    zoom: number;
    query: string;
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
    const queryStatesMap = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_countries_map'));
    const summaryData = useRef<SummaryData>(new SummaryData());
    const [summaryQueryData, setSummaryQueryData] = useState<any>([]);
    const mapData = useRef <Map<string, any>> (new Map());
    const [heatMapType, setHeatMapType, heatMapTypeRef] = useStateRef('status');
    const [mapSelectedLocation, setMapSelectedLocation] = useState<any>([]);
    const [modalVisible, setModalVisible] = useState<boolean>(false);



    function toMapData(data: any) {
        let mapData: Map<string, any> = new Map();

        if (data) {
            data.forEach((item: any) => {
               mapData.set(item.location_code, item);
            })
        }
        return mapData;
    }


    useEffect(() => {
        queryStatesMap.current = new QueryData(props.query);
        queryStatesMap.current.initData(undefined).then(() => {
            mapData.current = toMapData(queryStatesMap.current.getData('latest'));
            setSummaryQueryData(queryStatesMap.current.getData('summary'));
            setMapSelectedLocation([]);
        })

    }, [props]);




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
                    summaryData.current.casesMax = item.cases_max;
                    summaryData.current.newCasesMax = item.new_cases_max;
                    summaryData.current.deathsMax = item.deaths_max;
                    summaryData.current.newDeathsMax = item.new_deaths_max;
                    summaryData.current.statusMax = item.status_max;
                })
            } else {
                return '';
            }
        }

        initSummary();

    }, [summaryQueryData]);

    const heatMapTypeChange = (value: any) => {
        setHeatMapType(value);

        console.log('new heat map value - ' + value);
    }

    const olToolTipHandler = (name: string) => {
        let row: any = mapData.current.get(name.toUpperCase());
        if (row) {
            return `<div style="border-width: 1px; background: antiquewhite; padding: 5px"><b>${row.location} </b>
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
                        <td>R</td>
                        <td style="color: cornflowerblue">${row.r}</td>
                        </tr>                       
                        <tr>
                        <td>Overall Status</td>
                        <td style="color: cornflowerblue">${row.status}</td>
                        </tr>      
                    </table>           
                </div>`
        } else {
            return `<div style="border-width: 1px; background: antiquewhite; padding: 5px">No data available for ${name}</div>`
        }
    }

    const olColorHandler = (name: string) => {
        if (!name) return '#a1a080';
        let row: any = mapData.current.get(name.toUpperCase());

        if (row) {
            console.log('row -' + row.location + ' heat map type -' +
                heatMapTypeRef.current + ' max: ' +
                summaryData.current.casesMax);
            let d = 0;
            switch (heatMapTypeRef.current) {
                case 'cases': d = row.cases / Math.max(1, summaryData.current.casesMax); break;
                case 'new_cases': d = row.new_cases /Math.max(1, summaryData.current.newCasesMax);  break;
                case 'deaths': d = row.deaths /Math.max(1, summaryData.current.deathsMax);  break;
                case 'new_deaths': d = row.new_deaths /Math.max(1, summaryData.current.newDeathsMax);  break;
                case 'status': d = row.status_numb /Math.max(1, summaryData.current.statusMax); break;
            }


            return d >= 0.9 ?  '#d73027':
                d > 0.6 ? '#fc8d59' :
                    d > 0.4 ? '#fee08b' :
                        d > 0.2? '#ffffbf' :
                            d > 0.1 ? '#d9ef8b' :
                                        '#91cf60';
        }  else return '#91cf60';


    }

    const olSelectHandler = (name: string) => {

        if (name === '') {
            setMapSelectedLocation([]);
        } else {
            let row: any = mapData.current.get(name.toUpperCase());
            if (row) {
                setMapSelectedLocation(row);
                showModal();
            } else {
                setMapSelectedLocation([]);
            }
        }


    }

    function getMapToolTipHeader() {
        if (mapSelectedLocation.location) {
            return mapSelectedLocation.location;
        } else {
            return 'PLEASE: View the metrics my selecting a state or mouse over'
        }
    }

    const showModal = () => {
        setModalVisible(true);
    };

    const handleOk = () => {
        setModalVisible(false);
    };


    const chartModelData = [{"name": "heatIndex", "value": mapSelectedLocation.heat_index},
        {"name": "iMort", "value": mapSelectedLocation.imort},
        {"name": "sdIndicator", "value": mapSelectedLocation.sd_indicator},
        {"name": "medIndicator", "value": mapSelectedLocation.med_indicator},
        {"name": "mR", "value": mapSelectedLocation.mr},
        {"name": "cR", "value": mapSelectedLocation.cr},
        {"name": "R", "value": mapSelectedLocation.r}
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

    }

    const chartSummaryData = [{"name": "New Cases", "value": mapSelectedLocation.new_cases},
        {"name": "Total Cases", "value": mapSelectedLocation.cases},
        {"name": "New Deaths", "value": mapSelectedLocation.new_deaths},
        {"name": "Total Deaths", "value": mapSelectedLocation.deaths},
        {"name": "Total Active", "value": mapSelectedLocation.active},
        {"name": "Total Recovered", "value": mapSelectedLocation.recovered}];

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

    }


    return (
        <Layout style={{padding: 5}}>
            <PageHeader title={props.title} subTitle={props.description}
            >
                <Descriptions size="small" column={2}>
                    <Descriptions.Item label="Data Attribution">John Hopkins University</Descriptions.Item>
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
                         value={heatMapType} buttonStyle="solid">
                <Space direction={'horizontal'}>
                    <Radio.Button value={'status'}>Spreading Model</Radio.Button>
                    <Radio.Button value={'new_cases'}>New Cases</Radio.Button>
                    <Radio.Button value={'new_deaths'}>New Deaths</Radio.Button>
                    <Radio.Button value={'cases'}>Total Cases</Radio.Button>
                    <Radio.Button value={'deaths'}>Total Deaths</Radio.Button>
                </Space>
            </Radio.Group>
            <div style={{height: 20}}/>

            <OlMap toolTipHandler={(name) => olToolTipHandler(name)} colorHandler={(name) => olColorHandler(name)}
                   selectHandler={(name) => olSelectHandler(name)} geoFile={props.geoFile} zoom={props.zoom}
                   geoLat={props.geoLat} geoLong={props.geoLong} geoKeyField={props.geoKeyField}/>
            <Modal
                title={getMapToolTipHeader()}
                visible={modalVisible}
                onOk={(e)=>handleOk()}
                onCancel={(e)=>handleOk()}
                width={1000}

                bodyStyle={{backgroundColor: '#f0f2f5'}}
                footer={null}
            >

            {/*<h4>{getMapToolTipHeader()}</h4>*/}
            <Tabs defaultActiveKey={'summary'} >
                <Tabs.TabPane key={'summary'} tab={'Summary'}>
                    <div style={{height: 20}}/>
                    <Row>
                        <Col span={12}>
                            <h3>Daily Stats - {mapSelectedLocation.date_string}</h3>
                            <Chart chart={Bar} config={chartSummary} data={chartSummaryData} height={'400px'}/>

                        </Col>
                        <Col span={12}>
                            <h3>SIR Model - {mapSelectedLocation.period_string}</h3>
                            <Chart chart={Bar} config={chartModel} data={chartModelData} height={'400px'}/>
                        </Col>
                    </Row>

                </Tabs.TabPane>
                <Tabs.TabPane key={'daily_trends'} tab={'Daily Trends'}>

                </Tabs.TabPane>
                <Tabs.TabPane key={'model_trends'} tab={'Model Trends'}>

                </Tabs.TabPane>
            </Tabs>
            <Button type="primary" onClick={() => handleOk()}>Close</Button>
            </Modal>

        </Layout>);
}
import React, {useEffect, useRef, useState} from 'react'

import {
    Button,
    Card,
    Col,
    Descriptions,
    Layout,
    Modal,
    PageHeader,
    Radio,
    Row,
    Space,
    Statistic,
    Table,
    Tabs
} from "antd";
import {QueryData} from "../components/QueryData";
import {Bar, Column} from "@antv/g2plot";
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
    const queryLocation = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_location_metrics'));
    const summaryData = useRef<SummaryData>(new SummaryData());
    const [summaryQueryData, setSummaryQueryData] = useState<any>([]);
    const mapData = useRef<Map<string, any>>(new Map());
    const [heatMapType, setHeatMapType, heatMapTypeRef] = useStateRef('status');
    const [mapSelectedLocation, setMapSelectedLocation] = useState<any>([]);
    const [modalVisible, setModalVisible] = useState<boolean>(false);

    const [locationSummaryQueryData, setLocationSummaryQueryData] = useState<any>([]);
    const [toolTipRow, setToolTipRow] = useState<any>([]);
    const [locationChildrenQueryData, setLocationChildrenQueryData] = useState<any>([]);
    const [locationPeriodTrendData, setLocationPeriodTrendQueryData] = useState<any>([]);
    const [modalTab, setModalTab] = useState<string>('r');

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
        let queryName = 'hpccsystems_covid19_query_' + props.type + '_map';

        queryLocationsMap.current = new QueryData(queryName);
        queryLocationsMap.current.initData(undefined).then(() => {
            mapData.current = toMapData(queryLocationsMap.current.getData('latest'));
            setSummaryQueryData(queryLocationsMap.current.getData('summary'));
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

    const locationCommentary: any = () => {
        if (locationSummaryQueryData.length > 0) {
            return locationSummaryQueryData[0]['commentary'];
        } else {
            return '';
        }
    }

    const heatMapTypeChange = (value: any) => {
        setHeatMapType(value);
    }

    const olToolTipHandler = (name: string) => {
        let row: any = mapData.current.get(name.toUpperCase());
        if (row) {
            setToolTipRow(row);
        } else {
            setToolTipRow([]);
        }

        return '';
    }
    const formatNumber: any = (value: any) => {
        if (value) {
            return value.toLocaleString();
        } else {
            return '';
        }
    }

    const renderToolTip = () => {
        let row: any = toolTipRow;
        if (row) {

            return <div>
                <Row>
                    <Col span={1}>Location:</Col>
                    <Col span={3}><b>{row.location}</b></Col>

                    <Col span={2}>New Cases:</Col>
                    <Col span={1}><b>{formatNumber(row.new_cases)}</b></Col>

                    <Col span={2}>Total Cases:</Col>
                    <Col span={2}><b>{formatNumber(row.cases)}</b></Col>

                    <Col span={2}>Still Active:</Col>
                    <Col span={2}><b>{formatNumber(row.active)}</b></Col>

                    <Col span={2}>R</Col>
                    <Col span={1}><b>{row.r}</b></Col>

                </Row>
                <Row>
                    <Col span={1}>Status:</Col>
                    <Col span={3}><b>{row.status}</b></Col>

                    <Col span={2}>New Deaths:</Col>
                    <Col span={1}><b>{formatNumber(row.new_deaths)}</b></Col>

                    <Col span={2}>Total Deaths:</Col>
                    <Col span={2}><b>{formatNumber(row.deaths)}</b></Col>

                    <Col span={2}>Recovered:</Col>
                    <Col span={2}><b>{formatNumber(row.recovered)}</b></Col>


                </Row>
            </div>


        } else {


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
                case 'cases':
                    d = row.cases / Math.max(1, summaryData.current.casesMax);
                    break;
                case 'new_cases':
                    d = row.new_cases / Math.max(1, summaryData.current.newCasesMax);
                    break;
                case 'deaths':
                    d = row.deaths / Math.max(1, summaryData.current.deathsMax);
                    break;
                case 'new_deaths':
                    d = row.new_deaths / Math.max(1, summaryData.current.newDeathsMax);
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

        if (name === '') {
            setMapSelectedLocation([]);
        } else {
            let row: any = mapData.current.get(name.toUpperCase());
            if (row) {
                setMapSelectedLocation(row);
                let filters: Map<string, string> = new Map();
                filters.set('location_type', props.type);
                filters.set('location', row['location_code']);
                queryLocation.current.initData(filters).then(() => {
                    setLocationSummaryQueryData(queryLocation.current.getData('summary'));
                    setLocationChildrenQueryData(queryLocation.current.getData('children'));
                    setLocationPeriodTrendQueryData(queryLocation.current.getData('period_trend'));
                    showModal();
                });

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
        setModalTab('r');
    };


    const chartModelData = [{"name": "Heat Index", "value": mapSelectedLocation.heat_index},
        {"name": "Case Fatality Rate", "value": mapSelectedLocation.imort},
        {"name": "Medical Indicator", "value": mapSelectedLocation.med_indicator},
        {"name": "Social Distance Indicator", "value": mapSelectedLocation.sd_indicator},
        {"name": "Mortality Rate (mR)", "value": mapSelectedLocation.mr},
        {"name": "Cases Rate (cR)", "value": mapSelectedLocation.cr},
        {"name": "Infection Rate (R)", "value": mapSelectedLocation.r}
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
        color: (d: any) => {
            return d === 'Infection Rate (R)' ? '#6394f8' :
                d === 'Case Rate (cR)' ? '#61d9aa' :
                    d === 'Mortality Rate (mR)' ? '#657797' :
                        d === 'Social Distance Indicator' ? '#f6c02c' :
                            d === 'Medical Indicator' ? '#7a4e48' :
                                d === 'Case Fatality Rate' ? '#6dc8ec' :
                                    '#9867bc'
        },
        colorField: 'name',
        data: [],
        xField: 'value',
        yField: 'name',

    }

    // const chartSummaryData = [{"name": "New Cases", "value": mapSelectedLocation.new_cases},
    //     {"name": "Total Cases", "value": mapSelectedLocation.cases},
    //     {"name": "New Deaths", "value": mapSelectedLocation.new_deaths},
    //     {"name": "Total Deaths", "value": mapSelectedLocation.deaths},
    //     {"name": "Total Active", "value": mapSelectedLocation.active},
    //     {"name": "Total Recovered", "value": mapSelectedLocation.recovered}];
    //
    // const chartSummary = {
    //     padding: 'auto',
    //     title: {
    //         visible: false,
    //     },
    //     forceFit: true,
    //     label: {
    //         visible: true,
    //         style: {
    //             strokeColor: 'black'
    //         }
    //     },
    //     xAxis: {
    //         title: {visible: false}
    //     },
    //     data: [],
    //     xField: 'value',
    //     yField: 'name',
    //
    // }

    const chartPeriodTrend = {
        padding: 'auto',
        title: {
            text: 'Rate of infection (R) Trend',
            visible: false,
        },
        forceFit: true,
        label: {
            visible: true,
            style: {
                strokeColor: 'black'
            }
        },
        color: (d: any) => {
            return d > 1.1 ? '#d73027' :
                d > 0.9 ? '#fee08b' :
                    '#1a9850'
        },
        colorField: 'r',
        data: [],
        xField: 'period_string',
        yField: 'r',

    }

    const locationDetailColumns = [
        {
            title: 'Location',
            dataIndex: 'location',
            width: '200px'
        },
        {
            title: 'Status',
            dataIndex: 'istate',
            width: '200px'
        },
        {
            title: 'R',
            dataIndex: 'r',
            className: 'column-number',
            width: '100px'
        },
        {
            title: 'Commentary',
            dataIndex: 'commentary',
        }


    ];

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

            {renderToolTip()}

            <div style={{height: 20}}/>

            <OlMap toolTipHandler={(name) => olToolTipHandler(name)} colorHandler={(name) => olColorHandler(name)}
                   selectHandler={(name) => olSelectHandler(name)} geoFile={props.geoFile} zoom={props.zoom}
                   geoLat={props.geoLat} geoLong={props.geoLong} geoKeyField={props.geoKeyField}
                   height={'700px'}/>
            <Modal
                title={getMapToolTipHeader()}
                visible={modalVisible}
                onOk={(e) => handleOk()}
                onCancel={(e) => handleOk()}
                width={1400}
                footer={null}
            >
                <Descriptions size="small" column={1}>
                    <Descriptions.Item label={<b>Commentary</b>}>{locationCommentary()}</Descriptions.Item>
                </Descriptions>

                <Tabs defaultActiveKey={'r'} activeKey={modalTab} onChange={(key) => {setModalTab(key)}}>
                    <Tabs.TabPane key={'r'} tab={'Rate of Infection (R)'}>
                        <div style={{height: 20}}/>
                        <Row>
                            <Col span={24}>
                                <Chart chart={Column} config={chartPeriodTrend} data={locationPeriodTrendData}
                                       height={'600px'}/>
                            </Col>
                        </Row>

                    </Tabs.TabPane>
                    <Tabs.TabPane key={'metrics'} tab={'Stats & Metrics'}>

                        <Row>
                            <Col span={12}>
                                <b>Daily Stats - {mapSelectedLocation.date_string}</b>
                            </Col>
                            <Col span={12} style={{paddingLeft: 25}}>
                                <b>Weekly Stats and Metrics - {mapSelectedLocation.period_string}</b>
                            </Col>
                        </Row>

                        <Row>
                            <Col span={12}>
                                <Card>
                                    <Statistic
                                        title="New Cases"
                                        value={mapSelectedLocation.new_cases}
                                        valueStyle={{color: '#cf1322'}}
                                    />
                                </Card>
                                <Card>
                                    <Statistic
                                        title="New Deaths"
                                        value={mapSelectedLocation.new_deaths}
                                        valueStyle={{color: '#cf1322'}}
                                    />
                                </Card>
                                <Card>
                                    <Statistic
                                        title="Active Cases"
                                        value={mapSelectedLocation.active}
                                        valueStyle={{color: '#cf1322'}}
                                    />
                                </Card>
                                <Card>
                                    <Statistic
                                        title="Recovered Cases"
                                        value={mapSelectedLocation.recovered}
                                        valueStyle={{color: '#cf1322'}}
                                    />
                                </Card>
                                <Card>
                                    <Statistic
                                        title="Total Cases"
                                        value={mapSelectedLocation.cases}
                                        valueStyle={{color: '#cf1322'}}
                                    />
                                </Card>
                                <Card>
                                    <Statistic
                                        title="Total Deaths"
                                        value={mapSelectedLocation.deaths}
                                        valueStyle={{color: '#cf1322'}}
                                    />
                                </Card>
                            </Col>
                            <Col span={12} style={{paddingLeft: 25}}>
                                <Row>
                                    <Col span={24}>

                                        <Card>
                                            <Statistic
                                                title="New Cases"
                                                value={mapSelectedLocation.period_new_cases}
                                                valueStyle={{color: '#cf1322'}}
                                            />
                                        </Card>
                                        <Card>
                                            <Statistic
                                                title="New Deaths"
                                                value={mapSelectedLocation.period_new_deaths}
                                                valueStyle={{color: '#cf1322'}}
                                            />
                                        </Card>
                                    </Col>

                                </Row>
                                <Row>
                                    <Col span={24}>
                                        <Chart chart={Bar} config={chartModel} data={chartModelData} height={'400px'}/>
                                    </Col>
                                </Row>

                            </Col>

                        </Row>



                    </Tabs.TabPane>
                    {/* Show the tab conditionally for a state. Does not apply to country or county*/}
                    {props.type === 'states' &&
                    <Tabs.TabPane key={'county_metrics'} tab={'Counties Metrics'}>
                        <Table dataSource={locationChildrenQueryData} columns={locationDetailColumns}
                               pagination={false} scroll={{y: 600}}/>
                    </Tabs.TabPane>
                    }
                </Tabs>
                <Button type="primary" onClick={() => handleOk()}>Close</Button>
            </Modal>

        </Layout>);
}
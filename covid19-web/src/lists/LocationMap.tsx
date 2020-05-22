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
    const queryStatesMap = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_countries_map'));
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

        queryStatesMap.current = new QueryData(queryName);
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

    const locationCommentary: any = () => {
        if (locationSummaryQueryData.length > 0) {
            console.log('location data: ' + locationSummaryQueryData[0]);
            return locationSummaryQueryData[0]['commentary'];
        } else {
            return '';
        }
    }

    const heatMapTypeChange = (value: any) => {
        setHeatMapType(value);

        console.log('new heat map value - ' + value);
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
                    d = row.status_numb / Math.max(1, summaryData.current.statusMax);
                    break;
            }


            return d >= 0.9 ? '#b2182b' :
                d > 0.6 ? '#d73027' :
                    d > 0.4 ? '#fee08b' :
                        d > 0.2 ? '#ffffbf' :
                            d > 0.1 ? '#999999' :
                                '#4d4d4d';
        } else return '#91cf60';


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

    const chartPeriodTrend = {
        padding: 'auto',
        title: {
            text: 'Rate of infection (R) Trend',
            visible: true,
        },
        forceFit: true,
        label: {
            visible: true,
            style: {
                strokeColor: 'black'
            }
        },

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
                   geoLat={props.geoLat} geoLong={props.geoLong} geoKeyField={props.geoKeyField}/>
            <Modal
                title={getMapToolTipHeader()}
                visible={modalVisible}
                onOk={(e) => handleOk()}
                onCancel={(e) => handleOk()}
                width={1400}
                bodyStyle={{backgroundColor: '#f0f2f5'}}
                footer={null}
            >
                <Descriptions size="small" column={1}>
                    <Descriptions.Item label="Comments">{locationCommentary()}</Descriptions.Item>

                </Descriptions>
                {/*<h4>{getMapToolTipHeader()}</h4>*/}
                <Tabs defaultActiveKey={'summary'}>
                    <Tabs.TabPane key={'summary'} tab={'Summary'}>
                        <div style={{height: 20}}/>
                        <Row>
                            <Col span={24}>
                                <Chart chart={Column} config={chartPeriodTrend} data={locationPeriodTrendData} height={'400px'}/>
                            </Col>
                        </Row>

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
                    {/* Show the tab conditionally for a state. Does not apply to country or county*/}
                    {props.type==='states' &&
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
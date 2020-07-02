import {Button, Card, Col, Descriptions, Modal, Popover, Row, Statistic, Table, Tabs} from "antd";
import {Chart} from "../components/Chart";
import {Bar, Column, StackedColumn} from "@antv/g2plot";
import Search from "antd/es/input/Search";
import React, {useEffect, useRef, useState} from "react";
import {QueryData} from "../components/QueryData";
import MetricsTerms from "./MetricsTerms";

interface LocationDetailsProps {
   show: any;
}

export default function LocationDetails(props: LocationDetailsProps) {
    const queryLocation = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_location_metrics'));

    const [locationSummaryQueryData, setLocationSummaryQueryData] = useState<any>([]);
    const [locationChildrenQueryData, setLocationChildrenQueryData] = useState<any>([]);
    const [locationPeriodTrendData, setLocationPeriodTrendQueryData] = useState<any>([]);
    const [locationPeriodCasesDeathsTrendData, setLocationPeriodCasesDeathsTrendQueryData] = useState<any>([]);
    const [modalTab, setModalTab] = useState<string>('r');
    const [tableLocationFilterValue, setTableLocationFilterValue] = React.useState<string>('');
    const [modalVisible, setModalVisible] = useState<boolean>(false);

    useEffect(() => {
        function showDetails(location: string, locationType: string) {
            let filters: Map<string, string> = new Map();
            filters.set('location_type', locationType);
            filters.set('location', location);

            queryLocation.current.initData(filters).then(() => {
                setLocationSummaryQueryData(queryLocation.current.getData('summary'));
                setLocationChildrenQueryData(queryLocation.current.getData('children'));
                setLocationPeriodTrendQueryData(queryLocation.current.getData('period_trend'));
                setLocationPeriodCasesDeathsTrendQueryData(queryLocation.current.getData('period_cases_deaths_trend'));
                showModal();
            });
        }
        if (props.show.visible) {
            showDetails(props.show.location, props.show.locationType);
        }

    }, [props.show])



    const locationCommentary: any = () => {
        if (locationSummaryQueryData.length > 0) {
            return locationSummaryQueryData[0]['commentary'];
        } else {
            return '';
        }
    }

    const locationDetail: any = (name: string) => {
        if (locationSummaryQueryData.length > 0) {
            return locationSummaryQueryData[0][name];
        } else {
            return '';
        }
    }

    function getMapToolTipHeader() {
        if (locationDetail('location') !== '') {
            return locationDetail('location')
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
        setTableLocationFilterValue('');
    };

    const renderOptionalValue= (value: any) => {
        if (value) {
            return '  (' + value + ' per 100K)'
        } else {
            return ''
        }
    }

    const renderCommaFormattedValue= (value: any) => {
        if (value) {
            return Math.trunc(value).toLocaleString()
        } else {
            return ''
        }
    }

    const chartModelData = [{"name": "Short Term Indicator", "value": locationDetail("sti")},
        {"name": "Heat Index", "value": locationDetail("heatindex")},
        {"name": "Case Fatality Rate", "value": locationDetail("cfr")},
        {"name": "Medical Indicator", "value": locationDetail("medindicator")},
        {"name": "Social Distance Indicator", "value": locationDetail("sdindicator")},
        {"name": "Mortality Rate (mR)", "value": locationDetail("mr")},
        {"name": "Cases Rate (cR)", "value": locationDetail("cr")},
        {"name": "Infection Rate (R)", "value": locationDetail("r")},
        {"name": "Contagion Risk", "value": locationDetail("contagionrisk")}
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
                                    d === 'Short Term Indicator' ? 'gray':
                                    '#9867bc'
        },
        colorField: 'name',
        data: [],
        xField: 'value',
        yField: 'name',


    }


    const chartPeriodTrend = {
        padding: '100',
        title: {
            visible: false,
        },
        forceFit: true,
        label: {
            visible: true
        },
        legend: {
            visible: false
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
        xAxis:{
            title: {text:'Period', visible: false},
            label: {autoRotate: true, autoHide:false}

        },
        yAxis:{
            title: {text:'R'}
        }
    }

    const chartPeriodCasesDeathsTrend = {
        padding: '100',
        title: {
            visible: false,
        },
        forceFit: true,
        label: {
            visible: true
        },
        legend: {
            visible: true
        },
        color: ['#fee08b', '#d73027',],
        colorField: 'measure',
        data: [],
        xField: 'period_string',
        yField: 'value',
        xAxis:{
            title: {text:'Period', visible: false},
            label: {autoRotate: true, autoHide:false}

        },
        yAxis:{
            title: {text:'Value'}
        },
        stackField: 'measure'
    }

    const locationDetailColumns = [
        {
            title: 'Location',
            dataIndex: 'location',
            width: '200px',
            onFilter: (value: any, record: any) =>
                record['location']
                    .toString()
                    .toLowerCase()
                    .includes(value.toLowerCase()),
            filteredValue: tableLocationFilterValue.split(',')
        },
        {
            title: 'Status',
            dataIndex: 'istate',
            width: '100px'
        },
        {
            title: 'Contagion Risk',
            dataIndex: 'contagionrisk',
            width: '100px'
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
        <Modal
            title={getMapToolTipHeader()}
            visible={modalVisible}
            onOk={(e) => handleOk()}
            onCancel={(e) => handleOk()}
            width={1000}
            footer={null}
            style={{ top: 10 }}
        >
            <Descriptions size="small" column={1}>
                <Descriptions.Item label={<b>Commentary</b>}>{locationCommentary()}  {<Popover placement={"left"} title={"Metrics Terms"} content={<MetricsTerms/>} trigger={"click"}><Button>Metrics Terms</Button></Popover>}</Descriptions.Item>
            </Descriptions>

            <Tabs defaultActiveKey={'r'} activeKey={modalTab} onChange={(key) => {
                setModalTab(key)
            }}>
                <Tabs.TabPane key={'r'} tab={'Rate of Infection (R)'}>
                    <div style={{height: 20}}/>
                    <Row>
                        <Col span={24}>
                            <Chart chart={Column} config={chartPeriodTrend} data={locationPeriodTrendData}
                                   height={'600px'}/>
                        </Col>
                    </Row>
                    <div style={{height: 20}}/>
                </Tabs.TabPane>



                <Tabs.TabPane key={'metrics'} tab={'Metrics'}>

                    <Row>
                        <Col span={12}>
                            <b>Daily Stats - {locationDetail("date_string")}</b>
                        </Col>
                        <Col span={12} style={{paddingLeft: 25}}>
                            <b>Weekly Stats and Metrics - {locationDetail("period_string")}</b>
                        </Col>
                    </Row>

                    <Row>
                        <Col span={12}>
                            <Card>
                                <Statistic
                                    title="New Cases"
                                    value={locationDetail("newcasesdaily")}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title="New Deaths"
                                    value={locationDetail("newdeathsdaily")}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title="Active Cases"
                                    value={locationDetail('active')}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title="Recovered Cases"
                                    value={locationDetail('recovered')}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title="Total Cases"
                                    value={renderCommaFormattedValue(locationDetail('cases')) + renderOptionalValue(locationDetail('cases_per_capita'))}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title="Total Deaths"
                                    value={renderCommaFormattedValue(locationDetail('deaths')) + renderOptionalValue(locationDetail('deaths_per_capita') )}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                        </Col>
                        <Col span={12} style={{paddingLeft: 25}}>
                            <Row>
                                <Col span={24}>

                                    <Card>
                                        <Statistic
                                            title="Weekly New Cases"
                                            value={locationDetail('newcases')}
                                            valueStyle={{color: '#cf1322'}}
                                        />
                                    </Card>
                                    <Card>
                                        <Statistic
                                            title="Weekly New Deaths"
                                            value={locationDetail('newdeaths')}
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

                <Tabs.TabPane key={'cases_deaths_trends'} tab={'New Cases & Deaths'}>
                    <div style={{height: 20}}/>
                    <Row>
                        <Col span={24}>
                            <Chart chart={StackedColumn} config={chartPeriodCasesDeathsTrend}
                                   data={locationPeriodCasesDeathsTrendData}
                                   height={'600px'}/>
                        </Col>
                    </Row>
                </Tabs.TabPane>
                {/* Show the tab conditionally for a state. Does not apply to country or county*/}
                {/*{props.type === 'states' &&*/}
                <Tabs.TabPane key={'location_children'} tab={'Locations'}>
                    <Search placeholder="input search text" onSearch={value => setTableLocationFilterValue(value)}
                            enterButton/>
                    <Table dataSource={locationChildrenQueryData} columns={locationDetailColumns}
                           pagination={false} scroll={{y: 550}} style={{minHeight: 600, fontSize: '9px'}} size={'small'}/>
                </Tabs.TabPane>
                {/*}*/}
            </Tabs>
            <Button type="primary" onClick={() => handleOk()}>Close</Button>
        </Modal>
    )
}
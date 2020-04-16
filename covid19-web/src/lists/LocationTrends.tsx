import React, {useEffect} from "react";
import {QueryData} from "../components/QueryData";
import {Button, Card, Col, Drawer, Input, Layout, PageHeader, Row, Statistic, Table, Tabs} from "antd";
import {Space} from "antd/es";
import {Chart} from "../components/Chart";
import {GroupedColumn, Line} from "@antv/g2plot";


const {TabPane} = Tabs;
const { Search } = Input;


interface LocationTrendsProps {
    title: string;
    description: string;
    typeFilter: string; //By states, world or counties
    locationAlias: string;
}

export default function LocationTrends(props: LocationTrendsProps) {
    const [queryTrends] = React.useState<QueryData>(new QueryData('hpccsystems_covid19_query_trends'));
    const [trends, setTrends] = React.useState<any>([]);
    const [latest, setLatest] = React.useState<any>([]);
    const [drawerVisible, setDrawerVisible] = React.useState<boolean>(false);
    const [tableFilterValue, setTableFilterValue]=  React.useState<string>('');
    const [locationsFilter, setLocationsFilter] = React.useState<Array<string>>([]);

    const [totalCases, setTotalCases] = React.useState<string>('');
    const [totalDeaths, setTotalDeaths] = React.useState<string>('');
    const [casesIncrease, setCasesIncrease] = React.useState<string>('');
    const [deathsIncrease, setDeathsIncrease] = React.useState<string>('');


    useEffect(() => {
        let filters: Map<string, string> = new Map();
        filters.set('typeFilter', props.typeFilter);

        queryTrends.initData(filters).then(() => {
            let trends = queryTrends.getData('trends');
            setTrends(trends);
            setLocationsFilter(toLocationsFilter(trends))
            setLatest(queryTrends.getData('latest'));
            setSummary(queryTrends.getData('summary'));
        });
    }, []);

    useEffect(() => {
        let filters: Map<string, string> = new Map();
        filters.set('typeFilter', props.typeFilter);
        filters.set('locationsFilter', stringArrayToString(locationsFilter));

        queryTrends.initData(filters).then(() => {
            let trends = queryTrends.getData('trends');
            setTrends(trends);
        });
    }, [locationsFilter]);

    function setSummary(data: any) {

        if (data) {
            data.forEach((item: any) => {
                setTotalCases(item.confirmed_total);
                setTotalDeaths(item.deaths_total);
                setCasesIncrease(item.confirmed_increase_total);
                setDeathsIncrease(item.deaths_increase_total)
            })
        }

    }

    function toLocationsFilter(data: any) {
        let a: string[] = [];
        if (data) {
            data.forEach((item: any) => {
                a.push(item.location);
            })
        }
        return a;
    }

    const stringArrayToString = (value: string[]) => {
        let rslt = '';
        if (value) {
            value.forEach((item) => {
                if (rslt === '') {
                    rslt = item;
                } else {
                    rslt = rslt + ',' + item;
                }
            });
        }
        return rslt;
    }

    const updateLocationsFilter = (value: any) => {
        if (value) {
            setLocationsFilter(value.toString().split(','))
        } else {
            setLocationsFilter([]);
        }
    }

    const rowSelection = {
        onChange: (selectedRowKeys: any, selectedRows: any) => {
            updateLocationsFilter(selectedRowKeys);
        },
        selectedRowKeys: locationsFilter,

    };

    const filterTable = [
        {
            title: props.locationAlias,
            dataIndex: 'location',
            minWidth: '50px',
            onFilter: (value: any, record: any) =>
                record['location']
                    .toString()
                    .toLowerCase()
                    .includes(value.toLowerCase()),
            filteredValue: tableFilterValue.split(',')
        },
        {
            title: 'Total Cases',
            dataIndex: 'confirmed',
            className: 'column-number',

        },
        {
            title: 'Cases Increase',
            dataIndex: 'confirmed_increase',
            className: 'column-number',
        },
        {
            title: 'Total Deaths',
            dataIndex: 'deaths',
            className: 'column-number',
        },
        {
            title: 'Deaths Increase',
            dataIndex: 'deaths_increase',
            className: 'column-number',
        },


    ]
    const chartCases = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Cases',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'confirmed',
        groupField: 'location',
    }
    const chartDeaths = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Deaths',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'deaths',
        groupField: 'location',
    }

    const chartCasesIncrease = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Cases Increase',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'confirmed_increase',
        seriesField: 'location',
    }

    const chartDeathsIncrease = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Deaths Increase',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'deaths_increase',
        seriesField: 'location',
    }
    return (
        <Layout style={{padding: '20px', height: '100%'}} >

            <PageHeader title={props.title} subTitle={props.description}

            />

            <Row gutter={16}>
                <Col span={6}>
                    <Card>
                        <Statistic
                            title="Total Cases"
                            value={totalCases}
                            valueStyle={{ color: '#cf1322' }}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card>
                        <Statistic
                            title="Total Deaths"
                            value={totalDeaths}
                            valueStyle={{ color: '#cf1322' }}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                <Card>
                    <Statistic
                        title="Cases Increase"
                        value={casesIncrease}
                        valueStyle={{ color: '#cf1322' }}
                    />
                </Card>
            </Col>
            <Col span={6}>
                <Card>
                    <Statistic
                        title="Deaths Increase"
                        value={deathsIncrease}
                        valueStyle={{ color: '#cf1322' }}
                    />
                </Card>
            </Col>
            </Row>
            <Space direction={'vertical'}>

                <Tabs defaultActiveKey="1">
                    <TabPane tab="Cases" key="1">
                        <Chart chart={GroupedColumn} config={chartCases} data={trends}/>
                        <div style={{height:'10px'}}/>
                        <Chart chart={Line} config={chartCasesIncrease} data={trends}/>
                    </TabPane>
                    <TabPane tab="Deaths" key="2">
                        <Chart chart={GroupedColumn} config={chartDeaths} data={trends}/>
                        <div style={{height:'10px'}}/>
                        <Chart chart={Line} config={chartDeathsIncrease} data={trends}/>
                    </TabPane>
                    <TabPane tab="Data & Filters   " key="3">
                        <Space direction={'vertical'}>
                            <Search placeholder="input search text" onSearch={value => setTableFilterValue(value)} enterButton />

                            <Table  rowKey={'location'} scroll={{y: 500}}  pagination={false} columns={filterTable} dataSource={latest} rowSelection={rowSelection}/>
                        </Space>
                    </TabPane>

                </Tabs>
            </Space>

            {/*<Drawer*/}
            {/*    title="Filter Locations by selecting rows from the table. The charts will update immediately on selection."*/}
            {/*    placement="right"*/}
            {/*    onClose={() => setDrawerVisible(false)}*/}
            {/*    visible={drawerVisible}*/}
            {/*    width={1000}*/}
            {/*>*/}
            {/*    <Space direction={'vertical'}>*/}
            {/*    <Search placeholder="input search text" onSearch={value => setTableFilterValue(value)} enterButton />*/}

            {/*    <Table  rowKey={'location'} scroll={{y: 500}}  pagination={false} columns={filterTable} dataSource={latest} rowSelection={rowSelection}/>*/}
            {/*    </Space>*/}
            {/*</Drawer>*/}
        </Layout>
    );
}
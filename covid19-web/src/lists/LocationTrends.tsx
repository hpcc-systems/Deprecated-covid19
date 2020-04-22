import React, {useEffect} from "react";
import {QueryData} from "../components/QueryData";
import {Card, Col, Input, Layout, PageHeader, Row, Statistic, Table, Tabs} from "antd";
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
    const [queryTrends] = React.useState<QueryData>(new QueryData('hpccsystems_covid19_query_daily_metrics'));
    const [trends, setTrends] = React.useState<any>([]);
    const [latest, setLatest] = React.useState<any>([]);
    const [tableFilterValue, setTableFilterValue]=  React.useState<string>('');
    const [locationsFilter, setLocationsFilter] = React.useState<Array<string>>([]);

    const [totalCases, setTotalCases] = React.useState<string>('');
    const [totalDeaths, setTotalDeaths] = React.useState<string>('');
    const [casesIncrease, setCasesIncrease] = React.useState<string>('');
    const [deathsIncrease, setDeathsIncrease] = React.useState<string>('');
    const [casesActive, setCasesActive] = React.useState<string>('');
    const [casesRecovered, setCasesRecovered] = React.useState<string>('');

    const [refreshData, setRefreshData] = React.useState<boolean>(false)


    useEffect(() => {
        let filters: Map<string, string> = new Map();
        filters.set('typeFilter', props.typeFilter);

        queryTrends.initData(filters).then(() => {
            let trends = queryTrends.getData('trends');
            setTrends(trends);
            setLocationsFilter(toLocationsFilter(trends))
            setLatest(queryTrends.getData('latest'));
            setSummary(queryTrends.getData('summary'));

            console.log('Initialization Complete');
        });
    }, []);

    useEffect(() => {
        if (refreshData) {
            console.log('Refresh data is called');

            setRefreshData(false);

            let filters: Map<string, string> = new Map();
            filters.set('typeFilter', props.typeFilter);
            filters.set('locationsFilter', stringArrayToString(locationsFilter));

            queryTrends.initData(filters).then(() => {
                let trends = queryTrends.getData('trends');
                setTrends(trends);
            });



       }
    }, [refreshData]);

    function setSummary(data: any) {

        if (data) {
            data.forEach((item: any) => {
                setTotalCases(item.cases_total);
                setTotalDeaths(item.deaths_total);
                setCasesIncrease(item.new_cases_total);
                setDeathsIncrease(item.new_deaths_total);
                setCasesActive(item.active_total);
                setCasesRecovered(item.recovered_total);
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

        setRefreshData(true);
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
            // @ts-ignore
            sorter: (a, b) => a.location.localeCompare(b.location),
            onFilter: (value: any, record: any) =>
                record['location']
                    .toString()
                    .toLowerCase()
                    .includes(value.toLowerCase()),
            filteredValue: tableFilterValue.split(',')
        },
        {
            title: 'Date',
            dataIndex: 'date',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.date - b.date

        },
        {
            title: 'Active Cases',
            dataIndex: 'active',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.active - b.active

        },
        {
            title: 'Recovered Cases',
            dataIndex: 'recovered',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.recovered - b.recovered

        },
        {
            title: 'Total Cases',
            dataIndex: 'cases',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.cases - b.cases

        },
        {
            title: 'Cases Increase',
            dataIndex: 'new_cases',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.new_cases - b.new_cases
        },
        {
            title: 'Total Deaths',
            dataIndex: 'deaths',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.deaths - b.deaths
        },
        {
            title: 'Deaths Increase',
            dataIndex: 'new_deaths',
            className: 'column-number',
            // @ts-ignore
            sorter: (a, b) => a.new_deaths - b.new_deaths
        },


    ]

    const chartActive = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Active Cases',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'active',
        groupField: 'location',
        barSize: 10
    }
    const chartRecovered = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Recovered Cases',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'recovered',
        seriesField: 'location',
    }
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
        yField: 'cases',
        groupField: 'location',
        barSize: 10
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
        barSize: 10
    }

    const chartCasesIncrease = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'New Cases',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'new_cases',
        seriesField: 'location',
    }

    const chartDeathsIncrease = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'New Deaths',
        },
        label: {
            visible: true
        },
        data:[],
        xField: 'date',
        yField: 'new_deaths',
        seriesField: 'location',
    }
    return (
        <Layout style={{padding: '20px'}} >

            <PageHeader title={props.title} subTitle={props.description}

            />

            <Row gutter={16}>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Active Cases"
                            value={casesActive}
                            valueStyle={{ color: '#cf1322' }}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Recovered Cases"
                            value={casesRecovered}
                            valueStyle={{ color: '#cf1322' }}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Total Cases"
                            value={totalCases}
                            valueStyle={{ color: '#cf1322' }}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card>
                        <Statistic
                            title="Total Deaths"
                            value={totalDeaths}
                            valueStyle={{ color: '#cf1322' }}
                        />
                    </Card>
                </Col>
                <Col span={4}>
                <Card>
                    <Statistic
                        title="New Cases"
                        value={casesIncrease}
                        valueStyle={{ color: '#cf1322' }}
                    />
                </Card>
            </Col>
            <Col span={4}>
                <Card>
                    <Statistic
                        title="New Deaths"
                        value={deathsIncrease}
                        valueStyle={{ color: '#cf1322' }}
                    />
                </Card>
            </Col>
            </Row>
            <Space direction={'vertical'}>

                <Tabs defaultActiveKey="1">
                    <TabPane tab="Active" key="1">
                        <Chart chart={GroupedColumn} config={chartActive} data={trends}/>
                        <div style={{height:'10px'}}/>
                        <Chart chart={Line} config={chartRecovered} data={trends}/>
                    </TabPane>
                    <TabPane tab="Cases" key="2">
                        <Chart chart={GroupedColumn} config={chartCases} data={trends}/>
                        <div style={{height:'10px'}}/>
                        <Chart chart={Line} config={chartCasesIncrease} data={trends}/>
                    </TabPane>
                    <TabPane tab="Deaths" key="3">
                        <Chart chart={GroupedColumn} config={chartDeaths} data={trends}/>
                        <div style={{height:'10px'}}/>
                        <Chart chart={Line} config={chartDeathsIncrease} data={trends}/>
                    </TabPane>
                    <TabPane tab="Data & Filters   " key="4">
                        <Space direction={'vertical'}>
                            <Search placeholder="input search text" onSearch={value => setTableFilterValue(value)} enterButton />

                            <Table size={'small'} rowKey={'location'} scroll={{y: 500}}  pagination={false} columns={filterTable} dataSource={latest} rowSelection={rowSelection}/>
                        </Space>
                    </TabPane>

                </Tabs>
            </Space>


        </Layout>
    );
}
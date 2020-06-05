import React, {useEffect, useRef, useState} from "react";

import {Button, Descriptions, Layout, PageHeader, Popover, Table, Tabs} from "antd";

import {QueryData} from "../components/QueryData";
import {FilterRenderer} from "../components/FilterRenderer";
import {ChartX} from "../components/ChartX";
import Search from "antd/es/input/Search";
import LocationDetails from "./LocationDetails";


const {TabPane} = Tabs;

interface AllMetricsProps {
    title: string;
    description: string;
    typeFilter: string; //By states, world or counties
    locationAlias: string;
}

export default function AllMetrics(props: AllMetricsProps) {
    // const [queryGrouped] = React.useState<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_grouped'));
    // const [queryPeriod] = React.useState<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_period'));
    // const [queryCatalog] = React.useState<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_catalog'));
    const queryGrouped = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_grouped'));
    const queryPeriod = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_period'));
    const queryCatalog = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_catalog'));
    const [queryLocationsFilter, setQueryLocationsFilter] = React.useState<Array<string>>([]);
    const [queryPeriodFilter, setQueryPeriodFilter] = React.useState<string>('1');


    const [locationsMeasuresData, setLocationsMeasuresData] = React.useState<any>([]);
    const [allMeasuresData, setAllMeasuresData] = React.useState<any>([]);
    const [locationsFilter, setLocationsFilter] = React.useState<Array<string>>([]);
    const [periodFilter, setPeriodFilter] = React.useState<string>('1');
    const [periodsCatalog, setPeriodsCatalog] = React.useState<any>([]);
    const [dataLoadingStatus, setDataLoadingStatus] = React.useState<boolean>(false);
    const [tableFilterValue, setTableFilterValue] = React.useState<string>('');
    const [filterLength, setFilterLength] = React.useState<number>(2);

    const [showLocationDetails, setShowLocationDetails] =
        useState<any>({visible: false, location: '', locationType: ''});

    function toLocationsFilter(data: any) {
        let a: string[] = [];
        if (data) {
            data.forEach((item: any) => {
                a.push(item.location);
            })
        }
        return a;
    }

    function periodTitle(): string {
        let title = '';
        periodsCatalog.forEach((item: any) => {
            if (periodFilter === item.id) {
                title = item.title;
            }
        })
        return title;
    }

    useEffect(() => {
        //This will be called once. Maybe fetch the catalog info and defaults here
        const fetchData = async () => {
            let filters: Map<string, string> = new Map();
            filters.set('typeFilter', props.typeFilter);

            await queryCatalog.current.initData(filters);
            setPeriodsCatalog(queryCatalog.current.getData('catalog_periods'));

            await queryPeriod.current.initData(filters);

            setAllMeasuresData(queryPeriod.current.getData('metrics_period'));
            let lf = toLocationsFilter(queryPeriod.current.getData('default_locations'));
            setQueryLocationsFilter(lf);
            setLocationsFilter(lf);

        }

        fetchData().then();
    }, [props.typeFilter]); //This will be called only if the typeFilter changes. Should be only once.


    useEffect(() => {
        let filters: Map<string, string> = new Map();
        filters.set('periodFilter', queryPeriodFilter);
        filters.set('typeFilter', props.typeFilter);

        queryPeriod.current.initData(filters).then(() => {
            setAllMeasuresData(queryPeriod.current.getData('metrics_period'));
            let lf = toLocationsFilter(queryPeriod.current.getData('default_locations'));
            setQueryLocationsFilter(lf);
            setLocationsFilter(lf);
        });
    }, [queryPeriodFilter, props.typeFilter]);


    useEffect(() => {

        let filters: Map<string, string> = new Map();
        filters.set('periodFilter', queryPeriodFilter);
        filters.set('locationsFilter', stringArrayToString(queryLocationsFilter));
        filters.set('typeFilter', props.typeFilter);
        setDataLoadingStatus(true);
        setFilterLength(queryLocationsFilter.length);
        if (queryLocationsFilter.length > 0) {
            queryGrouped.current.initData(filters).then(() => {

                setLocationsMeasuresData(queryGrouped.current.getData('metrics_grouped'));
                setDataLoadingStatus(false);

            });
        } else {
            console.log('cleared measure data')
            setLocationsMeasuresData([]);
            setDataLoadingStatus(false);
        }

    }, [queryLocationsFilter, queryPeriodFilter, props.typeFilter])

    const updateLocationsFilter = (value: any) => {
        if (value) {
            setLocationsFilter(value.toString().split(','));
        } else {
            setLocationsFilter([]);
        }

    }

    const applyPeriodFilter = (value: any) => {
        setQueryPeriodFilter(value);
        setPeriodFilter(value);
    }

    const applyLocationFilter = () => {
        setQueryLocationsFilter(locationsFilter);
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

    function showDetail(record: any) {
        if (props.typeFilter !== 'counties') {
            setShowLocationDetails({visible: true, location: record.location, locationType: props.typeFilter})
        } else {
            setShowLocationDetails({visible: true, location: record.fips, locationType: props.typeFilter})
        }
    }

    const layout = [
        {
            title: props.locationAlias,
            dataIndex: 'location',
            width: '100px',
            render: (text:any, record: any) => {
                return <Button onClick={()=> showDetail(record)}>{text}</Button>
            },
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
            title: 'Status',
            dataIndex: 'istate',
            width: '100px',
            // @ts-ignore
            sorter: (a, b) => a.istate.localeCompare(b.istate)
        },
        {
            title: 'Commentary',
            dataIndex: 'commentary',
        },
        // {
        //     title: 'Cases',
        //     dataIndex: 'cases',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.cases - b.cases
        // },
        // {
        //     title: 'Deaths',
        //     dataIndex: 'deaths',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.deaths - b.deaths
        //
        // },
        //
        // {
        //     title: 'New Cases',
        //     dataIndex: 'newcases',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.newcases - b.newcases
        //
        // },
        // {
        //     title: 'New Deaths',
        //     dataIndex: 'newdeaths',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.newdeaths - b.newdeaths
        // },
        // {
        //     title: 'Recovered',
        //     dataIndex: 'recovered',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.recovered - b.recovered
        // },
        // {
        //     title: 'cR',
        //     dataIndex: 'cr',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.cr - b.cr
        // },
        // {
        //     title: 'mR',
        //     dataIndex: 'mr',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.mr - b.mr
        //
        // },
        // {
        //     title: 'R',
        //     dataIndex: 'r',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.r - b.r
        // },
        // {
        //     title: 'sdIndicator',
        //     dataIndex: 'sdindicator',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.sdindicator - b.sdindicator
        // },
        // {
        //     title: 'medIndicator',
        //     dataIndex: 'medindicator',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.dmr - b.dmr
        // },
        // {
        //     title: 'iMort',
        //     dataIndex: 'imort',
        //     className: 'column-number',
        //     // @ts-ignore
        //     sorter: (a, b) => a.imort - b.imort
        //
        // },
    ];

    const rowSelection = {
        onChange: (selectedRowKeys: any, selectedRows: any) => {
            updateLocationsFilter(selectedRowKeys);
        },
        selectedRowKeys: locationsFilter,

    };


    const definitions = (
        <div style={{width: 500}}>
            <Descriptions column={1}>
                <Descriptions.Item label="cR">
                    Compound growth factor for Confirmed Cases. This is an indicator of the degree of spread and
                    should decrease with social distancing. In the absence of immunity and social mitigation's,
                    this would be equal to R0 (the natural spread rate of a virus).
                </Descriptions.Item>
                <Descriptions.Item label="mR">
                    Compound growth rate for Deaths. Though this lags the cR, it may be a better proxy for
                    actual number of cases because it is not confounded by test availability and policy.
                </Descriptions.Item>
                <Descriptions.Item label="sdIndicator">
                    Shows progress in social distancing behavior from period to period. Positive values indicate
                    progress in slowing the spread. Negative values indicate that the rate of spread is
                    increasing.

                </Descriptions.Item>
                <Descriptions.Item label="medIndicator">
                    Shows progress in medical performance from period to period. Positive values indicate
                    improvement. Negative values may indicate overload conditions. A negative value early on in
                    a
                    given location’s progress may indicate a lack of testing or diagnosis. A return to negative
                    later in the cycle can indicate an erosion in the quality of medical care.
                </Descriptions.Item>

                <Descriptions.Item label="iMort">
                    This is an approximation of Infection Mortality which is the likelihood that someone who
                    tests positive for the infection will die as a result of the infection. This number may be
                    exaggerated during the very early stages of the infection in a location due to lack of
                    diagnosis and testing.
                </Descriptions.Item>
                <Descriptions.Item label="HeatIndex">
                    This is a composite indicator designed to reflect a broad aspect of a location’s progress.
                    Higher values indicate locations with higher risk. This indicator combines Case Growth (cR),
                    Mortality Growth (mR), Social Distancing (sdIndicator) and Medical Indicator (medIndicator).
                    This indicator is designed to flag locations that are in need of attention, due to high
                    rates of
                    spread or that have begun to regress (e.g. as a result of loosened social distancing or
                    medical
                    overload).
                </Descriptions.Item>
            </Descriptions>
        </div>
    );

    return (

        <Layout style={{padding: '20px'}}>

            <PageHeader title={props.title} subTitle={props.description}
            >
                <Descriptions size="small" column={1}>
                    <Descriptions.Item label="Data Attribution">John Hopkins University</Descriptions.Item>
                    <Descriptions.Item label="Filters">Default filters select the top 10 locations by heat index and the current period. Use
                        the Data & Location Filters tab to customize filters.</Descriptions.Item>
                </Descriptions>
            </PageHeader>

            <LocationDetails show={showLocationDetails}/>

            <FilterRenderer title={'Select a Period'} data={periodsCatalog} value={periodFilter}
                            mode={undefined}
                            onFilterChange={(value) => applyPeriodFilter(value)}/>

            <Tabs defaultActiveKey="1" onChange={(key) => {
                applyLocationFilter()
            }}>

                {/*<div style={{height:20}}/>*/}
                <TabPane tab="Analysis" key="1">


                    <div style={{height: 20}}/>

                    <Popover placement="rightTop" title={'Metrics Definitions'} content={definitions} trigger="click"
                             style={{width: 300}}>
                        <Button>Metrics Definitions</Button>
                    </Popover>

                    <div style={{height: 20}}/>


                    <ChartX data={locationsMeasuresData} groupFiled={'measure'} labelField={'locationstatus'}
                            valueFiled={'value'} height={filterLength * 200}/>
                </TabPane>


                <TabPane tab="Data & Locations Filter" key="2">

                    <div style={{height: 20}}/>


                    <Search placeholder="input search text" onSearch={value => setTableFilterValue(value)} enterButton/>
                    <div style={{height: 20}}/>
                    <Button onClick={() => {
                        updateLocationsFilter('')
                    }}>Clear Table Selections</Button>
                    <div style={{height: 20}}/>
                    <Table size={'small'} rowKey={'location'} bordered columns={layout} dataSource={allMeasuresData}
                           pagination={{pageSize: 50}} loading={{spinning: dataLoadingStatus}}
                           rowSelection={{
                               type: "checkbox" as "checkbox",
                               ...rowSelection
                           }}/>

                </TabPane>
            </Tabs>


        </Layout>
    )


}


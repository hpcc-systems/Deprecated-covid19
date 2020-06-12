import React, {useEffect, useRef, useState} from "react";

import {Button, Descriptions, Layout, PageHeader, Table, Tabs} from "antd";

import {QueryData} from "../components/QueryData";
import {FilterRenderer} from "../components/FilterRenderer";
import Search from "antd/es/input/Search";
import LocationDetails from "./LocationDetails";


interface AllMetricsProps {
    title: string;
    description: string;
    typeFilter: string; //By states, world or counties
    locationAlias: string;
}

export default function AllMetrics(props: AllMetricsProps) {

    const queryGrouped = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_grouped'));
    const queryPeriod = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_period'));
    const queryCatalog = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_catalog'));
    const [queryLocationsFilter, setQueryLocationsFilter] = React.useState<Array<string>>([]);
    const [queryPeriodFilter, setQueryPeriodFilter] = React.useState<string>('1');


    const [allMeasuresData, setAllMeasuresData] = React.useState<any>([]);
    const [periodFilter, setPeriodFilter] = React.useState<string>('1');
    const [periodsCatalog, setPeriodsCatalog] = React.useState<any>([]);
    const [dataLoadingStatus, setDataLoadingStatus] = React.useState<boolean>(false);
    const [tableFilterValue, setTableFilterValue] = React.useState<string>('');


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
        });
    }, [queryPeriodFilter, props.typeFilter]);


    useEffect(() => {

        let filters: Map<string, string> = new Map();
        filters.set('periodFilter', queryPeriodFilter);
        filters.set('locationsFilter', stringArrayToString(queryLocationsFilter));
        filters.set('typeFilter', props.typeFilter);
        setDataLoadingStatus(true);

        if (queryLocationsFilter.length > 0) {
            queryGrouped.current.initData(filters).then(() => {

                setDataLoadingStatus(false);

            });
        } else {

            setDataLoadingStatus(false);
        }

    }, [queryLocationsFilter, queryPeriodFilter, props.typeFilter])



    const applyPeriodFilter = (value: any) => {
        setQueryPeriodFilter(value);
        setPeriodFilter(value);
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
                return <Button type={"link"} onClick={()=> showDetail(record)}>{text}</Button>
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
            title: 'Heat Index',
            width: '50px',
            dataIndex: 'heatindex',
            // @ts-ignore
            sorter: (a, b) => a.heatindex.localeCompare(b.heatindex)
        },
        {
            title: 'Commentary',
            dataIndex: 'commentary',
        },

    ];





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

            <div style={{height: 20}}/>
            <Search placeholder="Type location to search" onSearch={value => setTableFilterValue(value)} enterButton/>

                    <div style={{height: 20}}/>
                    <Table size={'small'} rowKey={'location'} bordered columns={layout} dataSource={allMeasuresData}
                           pagination={{pageSize: 50}} loading={{spinning: dataLoadingStatus}}
                           />


        </Layout>
    )


}


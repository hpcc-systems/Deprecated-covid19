import React, {useEffect, useRef, useState} from "react";

import {Button, Col, Descriptions, Layout, PageHeader, Radio, Space, Table, Tabs} from "antd";

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

export default function Hotspots(props: AllMetricsProps) {

    const queryGrouped = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_grouped'));
    const queryPeriod = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_period'));
    const queryCatalog = useRef<QueryData>(new QueryData('hpccsystems_covid19_query_metrics_catalog'));
    //const [queryLocationsFilter, setQueryLocationsFilter] = React.useState<Array<string>>([]);
    //const [queryPeriodFilter, setQueryPeriodFilter] = React.useState<string>('1');

    const [heatIndex, setHeatIndex] = React.useState<number>(1);
    const [allMeasuresData, setAllMeasuresData] = React.useState<any>([]);
    // const [periodFilter, setPeriodFilter] = React.useState<string>('1');
    // const [periodsCatalog, setPeriodsCatalog] = React.useState<any>([]);
    const [dataLoadingStatus, setDataLoadingStatus] = React.useState<boolean>(false);
    const [tableFilterValue, setTableFilterValue] = React.useState<string>('');


    const [showLocationDetails, setShowLocationDetails] =
        useState<any>({visible: false, location: '', locationType: ''});


    useEffect(() => {
        let filters: Map<string, any> = new Map();
        filters.set('heatIndex', heatIndex);
        filters.set('typeFilter', props.typeFilter);
        setDataLoadingStatus(true);
        queryPeriod.current.initData(filters).then(() => {
            setAllMeasuresData(queryPeriod.current.getData('metrics_period'));
            setDataLoadingStatus(false);
        });
    }, [heatIndex, props.typeFilter]);




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
                <Descriptions size="small" column={2}>
                    <Descriptions.Item label="Data Attribution">John Hopkins University, US Census Bureau, UN DESA</Descriptions.Item>
                    <Descriptions.Item label="Filters">Filter by Hotspot > 1 or All. Then, further filter by location (partial text searches work)</Descriptions.Item>
                </Descriptions>
            </PageHeader>

            <LocationDetails show={showLocationDetails}/>

            {/*<FilterRenderer title={'Select a Period'} data={periodsCatalog} value={periodFilter}*/}
            {/*                mode={undefined}*/}
            {/*                onFilterChange={(value) => applyPeriodFilter(value)}/>*/}
            <Radio.Group onChange={(e) => setHeatIndex(e.target.value)}
                         value={heatIndex}>
                <Space direction={'horizontal'}>
                    <Radio value={1}>Heat Index > 1</Radio>
                    <Radio value={0}>All</Radio>
                </Space>

            </Radio.Group>
            <div style={{height: 20}}/>
            <Search placeholder="Type location to search" onSearch={value => setTableFilterValue(value)} enterButton/>

                    <div style={{height: 20}}/>
                    <Table size={'small'} rowKey={'location'} bordered columns={layout} dataSource={allMeasuresData}
                           pagination={{pageSize: 50}} loading={{spinning: dataLoadingStatus}}
                           />


        </Layout>
    )


}


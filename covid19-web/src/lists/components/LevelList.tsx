import {Table} from "antd";
import React from "react";

interface LevelListProps {
    data: any;
    location: string;
}

const LevelList = (props: LevelListProps) => {

    const layout = [
        {
            title: 'Location',
            dataIndex: 'location',
            sorter: (a:any, b:any) => a.location.localeCompare(b.location),
        },

        {
            title: 'Contagion Risk',
            dataIndex: 'contagion_risk',
            render: (text: any, record: any) => <span>{Math.trunc(text * 100)} %</span>,
            sorter: (a: any,b: any) => a.contagion_risk-b.contagion_risk,
            defaultSortOrder: "descend" as "descend"
        },
        {
            title: 'Infection State',
            dataIndex: 'status',
            sorter: (a: any, b: any) => a.status_numb - b.status_numb

        },
        {
            title: 'Weekly New Cases',
            dataIndex: 'period_new_cases',
            sorter: (a:any, b:any) => a.period_new_cases-b.period_new_cases
        },
        {
            title: 'Weekly New Deaths',
            dataIndex: 'period_new_deaths',
            sorter: (a:any, b:any) => a.period_new_deaths-b.period_new_deaths
        },
        {
            title: 'Cases/100K',
            dataIndex: 'cases_per_capita',
            sorter: (a:any, b:any) => a.cases_per_capita - b.cases_per_capita
        },
        {
            title: 'Deaths/100K',
            dataIndex: 'deaths_per_capita',
            sorter: (a:any, b:any) => a.deaths_per_capita - b.deaths_per_capita
        }

    ];


// && !Catalog.maps.get(props.location)
    if (props.data.length > 0 ) {
        return (
            <Table rowKey={(record)=>record.location} dataSource={props.data} columns={layout}
                   scroll={{y: 500}} pagination={false}/>
        )
    } else {
        return null;
    }
}

export default LevelList;
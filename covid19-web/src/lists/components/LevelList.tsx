import {Button, Layout, Progress, Table} from "antd";
import React from "react";

interface LevelListProps {
    data: any;
    location: string;
    selectHandler: (name: string) => void;
}

const LevelList = (props: LevelListProps) => {

    function getColor(heatMapType: string, value: any) {
        switch (heatMapType) {
            case 'contagion_risk':
                return value >= 0.5 ? '#a50026' :
                    value >= 0.25 ? '#d73027' :
                        value >= 0.15 ? '#fdae61' :
                            value >= 0.05 ? '#fee08b' :
                                value > 0 ? '#66bd63' :
                                    '#1a9850';
            case 'status':
                if (value >= 6) {
                    return '#a50026'
                } else if (value === 5) {
                    return '#d73027'
                } else if (value === 4) {
                    return '#fdae61'
                } else if (value === 3) {
                    return '#fee08b'
                } else if (value === 2) {
                    return '#66bd63'
                } else {
                    return '#1a9850'
                }
            default:
                return '#2b2b2b'

        }
    }

    const getLocation = (location: string, location_code: string | undefined) => {
        let locations: string[]
        if (location_code) {
            locations = location_code.split('-');
        } else {
            locations = location.split('-');
        }
        return locations[locations.length - 1];
    }

    // const percentToStatus= (percent: any) => {
    //     switch(percent) {
    //         case 10: return 'Emerging';
    //         case 20: return 'Recovered';
    //         case 30: return 'Stabelized';
    //         default: return 'Spreading';
    //     }
    // }

    const layout = [
        {
            title: 'Location',
            dataIndex: 'location',
            render: (text: any, record: any) =>
                <Button type={"link"} onClick={()=>props.selectHandler(getLocation(record.location, undefined))}>{getLocation(text, undefined)}</Button>,
            sorter: (a: any, b: any) => a.location.localeCompare(b.location),
        },
        {
            title: 'Contagion Risk',
            dataIndex: 'contagion_risk',
            //render: (text: any, record: any) => <Progress percent={Math.trunc(text * 100)} strokeColor={getColor("contagion_risk", record.contagion_risk)} />,
            render: (text: any, record: any) => <span>{Math.trunc(text * 100)}</span>,
            sorter: (a: any, b: any) => a.contagion_risk - b.contagion_risk,
            defaultSortOrder: "descend" as "descend"
        },
        {
            title: 'Infection State',
            dataIndex: 'status',
            // render: (text: any, record: any) => <Progress percent={Math.trunc(record.status_numb * 100/6)} steps={5} format={(percent)=> percentToStatus(percent)}/>,
            sorter: (a: any, b: any) => a.status_numb - b.status_numb

        },
        {
            title: 'Weekly New Cases',
            dataIndex: 'period_new_cases',
            sorter: (a: any, b: any) => a.period_new_cases - b.period_new_cases
        },
        {
            title: 'Weekly New Deaths',
            dataIndex: 'period_new_deaths',
            sorter: (a: any, b: any) => a.period_new_deaths - b.period_new_deaths
        },
        {
            title: 'Cases/100K',
            dataIndex: 'cases_per_capita',
            sorter: (a: any, b: any) => a.cases_per_capita - b.cases_per_capita
        },
        {
            title: 'Deaths/100K',
            dataIndex: 'deaths_per_capita',
            sorter: (a: any, b: any) => a.deaths_per_capita - b.deaths_per_capita
        }

    ];


// && !Catalog.maps.get(props.location)
    if (props.data.length > 0) {
        return (
            <Layout>
                <div style={{fontSize: 16, fontWeight: 'bold', paddingBottom: 10, paddingTop: 10}}>Interactive list of
                    locations. Click on a location to drill down.
                </div>
                {/*<Table rowKey={(record) => record.location} dataSource={props.data} columns={layout}*/}
                {/*       scroll={{y: 500}} pagination={false}/>*/}
                <Table rowKey={(record) => record.location} dataSource={props.data} columns={layout}
                       />
            </Layout>
        )
    } else {
        return null;
    }
}

export default LevelList;
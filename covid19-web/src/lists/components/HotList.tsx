import {Layout, Table} from "antd";
import React from "react";

interface HotListProps {
    data: any;
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

const HotList = (props: HotListProps) => {

    const columns = [
        {
            dataIndex: 'commentary',
            render: (text: any, record: any) => <div style={{fontSize:14}}><b>{getLocation(record.location, undefined)}</b><br/>{record.commentary}</div>
        }
    ];
    if (props.data.length > 0) {
        return (
            <Layout>
                <div style={{fontSize: 16, fontWeight: 'bold', paddingBottom: 10, paddingTop: 10}}>Hot Spots
                </div>
            <Table rowKey={(record)=>record.location} dataSource={props.data} columns={columns}
                   size={'large'} title={undefined}/>
            </Layout>
        )
    } else {
        return null;
    }
}

export default HotList;
import {Table} from "antd";
import React from "react";
import Catalog from "../../utils/Catalog";

interface LevelListProps {
    data: any;
    location: string;
}

const LevelList = (props: LevelListProps) => {

    const columns = [
        {
            title: 'Location',
            dataIndex: 'location'
        },
        {
            title: 'Cases',
            dataIndex: 'cases'
        }
    ];
    if (props.data.length > 0 && !Catalog.maps.get(props.location)) {
        return (
            <Table rowKey={(record)=>record.location} dataSource={props.data} columns={columns}
                   size={'large'} />
        )
    } else {
        return null;
    }
}

export default LevelList;
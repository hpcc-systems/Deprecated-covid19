import {Table} from "antd";
import React from "react";

interface HotListProps {
    data: any;
}

const HotList = (props: HotListProps) => {

    const columns = [
        {
            title: 'Top 10 Hot Spots',
            dataIndex: 'commentary',
            render: (text: any, record: any) => <div style={{fontSize:14}}><b>{record.location}</b><br/>{record.commentary}</div>
        }
    ];
    if (props.data.length > 0) {
        return (
            <Table rowKey={(record)=>record.location} dataSource={props.data} columns={columns}
                   size={'large'} />
        )
    } else {
        return null;
    }
}

export default HotList;
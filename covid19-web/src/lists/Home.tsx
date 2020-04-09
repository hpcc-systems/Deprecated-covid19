import React from "react";
import {Layout, PageHeader, Tabs} from "antd";
import {Space} from "antd/es";
import {WorldHome} from "./world/WorldHome";
import {StatesHome} from "./us-states/StatesHome";


const {TabPane} = Tabs;

interface HomeProps {
   title: string;
   description: string;
}



export function Home(props: HomeProps) {


    return (
        <Layout style={{padding: '20px', height: '100%'}}>
            <PageHeader title={props.title} subTitle={props.description}

            />
            <Space direction={'vertical'}>

                <Tabs defaultActiveKey="1">
                    <TabPane tab="World" key="1">
                        <WorldHome/>
                    </TabPane>
                    <TabPane tab="US States" key="2">
                        <StatesHome/>
                    </TabPane>

                </Tabs>
            </Space>
        </Layout>
    )

}
import React, {useEffect} from "react";
import {Layout, Tabs} from "antd";
import {Space} from "antd/es";
import {QueryData} from "../components/QueryData";
import ColumnChart from "../components/ColumnChart";
import {WorldHome} from "./world/WorldHome";
import {StatesHome} from "./us-states/StatesHome";



const {TabPane} = Tabs;

interface HomeProps {

}

interface HomeState {
    queryData: QueryData;
    topConfirmed: any;
    topDeaths: any;
    topConfirmedIncrease: any;
    topDeathsIncrease: any;
}

export function Home(props: HomeProps) {

    const [worldData] = React.useState(new QueryData('hpccsystems_covid19_query_summary_world'));
    const [topConfirmed, setTopConfirmed] = React.useState([]);
    const [topDeaths, setTopDeaths] = React.useState([]);
    const [topConfirmedIncrease, setConfirmedIncrease] = React.useState([]);
    const [topDeathsIncrease, setDeathsIncrease] = React.useState([]);

    useEffect(() => {
        worldData.initData(undefined).then(() => {
            setTopConfirmed(worldData.getData('top_confirmed'));
            setTopDeaths(worldData.getData('top_deaths'));
            setConfirmedIncrease(worldData.getData('top_confirmed_increase'));
            setDeathsIncrease(worldData.getData('top_deaths_increase'));
        });
    }, [worldData]);

    return (
        <Layout style={{padding: '20px', height: '100%'}}>
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
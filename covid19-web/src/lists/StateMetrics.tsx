import React, {useEffect} from "react";
import {Col, Layout, Row} from "antd";
import {GroupedColumn, Line} from "@antv/g2plot";
import {Chart} from "../components/Chart";

interface StateMetricsProps {
    title: string;
    description: string;
}

export default function StateMetrics(props: StateMetricsProps) {
    const [newTrends, setNewTrendsData] = React.useState<any>([
        {"day": "April 27", "cases": 20000, "type": "New Cases"},
        {"day": "April 28", "cases": 21000, "type": "New Cases"},
        {"day": "April 29", "cases": 19000, "type": "New Cases"},
        {"day": "April 27", "cases": 1000, "type": "New Deaths"},
        {"day": "April 28", "cases": 1500, "type": "New Deaths"},
        {"day": "April 29", "cases": 1200, "type": "New Deaths"},
        {"day": "April 30", "cases": 20000, "type": "New Cases"},
        {"day": "May 1", "cases": 21000, "type": "New Cases"},
        {"day": "May 2", "cases": 19000, "type": "New Cases"},
        {"day": "April 30", "cases": 1000, "type": "New Deaths"},
        {"day": "May 1", "cases": 1500, "type": "New Deaths"},
        {"day": "May 2", "cases": 1200, "type": "New Deaths"}
        ]);

    const [cumuTrends, setCumuTrendsData] = React.useState<any>([
        {"day": "April 30", "cases": 20000, "type": "Cumulative Cases"},
        {"day": "May 1", "cases": 21000, "type": "Cumulative Cases"},
        {"day": "May 2", "cases": 19000, "type": "Cumulative Cases"},
        {"day": "April 30", "cases": 1000, "type": "Cumulative Deaths"},
        {"day": "May 1", "cases": 1500, "type": "Cumulative Deaths"},
        {"day": "May 2", "cases": 1200, "type": "Cumulative Deaths"}
    ]);

    const newTrendsChart = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Trends of New Cases',
        },
        label: {
            visible: true
        },
        data: [],
        xField: 'day',
        yField: 'cases',
        seriesField: 'type'
    }

    const cumuTrendsChart = {
        padding: 'auto',
        title: {
            visible: true,
            text: 'Trends of Cumulative Cases',
        },
        label: {
            visible: true
        },
        xAxis: {
            title: {visible:false}
        },
        data: [],
        xField: 'day',
        yField: 'cases',
        groupField: 'type',
        barSize: 10
    }



    return (
        <Layout>
            <Row>
                <Col span={12}>
                    <Chart chart={Line} config={newTrendsChart} data={newTrends} height={'500px'}/>
                </Col>
                <Col span={12}>
                    <Chart chart={GroupedColumn} config={cumuTrendsChart} data={cumuTrends} height={'500px'}/>
                </Col>
            </Row>
        </Layout>
    );
}
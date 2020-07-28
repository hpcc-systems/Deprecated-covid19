import React from "react";
import {Chart} from "../../components/Chart";
import {Column} from "@antv/g2plot";
import {Col, Layout, Row} from "antd";

interface PeriodTrendsProps {
    columnData: any;
    groupedData: any;
}

const PeriodTrends = (props: PeriodTrendsProps) => {
    const RTrend = {
        padding: '100',
        title: {
            text: 'Rate of Infection (Week to Week Progress)',
            visible: true,
            style: {fontSize: 14}
        },
        forceFit: true,
        label: {
            visible: true
        },
        legend: {
            visible: false
        },
        color: (d: any) => {
            return d > 1.1 ? '#d73027' :
                d > 0.9 ? '#fee08b' :
                    '#1a9850'
        },
        colorField: 'r',
        data: [],
        xField: 'period_string',
        yField: 'r',
        xAxis: {
            title: {text: 'Period', visible: false},
            label: {autoRotate: true, autoHide: false}

        },
        yAxis: {
            title: {text: 'R'}
        }
    }

    const NewCasesTrend = {
        padding: '100',
        title: {
            text: 'New Cases and New Deaths (Week to Week Progress)',
            visible: true,
            style: {fontSize: 14}
        },
        forceFit: true,
        label: {
            visible: true
        },
        legend: {
            visible: true
        },
        color: ['#fee08b', '#d73027',],
        colorField: 'measure',
        data: [],
        xField: 'period_string',
        yField: 'value',
        xAxis: {
            title: {text: 'Period', visible: false},
            label: {autoRotate: true, autoHide: false}

        },
        yAxis: {
            title: {text: 'Value'}
        },
        stackField: 'measure'
    }


    return (
        <Layout>
            <Layout.Content>
                <Row style={{width: "100%", padding: 10}}>
                    <Col flex={2}>
                        <Chart chart={Column} config={RTrend} data={props.columnData}
                               height={'600px'}/>
                    </Col>
                    <Col flex={3}>
                        <Chart chart={Column} config={NewCasesTrend} data={props.groupedData}
                               height={'600px'}/>
                    </Col>
                </Row>
            </Layout.Content>
        </Layout>

    );
}

export default PeriodTrends;
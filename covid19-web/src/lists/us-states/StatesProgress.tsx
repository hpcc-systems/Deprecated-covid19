import React, {Component} from "react";
import {GroupedColumn} from '@antv/g2plot';


import {
    Col,
    Layout, Row,
    Select
} from "antd";


import {Space} from "antd/es";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";

const {Option} = Select;

interface StatesProgressProp {

}

interface StatesProgressState {
    metrics_by_state: any;
    indicators_by_state: any;
}


export default class StatesProgress extends Component <StatesProgressProp, StatesProgressState> {


    byState : QueryData;


    constructor(props: StatesProgressProp) {
        super(props);
        this.state = {metrics_by_state:[], indicators_by_state:[]};

        this.byState = new QueryData('covid19_weekly_metrics_by_state');
    }

    componentDidMount(): void {
        this.handleChange('GEORGIA').then(r => {
        });
    }


    private async handleChange(value: any) {

        // let filters = [{key: 'statesFilter', value: value}];

        // await this.byState.initData(filters);

        // let metricsData = this.byState.getData('metrics_by_state');
        // let indicatorsData = this.byState.getData('indicators_by_state');

        // console.log('metrics data ' + metricsData);
        // console.log('indicators data ' + JSON.stringify(indicatorsData));

        // this.setState({metrics_by_state: metricsData, indicators_by_state:indicatorsData});
    }

    private renderOptions() {
        return Catalog.us_states.map((item: any) => {
            return <Option key={item.name} value={item.name} label={item.name}> {item.name}</Option>
        });
    }

    render() {
        console.log('render called');
        let dataMetrics =  this.state.metrics_by_state;
        let dataIndicators =  this.state.indicators_by_state;

        // const config = {
        //         title: {
        //             visible: true,
        //             text: 'CR',
        //         },
        //         description: {
        //             visible: true,
        //             text: 'Compound growth factor for Confirmed Cases.  This is an indicator of the degree of spread and should decrease with social',
        //         },
        //         padding: [20, 100, 30, 80],
        //         forceFit: true,
        //         data,
        //         xField: 'period_reverse',
        //         yField: 'cr',
        //         seriesField: 'state',
        //         xAxis: {
        //             type: 'dateTime',
        //             label: {
        //                 visible: true
        //             },
        //         },
        //         legend: {
        //             visible: true,
        //         },
        //         label: {
        //             visible: true,
        //             type: 'line',
        //         },
        //         animation: {
        //             appear: {
        //                 animation: 'clipingWithData',
        //             },
        //         },
        //         theme: 'dark',
        //         smooth: true,
        //     };

        const configMetrics = {

            title: {
                visible: true,
                text: 'Current Metrics by State for a Period',
            },
            forceFit: true,
            data: dataMetrics,
            xField: 'state',
            yField: 'value',
            yAxis: {
                min: -1,
            },
            label: {
                visible: true,
            },
            legend: {
                visible: true,
                flipPage: false,
            },

            groupField: 'measure',
            height: 600,
            theme: 'dark'

        }



        const configIndicators = {

            title: {
                visible: true,
                text: 'Current Indicators by State for a Period',
            },
            forceFit: true,
            data: dataIndicators,
            xField: 'state',
            yField: 'value',
            yAxis: {
                min: -1,
            },
            label: {
                visible: true,
            },
            legend: {
                visible: true,
                flipPage: false,
            },
            height: 600,
            groupField: 'measure',

            theme: 'dark'

        }

        return (

            <Layout style={{padding: '20px', height: '100%'}}>
                <Space direction={'vertical'} >
                    <Row>
                        <Col span={18}>
                            <Select
                                mode="multiple"
                                style={{width: '100%'}}
                                placeholder="select one state"
                                defaultValue={['GEORGIA']}
                                onChange={(value: any) => this.handleChange(value)}
                                optionLabelProp="label"
                            >
                                {this.renderOptions()}
                            </Select>
                        </Col>
                        <Col span={6}>
                            <Select
                                style={{width: '100%'}}
                                placeholder="select one state"
                                defaultValue={1}
                                optionLabelProp="label"
                            >
                                <Option  key={1} value={1} label={'Period 1'}> {'Period 1'}</Option>
                                <Option key={2} value={2} label={'Period 2'}> {'Period 2'}</Option>
                            </Select>
                        </Col>
                    </Row>


                    {/*<ReactG2Plot key={'first'}*/}
                    {/*             config={configMetrics}*/}
                    {/*             Ctor={GroupedColumn}*/}

                    {/*/>*/}


                    {/*<ReactG2Plot key={'second'}*/}
                    {/*    config={configIndicators}*/}
                    {/*    Ctor={GroupedColumn}*/}
                    {/*/>*/}



                </Space>
            </Layout>
        )
    }

}


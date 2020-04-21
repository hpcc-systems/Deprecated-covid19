import React, {Component} from "react";

import {Button, Drawer, Layout, PageHeader, Select, Tabs} from "antd";


import {Space} from "antd/es";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";
import {Filters} from "../../utils/Filters";
import StackedChart from "../../components/StackedChart";
import LineChart from "../../components/LineChart";
//import GroupBarChart from "../../components/GroupBarChart";

import ReactG2Plot from 'react-g2plot';
import {Chart} from "../../components/Chart";
import {GroupedBar, GroupedColumn} from "@antv/g2plot";

const {Option} = Select;
const {TabPane} = Tabs;

interface TrendsProps {
    title: string;
    description: string;
}

interface TrendsState {
    //ctpData: any;
    jhData: any;
    filterVisible: boolean;
}


export default class Trends extends Component <TrendsProps, TrendsState> {
    //private ctpQuery: QueryData;//Covid Project
    private jhQuery: QueryData;//John Hopkins


    constructor(props: TrendsProps) {
        super(props);
        this.state = {jhData: [], filterVisible: false};

        //this.ctpQuery = new QueryData('covid19_by_us_states_ctp');
        this.jhQuery = new QueryData('hpccsystems_covid19_query_summary_us');
    }

    componentDidMount(): void {
        this.handleStatesChange(undefined).then(r => {
        });
    }

    private async handleStatesChange(value: any) {
        if (value) {
            Filters.getInstance().set('statesFilter', value.toString());
        }

        await this.jhQuery.initData(Filters.getInstance().getMap());
        let jhData = this.jhQuery.getData('states');

        this.setState({jhData: jhData});


    }

    quickFilterLocation= (name: string) => {
        let data = this.jhQuery.getData(name);
        let filter = '';
        data.forEach((item: any) => {
            if (filter==='') {
                filter += item.state;
            } else {
                filter += ',' + item.state;
            }
        });
        this.handleStatesChange(filter).then(r => {
        });
    }

    private renderStatesOptions() {
        return Catalog.us_states.map((item: any) => {
            return <Option key={item.name} value={item.name} label={item.name}> {item.name}</Option>
        });
    }

    filterOnClose = () => {
        this.setState({
            filterVisible: false,
        });
    };

    showFilter = () => {
        this.setState({
            filterVisible: true,
        });
    };

    hideFilter = () => {
        this.setState({
            filterVisible: false,
        });
    };

    render() {
        let statesFilterArray: string[] = [];

        let statesFilter = Filters.getInstance().get('statesFilter');
        if (statesFilter) {
            console.log('states filter ' + typeof statesFilter);
            statesFilterArray = statesFilter.split(',');
        }


        const chartCases = {
            padding: 'auto',
            title: {
                visible: true,
                text: 'Cases Confirmed',
            },
            label: {
                visible: true
            },
            data:[],
            xField: 'date',
            yField: 'confirmed',
            groupField: 'state',
        }


            // color: ['#1383ab', '#c52125'],
            // label: {
            //     //formatter: (v) => `${v}`.replace(/\d{1,3}(?=(\d{3})+$)/g, (s) => `${s},`),
            // }

        return (

            <Layout style={{padding: '20px', height: '100%'}}>
                <PageHeader title={this.props.title} subTitle={this.props.description}
                            extra={[
                                <Button type="primary" onClick = {() => this.quickFilterLocation('top_confirmed')}>
                                    Top 10 States (highest cases)
                                </Button>,
                                <Button type="primary" onClick={() => this.quickFilterLocation('top_confirmed_increase')}>
                                    Top 10 States (cases increase)
                                </Button>,
                                <Button type="primary" onClick={this.showFilter}>
                                    Custom Filter
                                </Button>]}
                />
                <Drawer
                    title="Apply Filters"
                    // width={520}
                    placement={'right'}
                    closable={false}
                    onClose={this.filterOnClose}
                    visible={this.state.filterVisible}
                >

                    <Space direction={'vertical'}>
                        <div>Select (Mutiple) States</div>
                        <Select
                            mode="multiple"
                            style={{width: '100%'}}
                            placeholder="select one state"
                            defaultValue={statesFilterArray}
                            value={statesFilterArray}
                            onChange={(value: any) => this.handleStatesChange(value)}
                            optionLabelProp="label"

                        >
                            {this.renderStatesOptions()}
                        </Select>


                        <Button type="primary" onClick={this.hideFilter}>
                            Close
                        </Button>
                    </Space>

                </Drawer>

                <Space direction={'vertical'}>

                    <Tabs defaultActiveKey="1">
                        <TabPane tab="Cases" key="1">

                                {/*<GroupBarChart title={'Cases'}*/}
                                {/*               groupField={'state'}*/}
                                {/*               yField={'confirmed'}*/}
                                {/*               xField={'date'}*/}
                                {/*               data={this.state.jhData}/>*/}
                            {/*<ReactG2Plot*/}
                            {/*    Ctor={GroupBarChart}*/}
                            {/*    config={chartCases}*/}
                            {/*/>*/}


                                <Chart chart={GroupedColumn} config={chartCases} data={this.state.jhData}/>

                                <div style={{height:'10px'}}/>
                                <LineChart title={'Cases Increase'}
                                              groupField={'state'}
                                              yField={'confirmed_increase'}
                                              xField={'date'}
                                              data={this.state.jhData}/>

                        </TabPane>
                        <TabPane tab="Deaths" key="2">


                                <StackedChart title={'Deaths'}
                                              groupField={'state'}
                                              yField={'deaths'}
                                              xField={'date'}
                                              data={this.state.jhData}/>
                                <div style={{height:'10px'}}/>
                                <LineChart title={'Deaths Increase'}
                                          groupField={'state'}
                                          yField={'deaths_increase'}
                                          xField={'date'}
                                          data={this.state.jhData}/>


                        </TabPane>

                    </Tabs>


                    {/* <ColumnChart title={'Recovered'}
                                groupField={'state'}
                                yField={'recovered'}
                                xField={'date'}
                                data={this.state.jhData}/> */}

                </Space>
            </Layout>
        )
    }

}
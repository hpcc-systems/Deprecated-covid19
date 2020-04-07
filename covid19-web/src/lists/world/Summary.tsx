import React, {Component} from "react";

import {Button, Drawer, Layout, Select, Tabs} from "antd";


import {Space} from "antd/es";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";
import {Filters} from "../../utils/Filters";
import StackedChart from "../../components/StackedChart";
import LineChart from "../../components/LineChart";

const {Option} = Select;
const {TabPane} = Tabs;

interface SummaryProps {

}

interface SummaryState {
    //ctpData: any;
    jhData: any;
    filterVisible: boolean;

}


export default class Summary extends Component <SummaryProps, SummaryState> {
    //private ctpQuery: QueryData;//Covid Project
    private jhQuery: QueryData;//John Hopkins


    constructor(props: SummaryProps) {
        super(props);
        this.state = {jhData: [], filterVisible: false};

        //this.ctpQuery = new QueryData('covid19_by_us_states_ctp');
        this.jhQuery = new QueryData('hpccsystems_covid19_query_summary_world');
    }

    componentDidMount(): void {
        this.handleStatesChange(undefined).then(r => {
        });
    }

    private async handleStatesChange(value: any) {
        if (value) {
            Filters.getInstance().set('countriesFilter', value.toString());
        }

        await this.jhQuery.initData(Filters.getInstance().getMap());
        let jhData = this.jhQuery.getData('world');

        this.setState({jhData: jhData});


    }

    private renderCountriesOptions() {
        return Catalog.countries.map((item: any) => {
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
        let countriesFilterArray: string[] = [];

        let countriesFilter = Filters.getInstance().get('countriesFilter');
        if (countriesFilter) {
            console.log('countries filter ' + typeof countriesFilter);
            countriesFilterArray = countriesFilter.split(',');
        }

        return (

            <Layout style={{padding: '20px', height: '100%'}}>
                <Drawer
                    title="Apply Filters"
                    // width={520}
                    placement={'right'}
                    closable={false}
                    onClose={this.filterOnClose}
                    visible={this.state.filterVisible}
                >

                    <Space direction={'vertical'}>
                        <div>Select (Mutiple) Countries</div>
                        <Select
                            mode="multiple"
                            style={{width: '100%'}}
                            placeholder="select countries"
                            defaultValue={countriesFilterArray}
                            onChange={(value: any) => this.handleStatesChange(value)}
                            optionLabelProp="label"

                        >
                            {this.renderCountriesOptions()}
                        </Select>


                        <Button type="primary" onClick={this.hideFilter}>
                            Close
                        </Button>
                    </Space>

                </Drawer>

                <Space direction={'vertical'}>

                    <Button type="primary" onClick={this.showFilter}>
                        Filter
                    </Button>
                    <Tabs defaultActiveKey="1">
                        <TabPane tab="Cases" key="1">

                                <StackedChart title={'Cases'}
                                              groupField={'country'}
                                              yField={'confirmed'}
                                              xField={'date'}
                                              data={this.state.jhData}/>
                                <div style={{height:'10px'}}/>
                                <LineChart title={'Cases Increase'}
                                              groupField={'country'}
                                              yField={'confirmed_increase'}
                                              xField={'date'}
                                              data={this.state.jhData}/>

                        </TabPane>
                        <TabPane tab="Deaths" key="2">


                                <StackedChart title={'Deaths'}
                                              groupField={'country'}
                                              yField={'deaths'}
                                              xField={'date'}
                                              data={this.state.jhData}/>
                                <div style={{height:'10px'}}/>
                                <LineChart title={'Deaths Increase'}
                                          groupField={'country'}
                                          yField={'deaths_increase'}
                                          xField={'date'}
                                          data={this.state.jhData}/>


                        </TabPane>

                    </Tabs>




                </Space>
            </Layout>
        )
    }

}
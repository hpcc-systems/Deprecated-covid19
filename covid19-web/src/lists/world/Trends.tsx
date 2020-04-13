import React, {Component} from "react";

import {Button, Drawer, Layout, PageHeader, Select, Tabs} from "antd";


import {Space} from "antd/es";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";
import {Filters} from "../../utils/Filters";
import StackedChart from "../../components/StackedChart";
import LineChart from "../../components/LineChart";

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
        this.jhQuery = new QueryData('hpccsystems_covid19_query_summary_world');
    }

    componentDidMount(): void {
        this.handleLocationsChange(undefined).then(r => {
        });
    }

    private async handleLocationsChange(value: any) {
        if (value) {
            Filters.getInstance().set('countriesFilter', value.toString());
        }

        await this.jhQuery.initData(Filters.getInstance().getMap());
        let jhData = this.jhQuery.getData('world');

        this.setState({jhData: jhData});
    }

    quickFilterLocation= (name: string) => {
        let data = this.jhQuery.getData(name);
        let filter = '';
        data.forEach((item: any) => {
            if (filter==='') {
                filter += item.country;
            } else {
                filter += ',' + item.country;
            }
        });
        this.handleLocationsChange(filter).then(r => {
        });
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
                <PageHeader title={this.props.title} subTitle={this.props.description}
                 extra={[
                     <Button type="primary" onClick = {() => this.quickFilterLocation('top_confirmed')}>
                         Top 10 Countries (highest cases)
                     </Button>,
                     <Button type="primary" onClick={() => this.quickFilterLocation('top_confirmed_increase')}>
                         Top 10 Countries (cases increase)
                     </Button>,
                     <Button type="primary" onClick={this.showFilter}>
                         Filter
                     </Button>

                 ]}
                />
                <Drawer
                    title="Apply Filters"
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
                            value={countriesFilterArray}
                            onChange={(value: any) => this.handleLocationsChange(value)}
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
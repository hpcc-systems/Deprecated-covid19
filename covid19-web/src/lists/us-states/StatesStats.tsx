import React, {Component} from "react";

import {Layout} from "antd";


import {Space} from "antd/es";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";
import {Filters} from "../../utils/Filters";
import GroupChart from "../../components/GroupChart";
import {FilterDrawer} from "../FilterDrawer";


interface StatesStatsProps {

}

interface StatesStatsState {
    metrics_by_state: any;
    indicators_by_state: any;
    filterVisible: boolean;
}

export default class StatesStats extends Component<StatesStatsProps, StatesStatsState> {

    byState: QueryData;
    periodsData: any;

    constructor(props: StatesStatsProps) {
        super(props);
        this.state = {metrics_by_state: [], indicators_by_state: [], filterVisible: false};

        this.byState = new QueryData('covid19_weekly_metrics_by_state');
    }

    componentDidMount(): void {
        this.fetchData().then();
    }

    private async handleFilterChange(key: string, value: any) {
        if (value) {
            Filters.getInstance().set(key, value.toString());
        }

        await this.fetchData();
    }

    private async fetchData() {
        await this.byState.initData(Filters.getInstance().getMap());
        let metricsData = this.byState.getData('metrics_by_state');
        let indicatorsData = this.byState.getData('indicators_by_state');
        this.periodsData = this.byState.getData('catalog_periods'); //Maybe we should get this from a separate query? And get it just once please
        console.log('metrics data ' + metricsData);
        console.log('indicators data ' + JSON.stringify(indicatorsData));
        this.setState({metrics_by_state: metricsData, indicators_by_state: indicatorsData});
    }


    render() {
        console.log('render called');

        let statesFilter = Filters.getInstance().get('statesFilter');

        let statesFilterArray: string[] = [];
        if (statesFilter) {
            console.log('states filter ' + typeof statesFilter);
            statesFilterArray = statesFilter.split(',');
        }


        let periodFilter = Filters.getInstance().get('periodFilter');
        if (!periodFilter) {
            periodFilter = '1';
        }


        return (

            <Layout style={{padding: '20px', height: '100%'}}>
                <Space direction={'vertical'}>
                    <FilterDrawer defaultPeriodValue={periodFilter}
                                  defaultStatesValue={statesFilterArray}
                                  periods={this.periodsData}
                                  states={Catalog.us_states}
                                  onFilterChange={(key, value) => this.handleFilterChange(key, value)}/>


                    <GroupChart title={`Current Metrics by states for Period ${periodFilter}`}
                                groupField={'measure'}
                                yField={'value'}
                                xField={'location'}
                                yAxisMin={-0.5}
                                data={this.state.metrics_by_state}/>

                    <GroupChart title={`Current Metrics by states for Period ${periodFilter}`}
                                groupField={'measure'}
                                yField={'value'}
                                xField={'location'}
                                yAxisMin={-0.5}
                                data={this.state.indicators_by_state}/>

                </Space>
            </Layout>
        )
    }

}


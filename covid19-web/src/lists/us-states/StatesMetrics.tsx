import React, {Component} from "react";

import {Button, Descriptions, Layout, PageHeader, Table} from "antd";


import {Space} from "antd/es";
import {QueryData} from "../../components/QueryData";
import Catalog from "../../utils/Catalog";
import {Filters} from "../../utils/Filters";
import GroupChart from "../../components/GroupChart";
import {FilterDrawer} from "../FilterDrawer";


interface StatesMetricsProps {
    title: string;
    description: string;
}

interface StatesMetricsState {
    metrics_by_state: any;
    indicators_by_state: any;
    all: any;
    filterVisible: boolean;
    stateFilters: string[];
    periodFilterLabel: string;
}


export default class StatesMetrics extends Component<StatesMetricsProps, StatesMetricsState> {

    byState: QueryData;
    periodsData: any;

    constructor(props: StatesMetricsProps) {
        super(props);
        this.state = {metrics_by_state: [], indicators_by_state: [], filterVisible: false, all: [], stateFilters: ['GEORGIA'], periodFilterLabel: ''};

        this.byState = new QueryData('covid19_weekly_metrics_by_state');
        this.periodsData = [];
    }

    componentDidMount(): void {
        this.fetchData().then();

    }

    private async handleFilterChange(key: string, value: any) {
        if (value) {
            Filters.getInstance().set(key, value.toString());
            if (key === 'statesFilter') {
                this.setState({stateFilters: value.toString().split(',')});
            }

            if(key === 'periodFilter') {
                this.setState({periodFilterLabel:this.lookupPeriod(value.toString())})
            }

        }

        await this.fetchData();
    }

    private async fetchData() {
        await this.byState.initData(Filters.getInstance().getMap());
        let metricsData = this.byState.getData('metrics_by_state');
        let indicatorsData = this.byState.getData('indicators_by_state');
        let allData = this.byState.getData('all');
        this.periodsData = this.byState.getData('catalog_periods'); //Maybe we should get this from a separate query? And get it just once please
        console.log('metrics data ' + metricsData);
        console.log('indicators data ' + JSON.stringify(indicatorsData));

        let stateFilter = Filters.getInstance().get('statesFilter');
        if (stateFilter) {
            this.setState({stateFilters: stateFilter.toString().split(',')});
        }

        let periodFilter = Filters.getInstance().get('periodFilter');
        if (periodFilter) {
            this.setState({periodFilterLabel:this.lookupPeriod(periodFilter.toString())})
        } else {
            this.setState({periodFilterLabel:this.lookupPeriod('1')})
        }
        this.setState({metrics_by_state: metricsData, indicators_by_state: indicatorsData, all: allData});
    }

    lookupPeriod(period: string): string {
        let selectedPeriod = '';
        this.periodsData.forEach((item: any)=>{
            console.log('period ' + item.period + 'in - ' + period);
            if (item.period === period) {

                selectedPeriod = `${item.period} - [ ${item.startdate}  -  ${item.enddate} ]`;

            }
        });
        console.log(' selected period ' + selectedPeriod);
        return selectedPeriod;
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



        const layout = [
            {
                title: 'State',
                dataIndex: 'location',
            },
            {
                title: 'Cases',
                dataIndex: 'cases',

            },
            {
                title: 'Deaths',
                dataIndex: 'deaths',

            },

            {
                title: 'New Cases',
                dataIndex: 'newcases',

            },
            {
                title: 'New Deaths',
                dataIndex: 'newdeaths',

            },
            {
                title: 'Recovered',
                dataIndex: 'recovered',

            },
            {
                title: 'cR',
                dataIndex: 'cr',

            },
            {
                title: 'mR',
                dataIndex: 'mr',

            },
            {
                title: 'dcR',
                dataIndex: 'dcr',

            },
            {
                title: 'dmR',
                dataIndex: 'dmr',

            },
            {
                title: 'iMort',
                dataIndex: 'imort',

            },
        ];

        const rowSelection = {
            onChange: (selectedRowKeys:any, selectedRows:any) => {
                //console.log(`selectedRowKeys: ${selectedRowKeys}`, 'selectedRows: ', selectedRows);

                this.handleFilterChange('statesFilter', selectedRowKeys);
            },
            selectedRowKeys: this.state.stateFilters,

        };


        return (

            <Layout style={{padding: '20px', height: '100%'}}>

                <PageHeader title={this.props.title} subTitle={this.props.description}
                            extra={[
                                <FilterDrawer defaultPeriodValue={periodFilter}
                                              defaultStatesValue={statesFilterArray}
                                              periods={this.periodsData}
                                              states={Catalog.us_states}
                                              onFilterChange={(key, value) => this.handleFilterChange(key, value)}/>
                            ]}


                >
                    <Descriptions size="small" column={1}>
                        <Descriptions.Item label="cR">
                            Compound growth factor for Confirmed Cases. This is an indicator of the degree of spread and
                            should decrease with social distancing. In the absence of immunity and social mitigation's,
                            this would be equal to R0 (the natural spread rate of a virus).
                        </Descriptions.Item>
                        <Descriptions.Item label="mR">
                            Compound growth rate for Deaths. Though this lags the cR, it may be a better proxy for
                            actual number of cases because it is not confounded by test availability and policy.
                        </Descriptions.Item>
                        <Descriptions.Item label="cmRatio">
                            The ratio of cR to mR. This is indicative of effectiveness of medical management. We would
                            expect this number to go down as hospitals become overburdened and go up as more effective
                            treatments are found.
                        </Descriptions.Item>
                        <Descriptions.Item label="dcR">
                            Slope of cR from week to week. This will show whether the situation is improving or getting
                            worse. This can also calibrate a SIR model with changing Beta.
                        </Descriptions.Item>
                        <Descriptions.Item label="dmR">
                            Same as dcR but for growth in deaths.
                        </Descriptions.Item>
                        <Descriptions.Item label="iMort">
                            This is an approximation of Infection Mortality which is the likelihood that someone who
                            tests positive for the infection will die as a result of the infection. This number may be
                            exaggerated during the very early stages of the infection in a location due to lack of
                            diagnosis and testing.
                        </Descriptions.Item>
                    </Descriptions>
                </PageHeader>
                <Space direction={'vertical'}>

                   <div style={{paddingLeft:25, fontWeight:'bold'}}>Selected Period:   {this.state.periodFilterLabel}</div>
                    <GroupChart title={'Current Metrics by states'}
                                groupField={'measure'}
                                yField={'value'}
                                xField={'location'}
                                yAxisMin={-0.5}
                                data={this.state.metrics_by_state}/>

                    <Table style={{height: '500px'}} rowKey={'location'} bordered columns={layout} dataSource={this.state.all}
                           pagination={false} scroll={{ y: 240 }} rowSelection={{
                        type: 'checkbox',
                        ...rowSelection
                    }}/>

                    {/*<GroupChart title={`Current Metrics by states for Period ${periodFilter}`}*/}
                    {/*            groupField={'measure'}*/}
                    {/*            yField={'value'}*/}
                    {/*            xField={'location'}*/}
                    {/*            yAxisMin={-0.5}*/}
                    {/*            data={this.state.indicators_by_state}/>*/}


                </Space>
            </Layout>
        )
    }

}


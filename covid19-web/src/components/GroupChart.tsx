import React, {PureComponent} from "react";
import {GroupedColumn} from '@antv/g2plot';


export type GroupChartProps = {
    readonly title: string;
    readonly data: any;
    readonly yField: string;
    readonly xField: string;
    readonly groupField: string;
    readonly yAxisMin?: number;
};


export default class GroupChart extends PureComponent <GroupChartProps> {

    private $dom: HTMLElement | null | undefined;
    private plot: any;

    componentDidMount() {
        console.log('component did mount - ' + this.$dom);
        this.newPlot();
    }

    componentDidUpdate(prevProps: Readonly<GroupChartProps>,
                       snapshot?: any): void {

        //console.log('GroupChart - Component Did Update : ' + this.props.data);
        this.plot.updateConfig({data: this.props.data});
        this.plot.render();

    }


    private newPlot() {


        let data = this.props.data;
        if (this.$dom) {
            this.plot = new GroupedColumn(this.$dom, {

                title: {
                    visible: true,
                    text: this.props.title,
                },
                forceFit: true,
                data,
                xField: this.props.xField,
                yField: this.props.yField,
                yAxis: {
                    min: this.props.yAxisMin,
                },
                label: {
                    visible: true,
                },
                legend: {
                    visible: true,
                },

                groupField: this.props.groupField,

                theme: 'dark'

            });
            this.plot.render();

        }
    }

    render() {
        return <div style={{width: '100%', height: '575px'}} ref={(e) => (this.$dom = e)}/>;
    }
}
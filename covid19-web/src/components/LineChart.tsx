import React, {PureComponent} from "react";
import {GroupedColumn, Line} from '@antv/g2plot';


export type LineChartProps = {
    readonly title: string;
    readonly data: any;
    readonly yField: string;
    readonly xField: string;
    readonly groupField: string;
    readonly yAxisMin?: number;
};


export default class LineChart extends PureComponent <LineChartProps> {

    private $dom: HTMLElement | null | undefined;
    private plot: any;

    componentDidMount() {
        console.log('component did mount - ' + this.$dom);
        this.newPlot();
    }

    componentDidUpdate(prevProps: Readonly<LineChartProps>,
                       snapshot?: any): void {

        //console.log('ColumnChart - Component Did Update : ' + this.props.data);
        this.plot.updateConfig({data: this.props.data});
        this.plot.render();

    }


    private newPlot() {


        let data = this.props.data;
        if (this.$dom) {
            this.plot = new Line(this.$dom, {

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
                    // style:{stroke: '#262626', fill: 'white'}
                },
                legend: {
                    visible: true,
                    flipPage: false,

                },

                seriesField: this.props.groupField,
                smooth: true,
                // theme: 'dark'

            });
            this.plot.render();

        }
    }

    render() {
        return <div style={{width: '100%', height: '575px'}} ref={(e) => (this.$dom = e)}/>;
    }
}
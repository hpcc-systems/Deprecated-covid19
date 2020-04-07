import React, {PureComponent} from "react";
import {StackedColumn} from "@antv/g2plot/esm";


export type StackedChartProps = {
    readonly title: string;
    readonly data: any;
    readonly yField: string;
    readonly xField: string;
    readonly groupField: string;
};


export default class StackedChart extends PureComponent <StackedChartProps> {

    private $dom: HTMLElement | null | undefined;
    private plot: any;

    componentDidMount() {
        console.log('component did mount - ' + this.$dom);
        this.newPlot();
    }

    componentDidUpdate(prevProps: Readonly<StackedChartProps>,
                       snapshot?: any): void {

        //console.log('GroupChart - Component Did Update : ' + this.props.data);
        this.plot.updateConfig({data: this.props.data});
        this.plot.render();

    }


    private newPlot() {


        let data = this.props.data;
        if (this.$dom) {
            this.plot = new StackedColumn(this.$dom, {

                title: {
                    visible: true,
                    text: this.props.title,
                },
                forceFit: true,
                data,
                xField: this.props.xField,
                yField: this.props.yField,
                yAxis: {
                    min: 0,
                    visible: true
                },
                label: {
                    visible: true,
                },
                legend: {
                    visible: true,
                    flipPage: false,
                },

                stackField: this.props.groupField,

                theme: 'dark'

            });
            this.plot.render();

        }
    }

    render() {
        return <div style={{width: '100%', height: '575px'}} ref={(e) => (this.$dom = e)}/>;
    }
}
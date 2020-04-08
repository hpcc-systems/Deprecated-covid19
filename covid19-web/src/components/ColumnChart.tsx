import React, {PureComponent} from "react";
import {Column} from "@antv/g2plot";


export type ColumnChartProps = {
    readonly title: string;
    readonly data: any;
    readonly yField: string;
    readonly xField: string;
    readonly yAxisMin?: number;
    readonly columnColor?: string;
};


export default class ColumnChart extends PureComponent <ColumnChartProps> {

    private $dom: HTMLElement | null | undefined;
    private plot: any;

    componentDidMount() {
        console.log('component did mount - ' + this.$dom);
        this.newPlot();
    }

    componentDidUpdate(prevProps: Readonly<ColumnChartProps>,
                       snapshot?: any): void {

        this.plot.updateConfig({data: this.props.data});
        this.plot.render();
    }



    private newPlot() {
        let data = this.props.data;
        if (this.$dom) {
            this.plot = new Column(this.$dom, {
                title: {
                    visible: true,
                    text: this.props.title,
                },
                forceFit: true,
                data,
                xField: this.props.xField,
                yField: this.props.yField,
                yAxis: {
                    min: this.props.yAxisMin
                },
                xAxis: {

                    title:{visible:true}

                },
                label: {
                    visible: true,
                },
                color:this.props.columnColor

            });
            this.plot.render();

        }
    }

    render() {
        return <div style={{width: '100%', height: '600px'}} ref={(e) => (this.$dom = e)}/>;
    }
}
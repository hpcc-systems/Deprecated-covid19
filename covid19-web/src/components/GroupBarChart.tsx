import React, {PureComponent} from "react";
import {GroupedBar, GroupedColumn, StackedBar} from '@antv/g2plot';



export type GroupChartProps = {
    readonly title: string;
    readonly data: any;
    readonly yField: string;
    readonly xField: string;
    readonly groupField: string;
    readonly yAxisMin?: number;
    readonly height?: string;
};


export default class GroupBarChart extends PureComponent <GroupChartProps> {

    private $dom: HTMLElement | null | undefined;
    private plot: any;

    componentDidMount() {
        console.log('component did mount - ' + this.$dom);
        this.newPlot();
    }

    componentDidUpdate(prevProps: Readonly<GroupChartProps>,
                       snapshot?: any): void {

        //console.log('ColumnChart - Component Did Update : ' + this.props.data);
        this.plot.updateConfig({data: this.props.data});
        this.plot.render();

    }


    private newPlot() {


        let data = this.props.data;
        if (this.$dom) {
            this.plot = new GroupedBar(this.$dom, {

                title: {
                    visible: true,
                    text: this.props.title,
                },
                data,
                xField: this.props.xField,
                yField: this.props.yField,
                xAxis: {
                    minLimit: -10
                },
                yAxis: {

                    label: {
                        visible: true,
                        autoRotate: false,
                        autoHide: true
                    }
                },
                label: {
                    visible: true,
                },
                legend: {
                    visible: true,
                    flipPage: true,
                },

                groupField: this.props.groupField,
            });
            this.plot.render();

        }
    }

    render() {
        return <div style={{width: '1000px', height: this.props.height}} ref={(e) => (this.$dom = e)}/>;
    }
}
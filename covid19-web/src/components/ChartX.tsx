import React, {useEffect} from "react";
import { Chart } from '@antv/g2';

interface Props {
    readonly valueFiled: string;
    readonly labelField: string;
    readonly groupFiled: string;
    readonly data: any;
    readonly height: number;
}


export function ChartX(props: Props) {
    const [plot, setPlot] = React.useState<any>(undefined);
    const [container, setContainer] = React.useState<HTMLElement|null>(null);


    useEffect(() => {
      if (plot) {
          plot.changeData(props.data);
          plot.render();
      }
    })

    useEffect(() => {
        console.log('Height Changed ' + props.height);
        if(plot) {
            plot.destroy();
            initChart();
        }
    },[props.height]);

    function initChart() {
        if (container != null) {
            const chart = new Chart({
                container: container,
                autoFit: true,
                height: Math.max(props.height, 500),
                renderer: 'svg'
            });
            chart.data(props.data);
            chart
                .coordinate()
                .transpose()
                .scale(0.8, -1);

            chart.axis(props.valueFiled, {
                position: 'right'
            });
            chart.axis(props.labelField, {
                label: {
                    offset:12,
                },
            });

            chart.tooltip({
                shared: true,
                showMarkers: false,
            });

            chart
                .interval()
                .position(props.labelField + '*' + props.valueFiled)
                .label(props.valueFiled)
                .color(props.groupFiled)
                .size(10)
                .adjust([
                    {
                        type: 'dodge',
                        marginRatio: 0,
                    },
                ]);
            chart.legend({
                position: 'left-top',
                // offsetX: -8

            });

            chart.interaction('active-region');
            chart.render();
            setPlot(chart);
        }
    }

    useEffect(() => {
        initChart();

    },[container]);



    return (
        <div ref={(e) => (setContainer(e))} />
    )
}

ChartX.defaultProps = {
    height: '600px'
}
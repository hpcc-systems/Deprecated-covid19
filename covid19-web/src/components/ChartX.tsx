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

          plot.data(props.data);
          plot.render();
      }
    })

    useEffect(() => {
        if(container != null) {
            const chart = new Chart({
                container: container,
                autoFit: true,
                height: props.height,
            });
            chart.data(props.data);
            chart
                .coordinate()
                .transpose()
                .scale(1, -1);

            chart.axis(props.valueFiled, {
                position: 'right',
            });
            chart.axis(props.labelField, {
                label: {
                    offset: 12,
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
                position: 'right-top',
            });

            chart.interaction('active-region');
            chart.render();
            setPlot(chart);
        }

    },[container]);



    return (
        <div style={{width:'100%'}} ref={(e) => (setContainer(e))} />
    )
}

ChartX.defaultProps = {
    height: '600px'
}
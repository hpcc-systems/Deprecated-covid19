import React, {useEffect} from "react";

interface Props {
    readonly chart: any;
    readonly config: object;
    readonly data: any;
    readonly height?: string;
}


export function Chart(props: Props) {
    const [plot, setPlot] = React.useState<any>(undefined);
    const [container, setContainer] = React.useState<HTMLElement|null>(null);
    useEffect(() => {

      if (plot) {
          plot.updateConfig(props.config);
          plot.changeData(props.data);
          plot.render();
      }
    })

    useEffect(() => {
        if(container != null) {
            const chart = new props.chart(container, props.config);

            chart.render();
            setPlot(chart);
        }

    },[container]);


    return (
        <div style={{width:'100%', height:props.height}} ref={(e) => (setContainer(e))} />
    )
}

Chart.defaultProps = {
    height: '600px'
}
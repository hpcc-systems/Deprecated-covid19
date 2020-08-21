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
            plot.changeData(props.data);
        }
    },[plot,props.data])

    useEffect(() => {
        if(!plot && container != null) {
            const chart = new props.chart(container, props.config);

            chart.render();
            setPlot(chart);
        }

    },[container, plot, props.chart, props.config]);


    return (
        <div style={{width:'100%', height:props.height}} ref={(e) => (setContainer(e))} />
    )
}

Chart.defaultProps = {
    height: '600px'
}
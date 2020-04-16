import React, {useEffect} from "react";

interface Props {
    readonly chart: any;
    readonly config: object;
    readonly data: object;
}


export function CommonChart(props: Props) {
    const [plot, setPlot] = React.useState<any>(undefined);
    const [container, setContainer] = React.useState<HTMLElement|null>(null);

    useEffect(() => {

        setPlot(new props.chart(container, props.config));
        plot.updateData(props.data);

    },[]);

    useEffect(() => {

        plot.updateConfig(props.config);

    },[props.config])

    useEffect(() => {

        plot.updateData(props.data);

    },[props.data])

    return (
        <div ref={(e) => (setContainer(e))} />
    )
}
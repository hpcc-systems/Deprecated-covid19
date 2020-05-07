
import React, {useEffect} from "react";
import { Leaflet, topoJsonFolder } from "@hpcc-js/map";

topoJsonFolder("https://cdn.jsdelivr.net/npm/@hpcc-js/map@2.0.0/TopoJSON");

interface Props {
    height: string,
    width: string;
    data: any;
    columns: string[];
    toolTipHandler: (rowObj: any) => void;
    clickHandler: (rowObj: any, sel: any) => void
}

class USStates extends Leaflet.USStates {
    _toolTipHandler: (rowObj: any) => void;

    constructor(toolTipHandler: (rowObj: any) => void) {
        super();
        this._toolTipHandler = toolTipHandler;
    }

    tooltipHandler(l: any, featureID: any) {
        let data: any = this._dataMap;
        const row: any = data[featureID];
        const rowObj: any = this.rowToObj(row);
        this._toolTipHandler(rowObj);
        return '';
    }

}

export function USStateMap(props: Props) {
    const plot = React.useRef<any>(undefined);
    const container = React.useRef<HTMLElement|null>(null);

    useEffect(() => {
        if (plot.current) {
            plot.current.render();
        }
    })

    useEffect(() => {
        function initChart() {
            if (container.current != null && !plot.current) {
                const chart =
                    new USStates(props.toolTipHandler)
                        .target(container.current)
                        .columns(props.columns)
                        .data(props.data)
                        .autoZoomToFit(false)
                        .defaultLat(38.2)
                        .defaultLong(-98.6)
                        .defaultZoom(4)
                        .on("click", (row: any, col: any, sel: any) => {
                            props.clickHandler(row, sel);
                        })

                ;

                chart.render();
                plot.current = chart;
            } else {
                plot.current.data(props.data);
                plot.current.render();
            }
        }
        initChart();

    },[props,container]);


    return (
        <div style={{width:props.width, height:props.height}} ref={(e) => (container.current= e)} />
    )
}

USStateMap.defaultProps = {
    height: '600px'
}
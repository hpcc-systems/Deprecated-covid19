
import React, {useEffect} from "react";
import { Leaflet, topoJsonFolder } from "@hpcc-js/map";

topoJsonFolder("https://cdn.jsdelivr.net/npm/@hpcc-js/map@2.0.0/TopoJSON");

const mapStyle= [
        {
            "featureType": "all",
            "elementType": "labels.text.fill",
            "stylers": [
                {
                    "saturation": 36
                },
                {
                    "color": "#000000"
                },
                {
                    "lightness": 40
                }
            ]
        },
        {
            "featureType": "all",
            "elementType": "labels.text.stroke",
            "stylers": [
                {
                    "visibility": "on"
                },
                {
                    "color": "#000000"
                },
                {
                    "lightness": 16
                }
            ]
        },
        {
            "featureType": "all",
            "elementType": "labels.icon",
            "stylers": [
                {
                    "visibility": "off"
                }
            ]
        },
        {
            "featureType": "administrative",
            "elementType": "geometry.fill",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 20
                }
            ]
        },
        {
            "featureType": "administrative",
            "elementType": "geometry.stroke",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 17
                },
                {
                    "weight": 1.2
                }
            ]
        },
        {
            "featureType": "landscape",
            "elementType": "geometry",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 20
                }
            ]
        },
        {
            "featureType": "poi",
            "elementType": "geometry",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 21
                }
            ]
        },
        {
            "featureType": "road.highway",
            "elementType": "geometry.fill",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 17
                }
            ]
        },
        {
            "featureType": "road.highway",
            "elementType": "geometry.stroke",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 29
                },
                {
                    "weight": 0.2
                }
            ]
        },
        {
            "featureType": "road.arterial",
            "elementType": "geometry",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 18
                }
            ]
        },
        {
            "featureType": "road.local",
            "elementType": "geometry",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 16
                }
            ]
        },
        {
            "featureType": "transit",
            "elementType": "geometry",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 19
                }
            ]
        },
        {
            "featureType": "water",
            "elementType": "geometry",
            "stylers": [
                {
                    "color": "#000000"
                },
                {
                    "lightness": 17
                }
            ]
        }
    ]
;

interface Props {
    height: string,
    width: string;
    data: any;
    zoomLevel: number;
    columns: string[];
    type: 'states' | 'counties';
    toolTipHandler: (rowObj: any) => string;
    clickHandler: (rowObj: any, sel: any) => void
}

class USStates extends Leaflet.USStates {
    _toolTipHandler: (rowObj: any) => string;

    constructor(toolTipHandler: (rowObj: any) => string) {
        super();
        this._toolTipHandler = toolTipHandler;
    }

    tooltipHandler(l: any, featureID: any) {
        let data: any = this._dataMap;
        const row: any = data[featureID];
        const rowObj: any = this.rowToObj(row);
        return this._toolTipHandler(rowObj);
    }

}
class USCounties extends Leaflet.USCounties {
    _toolTipHandler: (rowObj: any) => string;

    constructor(toolTipHandler: (rowObj: any) => string) {
        super();
        this._toolTipHandler = toolTipHandler;
    }

    tooltipHandler(l: any, featureID: any) {
        let data: any = this._dataMap;
        const row: any = data[featureID];
        const rowObj: any = this.rowToObj(row);
        return this._toolTipHandler(rowObj);
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
                let chart: any;
                if (props.type === 'states') {
                    chart =
                        new USStates(props.toolTipHandler)
                } else {
                    chart = new USCounties(props.toolTipHandler)
                }
                chart.mapType("Google")
                    .target(container.current)
                    .columns(props.columns)
                    .data(props.data)
                    .autoZoomToFit(false)
                    .defaultLat(38.2)
                    .defaultLong(-98.6)
                    .defaultZoom(props.zoomLevel)
                    .on("click", (row: any, col: any, sel: any) => {
                        props.clickHandler(row, sel);
                    });
                chart._gmapLayer.googleMapStyles(mapStyle);
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
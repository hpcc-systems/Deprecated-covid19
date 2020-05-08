
import React, {useEffect} from "react";
import { Leaflet, topoJsonFolder } from "@hpcc-js/map";

topoJsonFolder("https://cdn.jsdelivr.net/npm/@hpcc-js/map@2.0.0/TopoJSON");

const mapStyle= [
    {
        "featureType": "administrative",
        "elementType": "all",
        "stylers": [
            {
                "saturation": "-100"
            }
        ]
    },
    {
        "featureType": "administrative.province",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "landscape",
        "elementType": "all",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "lightness": 65
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "lightness": "50"
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "all",
        "stylers": [
            {
                "saturation": "-100"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "elementType": "all",
        "stylers": [
            {
                "lightness": "30"
            }
        ]
    },
    {
        "featureType": "road.local",
        "elementType": "all",
        "stylers": [
            {
                "lightness": "40"
            }
        ]
    },
    {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
            {
                "hue": "#ffff00"
            },
            {
                "lightness": -25
            },
            {
                "saturation": -97
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "labels",
        "stylers": [
            {
                "lightness": -25
            },
            {
                "saturation": -100
            }
        ]
    }
];

interface Props {
    height: string,
    width: string;
    data: any;
    columns: string[];
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
                        .mapType("Google")
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
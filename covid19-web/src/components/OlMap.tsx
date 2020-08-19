import React, {useEffect, useRef} from 'react';
import {Map, View} from 'ol';
import {Vector as VectorLayer} from 'ol/layer';

import 'ol/ol.css';
import GeoJSON from 'ol/format/GeoJSON';
import VectorSource from "ol/source/Vector";
import Select from "ol/interaction/Select";
import {pointerMove} from "ol/events/condition";
import {Fill, Stroke, Style, Text} from 'ol/style';
import {FeatureLike} from "ol/Feature";
import Overlay from "ol/Overlay";
import {fromLonLat} from "ol/proj";
import {defaults as defaultInteractions} from 'ol/interaction.js'
import OverlayPositioning from "ol/OverlayPositioning";


interface Props {
    toolTipHandler: (name: string) => string;
    colorHandler: (name: string) => string;
    selectHandler: (name: string) => void;
    measureHandler: (name: string) => void;
    geoFile: string;
    secondaryGeoFile?: string;
    geoLat: number;
    geoLong: number;
    selectKeyField: string;
    colorKeyField: string;
    zoom: number;
    height: string;
}

export default function OlMap(props: Props) {
    const container = useRef<HTMLElement | null>(null);
    const popup = useRef<HTMLElement | null>(null);


    function selectFunction(feature: FeatureLike) {
        const style = new Style({
            fill: new Fill({
                color: getColor(feature),
            }),
            stroke: new Stroke({
                color: 'black',
                width: 3,
            }),
            text: new Text({
                font: '9px Calibri,sans-serif',
                fill: new Fill({
                    color: '#000',
                }),
                stroke: new Stroke({
                    color: 'gray',
                    width: 1,
                }),
            }),
        });

        let text = feature.get(props.selectKeyField).toUpperCase();
        style.getText().setText(text + ' ' + props.measureHandler(feature.get(props.colorKeyField)));
        return style;
    }

    function getColor(feature: any) {
        return props.colorHandler(feature.get(props.colorKeyField));
    }

    const overlay = new Overlay({
        offset: [10, 0],
        positioning:OverlayPositioning.TOP_LEFT,

    });

    const map = useRef<Map | null>(null);

    function colorLayer(geoJsonFileName: string,
                        geoKeyField: string,
                        borderColor: string,
                        borderWidth: number,
                        fillColor: string,
                        showLabel: boolean) {
        return new VectorLayer({
            source: new VectorSource({
                url: geoJsonFileName,
                format: new GeoJSON()
            }),
            style: function (feature) {
                const style = new Style({
                    fill: new Fill({
                        color: fillColor === '' ? props.colorHandler(feature.get(geoKeyField)) : fillColor,
                    }),
                    stroke: new Stroke({
                        color: borderColor,
                        width: borderWidth,
                    }),
                    text: new Text({
                        font: '9px Calibri,sans-serif',
                        fill: new Fill({
                            color: '#000',
                        }),
                        stroke: new Stroke({
                            color: 'gray',
                            width: 1,
                        }),
                    }),
                });

                let text = feature.get(props.selectKeyField).toUpperCase();
                style.getText().setText(showLabel ?  text + ' ' + props.measureHandler(feature.get(props.colorKeyField)) : '');
                return style;
            },
        });
    }

    const initMap = () => {
        if (map.current !== null)
            map.current.dispose();


        map.current = new Map({
            overlays: [overlay],
            view: new View({
                center: [0, 0],
                zoom: 2
            }),
            interactions: defaultInteractions({
                doubleClickZoom: false,
                dragPan: true,
                mouseWheelZoom: false
            }),
        });

        if (container.current && popup.current && map.current !== null) {

            let layer: VectorLayer = colorLayer(props.geoFile, props.colorKeyField, '#319FD3', 1, '', true);
            map.current.addLayer(layer);

            if (props.secondaryGeoFile) {
                let secondaryLayer: VectorLayer = colorLayer(props.secondaryGeoFile,
                    'name',
                    'lightblue',
                    2, 'transparent', false);
                map.current.addLayer(secondaryLayer);
            }

            map.current.getView().setCenter(fromLonLat([props.geoLong, props.geoLat]))
            map.current.getView().setZoom(props.zoom);

            overlay.setElement(popup.current);
            map.current.setTarget(container.current);

            let selectMouseMove = new Select({
                layers: [layer],
                condition: pointerMove,
                style: selectFunction
            });

            selectMouseMove.on('select', function (e: any) {
                if (e.selected.length > 0) {
                    let feature = e.selected[0];
                    if (popup.current) {
                        popup.current.innerHTML = props.toolTipHandler(feature.get(props.colorKeyField));
                        overlay.setPosition(e.mapBrowserEvent.coordinate);
                    }
                } else {
                    props.toolTipHandler('');
                    if (popup.current) {
                        popup.current.innerHTML = '';
                    }
                }
            });

            map.current.addInteraction(selectMouseMove);

            map.current.on('singleclick', function (evt) {
                if (map.current !== null) {
                    map.current.forEachFeatureAtPixel(evt.pixel,
                        function (feature, l) {
                            if (l === layer) {
                                props.selectHandler(feature.get(props.selectKeyField));
                                return [feature, layer];
                            }
                        });
                }
            });

            map.current.updateSize();
            map.current.render();
        }

   }

    useEffect((initMap), [props.geoFile]);

    useEffect(() => {
        if (map.current !== null) {
            map.current.getLayers().forEach((layer) => {
                (layer as VectorLayer).getSource().changed();
            })
        }

    })

    return (
        <div>
            <div style={{background: '#2b2b2b', height: props.height}} ref={(e) => (container.current = e)}/>
            <div ref={(e) => (popup.current = e)}/>
        </div>

    )
}
import React, { useEffect,useRef } from 'react';
import { Map, View } from 'ol';
import {Tile as TileLayer, Vector as VectorLayer} from 'ol/layer';
import OSM from 'ol/source/OSM';



export default function OlMap() {
    const container = useRef(null);
    const map = new Map({

        layers: [
            new TileLayer({
                source: new OSM()
            })
        ],
        view: new View({
            center: [-6005420.749222653, 6000508.181331601],
            zoom: 9
        })
    });
    useEffect(() => {
        map.setTarget(container.current)
        return () => map.setTarget(undefined);
    }, [map]);

    return (
        <div  ref={(e) => (container.current= e)}/>

    )
}
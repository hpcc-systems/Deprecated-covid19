
//import { functions, isEqual, omit } from 'lodash'

import React, { useState, useEffect, useRef } from 'react'

interface Props {
    options?: any;
    onMount?: any;
    className?: any;
    onMountProps?: any;
}

function Map(props:Props) {

    const citymap: any = {
        chicago: {
            center: {lat: 41.878, lng: -87.629},
            population: 2714856
        },
        newyork: {
            center: {lat: 40.714, lng: -74.005},
            population: 8405837
        },
        losangeles: {
            center: {lat: 34.052, lng: -118.243},
            population: 3857799
        },
        vancouver: {
            center: {lat: 49.25, lng: -123.1},
            population: 603502
        }
    };

    const container = useRef<HTMLElement|null>(null);
    const [map, setMap] = useState()

    useEffect(() => {
        // The Google Maps API modifies the options object passed to
        // the Map constructor in place by adding a mapTypeId with default
        // value 'roadmap'. { ...options } prevents this by creating a copy.
        const onLoad = () => {
            if (container.current) {
                let m = new window.google.maps.Map(container.current, {...props.options});
                setMap(m)
                for (let city in citymap) {
                    // Add the circle for this city to the map.
                    let cityCircle = new window.google.maps.Circle({
                        strokeColor: '#FF0000',
                        strokeOpacity: 0.8,
                        strokeWeight: 2,
                        fillColor: '#FF0000',
                        fillOpacity: 0.35,
                        map: m,
                        center: citymap[city].center,
                        radius: Math.sqrt(citymap[city].population) * 100
                    });
                }
            }
        }
        if (!window.google) {
            const script = document.createElement(`script`)
            script.src =
                `https://maps.googleapis.com/maps/api/js?key=` +
                process.env.REACT_APP_GOOGLE_MAPS_API_KEY

            document.head.append(script)
            script.addEventListener(`load`, onLoad)
            return () => script.removeEventListener(`load`, onLoad)
        } else onLoad()
    }, [props.options])

    if (map && typeof props.onMount === `function`) props.onMount(map, props.onMountProps)

    return (
        <div
            style={{ height: `60vh`, margin: `1em 0`, borderRadius: `0.5em` }}
            ref={(e) => (container.current= e)}
        />
    )
}

function shouldNotUpdate(props: any, nextProps: any) {
    return true;
}

export default React.memo(Map, shouldNotUpdate)

Map.defaultProps = {
    options: {
        center: { lat: 48, lng: 8 },
        zoom: 5,
    },
}
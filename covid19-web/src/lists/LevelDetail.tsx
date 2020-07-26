import React, {useEffect, useRef, useState} from "react";
import {Layout} from "antd";
import LevelMap from "./components/LevelMap";
import {QueryData} from "../components/QueryData";



export default function LevelDetail(props) {
    const query = useRef(new QueryData('hpccsystems_covid19_query_location_map'));

    const [location, setLocation] = useState({code: '', level: 0});
    const locationStack = useRef([]);

    //Data
    const [summaryData, setSummaryData] = useState([]);
    const [maxData, setMaxData] = useState([]);
    const [listData, setListData] = useState(new Map());

    useEffect(() => {
        function toMapData(data) {
            let mapData = new Map();

            if (data) {
                data.forEach(item => {
                    mapData.set(item.location, item);
                    //console.log('map - '+ item.location)
                })

            }
            return mapData;
        }

        //Get the data
        let filters = new Map();
        filters.set('level', locationStack.current.length + 1);
        if (locationStack.current.length >= 1)
           filters.set('level1_location', locationStack.current[0]);
        if (locationStack.current.length >= 2)
            filters.set('level2_location', locationStack.current[1]);
        query.current.initData(filters).then(() => {
            let summary = query.current.getData('summary');

            if (summary.length > 0) {

                summary.forEach(item => {
                    setSummaryData(item);
                });

            }

            let max = query.current.getData('max');

            if (max.length > 0) {

                max.forEach(item => {
                    setMaxData(item);
                });

            }

            let list = query.current.getData('list');
            let mapData  = toMapData(list);
            setListData(mapData);

            console.log('map data size - ' + mapData.size)


        })

    }, [location]);

    const pushLocation = (location) => {
        locationStack.current.push(location);
        setLocation(location);
    }

    const popLocation = () => {
        setLocation(locationStack.current.pop());
    }


    return (
        <Layout width={'100vw'}>
            <LevelMap level={location.level} location={location.code} locationAlias={''} listData={listData} maxData={maxData}>
            </LevelMap>
        </Layout>
    );


}
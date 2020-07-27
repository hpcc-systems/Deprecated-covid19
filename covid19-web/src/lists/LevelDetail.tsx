import React, {useEffect, useRef, useState} from "react";
import {Button, Descriptions, Layout, PageHeader, Row} from "antd";
import LevelMap from "./components/LevelMap";
import {QueryData} from "../components/QueryData";
import SummaryMeasures from "./components/SummaryMeasures";
import HotList from "./components/HotList";


const LevelDetail = () => {
    const query = useRef(new QueryData('hpccsystems_covid19_query_location_map'));

    const [location, setLocation] = useState<string>('');
    const locationStack = useRef<any>([]);

    //Data
    const [summaryData, setSummaryData] = useState<any>([]);
    const [maxData, setMaxData] = useState<any>([]);
    const [listData, setListData] = useState<any>(new Map());
    const [hotListData, setHotListData] = useState<any>([]);

    useEffect(() => {
        function toMapData(data: any) {
            let mapData = new Map();

            if (data) {
                data.forEach((item: any) => {
                    let locations: string;
                    if (item.location_code) {
                        locations = item.location_code.split('-');
                    } else {
                        locations = item.location.split('-');
                    }

                    mapData.set(locations[locations.length - 1], item);
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
        if (locationStack.current.length >= 3)
            filters.set('level3_location', locationStack.current[2]);//NOTE: This is the max level supported. For US, it is the county level
        query.current.initData(filters).then(() => {
            let summary = query.current.getData('summary');

            if (summary.length > 0) {

                summary.forEach((item: any) => {
                    setSummaryData(item);
                });

            }

            let max = query.current.getData('max');

            if (max.length > 0) {

                max.forEach((item: any) => {
                    setMaxData(item);
                });

            }

            let list = query.current.getData('list');
            let mapData = toMapData(list);
            setListData(mapData);

            //console.log('map data size - ' + mapData.size)

            setHotListData(query.current.getData('hot_list'));

        })

    }, [location]);

    const pushLocation = (location: any) => {
        locationStack.current.push(location);
        setLocation(location);
    }

    const popLocation = () => {
        locationStack.current.pop();
        setLocation(locationStack.current[locationStack.current.length - 1]);
    }

    function olSelectHandler(name: string) {
        pushLocation(name);
        console.log('location selection ' + name);
    }

    function locationUUID() {
        let uuid: string = 'THE WORLD';
        if (locationStack.current.length >= 1) {
            uuid += '-' + locationStack.current[0];
        }
        if (locationStack.current.length >= 2) {
            uuid += '-' + locationStack.current[1];
        }
        return uuid;
    }

    return (
        <Layout style={{overflow: 'auto'}}>
            <PageHeader title={summaryData.location}
                        extra={[locationStack.current.length>0 ? (<Button key={'Close'} style={{width: 70}} onClick={() => popLocation()}
                                        type={"primary"}>Close</Button>) : '']}

            >
                <Descriptions size="small" column={1} bordered>
                    <Descriptions.Item>{summaryData.commentary}</Descriptions.Item>
                </Descriptions>
            </PageHeader>
            <Row>
                <LevelMap listData={listData} maxData={maxData} locationAlias={''}
                          selectHandler={(name) => olSelectHandler(name)} location={locationUUID()}/>
            </Row>
            <Row>
                <SummaryMeasures summaryData={summaryData}/>
            </Row>
            <Row>
                <HotList data={hotListData}/>
            </Row>

        </Layout>
    );


}

export default LevelDetail;


import React, {useEffect, useRef, useState} from "react";
import {Button, Descriptions, Layout, PageHeader} from "antd";
import LevelMap from "./components/LevelMap";
import {QueryData} from "../components/QueryData";
import SummaryMeasures from "./components/SummaryMeasures";
import HotList from "./components/HotList";
import PeriodTrends from "./components/PeriodTrends";


const LevelDetail = () => {
    const query = useRef(new QueryData('hpccsystems_covid19_query_location_map'));

    const [location, setLocation] = useState<string>('');
    const locationStack = useRef<any>([]);

    //Data
    const [summaryData, setSummaryData] = useState<any>([]);
    const [maxData, setMaxData] = useState<any>([]);
    const [listData, setListData] = useState<any>(new Map());
    const [periodTrendsColumnData, setPeriodTrendsColumnData] = useState<any>([]);
    const [periodTrendsGroupedData, setPeriodTrendsGroupedData] = useState<any>([]);
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

            setPeriodTrendsColumnData(query.current.getData('period_trend_column'));
            setPeriodTrendsGroupedData(query.current.getData('period_trend_grouped'));
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
        console.log('location selection ' + name);

        pushLocation(name);

    }

    function locationUUID() {
        let uuid: string = 'THE WORLD';
        if (locationStack.current.length >= 1) {
            uuid += '-' + locationStack.current[0];
        }
        if (locationStack.current.length >= 2) {
            uuid += '-' + locationStack.current[1];
        }
        if (locationStack.current.length >= 3) {
            uuid += '-' + locationStack.current[2];
        }
        return uuid;
    }

    return (
        <Layout >
            <div style={{textAlign:"center"}}>
                <Button href={"#commentary"} type={"link"} className={"anchor-btn"}>Commentary/Top</Button>
                <Button href={"#map"} type={"link"} className={"anchor-btn"}>Map</Button>
                <Button href={"#summary_stats"} type={"link"} className={"anchor-btn"}>Stats</Button>
                <Button href={"#trends"} type={"link"} className={"anchor-btn"}>Trends</Button>
                <Button href={"#hot_spots"} type={"link"} className={"anchor-btn"}>Hot Spots</Button>
            </div>

            <Layout style={{overflow: 'auto', paddingLeft: 10, paddingRight: 10}}>

                <div id={"commentary"}/>

                <PageHeader title={summaryData.location}
                            extra={[locationStack.current.length > 0 ? (
                                <Button key={'Back'} style={{width: 70}} onClick={() => popLocation()}
                                        type={"primary"}>Back</Button>) : '']}

                >
                    <Descriptions size="small" column={1} bordered>
                        <Descriptions.Item>{summaryData.commentary}</Descriptions.Item>
                    </Descriptions>

                </PageHeader>


                <Layout.Content>
                    <div id={"map"}/>
                    <LevelMap listData={listData} maxData={maxData} locationAlias={''}
                              selectHandler={(name) => olSelectHandler(name)} location={locationUUID()}/>
                    <div id={"summary_stats"} style={{height: 10}}/>
                    <SummaryMeasures summaryData={summaryData}/>

                    <div id={"trends"} style={{height: 10}}/>
                    <PeriodTrends columnData={periodTrendsColumnData} groupedData={periodTrendsGroupedData}/>
                    <div id={"hot_spots"} style={{height: 10}}/>
                    <HotList data={hotListData}/>
                </Layout.Content>
            </Layout>
        </Layout>
    );


}

export default LevelDetail;


import React, {useEffect} from "react";
import {Tabs} from "antd";
import {QueryData} from "../../components/QueryData";
import ColumnChart from "../../components/ColumnChart";


const {TabPane} = Tabs;

interface HomeProps {

}

export function WorldHome(props: HomeProps) {

    const [worldData] = React.useState(new QueryData('hpccsystems_covid19_query_trends'));
    const [topConfirmed, setTopConfirmed] = React.useState([]);
    const [topDeaths, setTopDeaths] = React.useState([]);
    const [topConfirmedIncrease, setConfirmedIncrease] = React.useState([]);
    const [topDeathsIncrease, setDeathsIncrease] = React.useState([]);

    useEffect(() => {
        let filters: Map<string, string> = new Map();
        filters.set('typeFilter', 'countries');
        filters.set('topX', '10');
        worldData.initData(filters).then(() => {
            setTopConfirmed(worldData.getData('top_confirmed'));
            setTopDeaths(worldData.getData('top_deaths'));
            setConfirmedIncrease(worldData.getData('top_confirmed_increase'));
            setDeathsIncrease(worldData.getData('top_deaths_increase'));
        });
    }, [worldData]);

    return (

                    <div>
                        <ColumnChart title={'Countries with the largest confirmed cases'}
                                     yField={'confirmed'}
                                     xField={'location'}
                                     data={topConfirmed}
                                     columnColor={'#6294f8'}/>
                        <ColumnChart title={'Countries with the largest deaths'}
                                     yField={'deaths'}
                                     xField={'location'}
                                     columnColor={'#fad866'}
                                     data={topDeaths}/>
                        <ColumnChart title={'Countries with the largest increase in confirmed cases'}
                                     yField={'confirmed_increase'}
                                     xField={'location'}
                                     data={topConfirmedIncrease}
                                     columnColor={'#6294f8'}/>
                        <ColumnChart title={'Countries with the largest increased in deaths'}
                                     yField={'deaths_increase'}
                                     xField={'location'}
                                     columnColor={'#fad866'}
                                     data={topDeathsIncrease}/>
                    </div>


    )

}
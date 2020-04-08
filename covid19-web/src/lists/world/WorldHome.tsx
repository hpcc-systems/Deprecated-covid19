import React, {useEffect} from "react";
import {Tabs} from "antd";
import {QueryData} from "../../components/QueryData";
import ColumnChart from "../../components/ColumnChart";


const {TabPane} = Tabs;

interface HomeProps {

}

export function WorldHome(props: HomeProps) {

    const [worldData] = React.useState(new QueryData('hpccsystems_covid19_query_summary_world'));
    const [topConfirmed, setTopConfirmed] = React.useState([]);
    const [topDeaths, setTopDeaths] = React.useState([]);
    const [topConfirmedIncrease, setConfirmedIncrease] = React.useState([]);
    const [topDeathsIncrease, setDeathsIncrease] = React.useState([]);

    useEffect(() => {
        worldData.initData(undefined).then(() => {
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
                                     xField={'country'}
                                     data={topConfirmed}
                                     columnColor={'#6294f8'}/>
                        <ColumnChart title={'Countries with the largest deaths'}
                                     yField={'deaths'}
                                     xField={'country'}
                                     columnColor={'#fad866'}
                                     data={topDeaths}/>
                        <ColumnChart title={'Countries with the largest increase in confirmed cases'}
                                     yField={'confirmed_increase'}
                                     xField={'country'}
                                     data={topConfirmedIncrease}
                                     columnColor={'#6294f8'}/>
                        <ColumnChart title={'Countries with the largest increased in deaths'}
                                     yField={'deaths_increase'}
                                     xField={'country'}
                                     columnColor={'#fad866'}
                                     data={topDeathsIncrease}/>
                    </div>


    )

}
import React, {useEffect} from "react";
import {Tabs} from "antd";
import {QueryData} from "../../components/QueryData";
import ColumnChart from "../../components/ColumnChart";


const {TabPane} = Tabs;

interface HomeProps {

}

export function StatesHome(props: HomeProps) {

    const [statesData] = React.useState(new QueryData('hpccsystems_covid19_query_summary_us'));
    const [topConfirmed, setTopConfirmed] = React.useState([]);
    const [topDeaths, setTopDeaths] = React.useState([]);
    const [topConfirmedIncrease, setConfirmedIncrease] = React.useState([]);
    const [topDeathsIncrease, setDeathsIncrease] = React.useState([]);

    useEffect(() => {
        statesData.initData(undefined).then(() => {
            setTopConfirmed(statesData.getData('top_confirmed'));
            setTopDeaths(statesData.getData('top_deaths'));
            setConfirmedIncrease(statesData.getData('top_confirmed_increase'));
            setDeathsIncrease(statesData.getData('top_deaths_increase'));
        });
    }, [statesData]);

    return (

        <div>
            <ColumnChart title={'States with the largest confirmed cases'}
                         yField={'confirmed'}
                         xField={'state'}
                         data={topConfirmed}
                         columnColor={'#6294f8'}/>
            <ColumnChart title={'States with the largest deaths'}
                         yField={'deaths'}
                         xField={'state'}
                         columnColor={'#fad866'}
                         data={topDeaths}/>
            <ColumnChart title={'States with the largest increase in confirmed cases'}
                         yField={'confirmed_increase'}
                         xField={'state'}
                         data={topConfirmedIncrease}
                         columnColor={'#6294f8'}/>
            <ColumnChart title={'States with the largest increased in deaths'}
                         yField={'deaths_increase'}
                         xField={'state'}
                         columnColor={'#fad866'}
                         data={topDeathsIncrease}/>
        </div>


    )

}
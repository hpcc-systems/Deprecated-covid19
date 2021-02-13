import {Descriptions} from "antd";
import React from "react";

export default function VaccineTerms() {
    return (
        <div style={{width: 800, height: 500, overflow: 'auto', paddingLeft: 10, paddingRight: 10}}>
            <Descriptions column={1}>
                <Descriptions.Item label="Vaccine Total Distributed">
                    The total number of vaccines distributed to the given location.
                </Descriptions.Item>
                <Descriptions.Item label="Vaccine Total Administered">
                    The total number of vaccine doses that were administered.
                </Descriptions.Item>
                <Descriptions.Item label="People Partially Vaccinated">
                    The number of people who have received at least one dose of a multi-dose vaccine, but have not yet recieved all doses (not available for all locations).
                </Descriptions.Item>
                <Descriptions.Item label="People Fully Vaccinated">
                    The number of people who have received all of the required doses of any vaccine, whether single dose or multi-dose (not available for all locations).
                </Descriptions.Item>
                <Descriptions.Item label="Population Fully Vaccinated">
                    The percent of the population that has recieved all of the required doses of any vaccine (not available for all locations).
                </Descriptions.Item>
                <Descriptions.Item label="Vaccine Dose Administered">
                    The percent of the distributed vaccines that have been administered (not available for all locations). 
                </Descriptions.Item>
                <Descriptions.Item label="People Fully Vaccinated in the week">
                    The number of vaccine final doses administered during the period (e.g. week).
                </Descriptions.Item>
                <Descriptions.Item label="People Getting at least one vaccine in the week">
                    The number of vaccine doses administered during the period (e.g. week).
                </Descriptions.Item>
            </Descriptions>
        </div>

    )
}
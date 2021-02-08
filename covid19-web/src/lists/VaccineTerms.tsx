import {Descriptions} from "antd";
import React from "react";

export default function VaccineTerms() {
    return (
        <div style={{width: 800, height: 500, overflow: 'auto', paddingLeft: 10, paddingRight: 10}}>
            <Descriptions column={1}>
                <Descriptions.Item label="Vaccine Total Distributed">
                    Vaccine Total Distributed
                </Descriptions.Item>
                <Descriptions.Item label="Vaccine Total Administered">
                    Vaccine Total Administered
                </Descriptions.Item>
                <Descriptions.Item label="People Partially Vaccinated">
                    People Partially Vaccinated
                </Descriptions.Item>
                <Descriptions.Item label="People Fully Vaccinated">
                    People Fully Vaccinated
                </Descriptions.Item>
                <Descriptions.Item label="Population Fully Vaccinated">
                    Population Fully Vaccinated
                </Descriptions.Item>
                <Descriptions.Item label="Vaccine Dose Administered">
                    Vaccine Dose Administered
                </Descriptions.Item>
                <Descriptions.Item label="Population Fully Vaccinated">
                    Population Fully Vaccinated
                </Descriptions.Item>
                <Descriptions.Item label="People Fully Vaccinated in the week">
                    People Fully Vaccinated in the week
                </Descriptions.Item>
                <Descriptions.Item label="People Getting at least one vaccine in the week">
                    People Getting at least one vaccination in the week
                </Descriptions.Item>
            </Descriptions>
        </div>

    )
}
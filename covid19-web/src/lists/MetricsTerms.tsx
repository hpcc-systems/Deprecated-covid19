import {Descriptions} from "antd";
import React from "react";

export default function StatusTerms() {
    return (
        <div style={{width: 700}}>
            <Descriptions column={1}>
                <Descriptions.Item label="cR">
                    Compound growth factor for Confirmed Cases. This is an indicator of the degree of spread and
                    should decrease with social distancing. In the absence of immunity and social mitigation's,
                    this would be equal to R0 (the natural spread rate of a virus).
                </Descriptions.Item>
                <Descriptions.Item label="mR">
                    Compound growth rate for Deaths. Though this lags the cR, it may be a better proxy for
                    actual number of cases because it is not confounded by test availability and policy.
                </Descriptions.Item>
                <Descriptions.Item label="sdIndicator">
                    Shows progress in social distancing behavior from period to period. Positive values indicate
                    progress in slowing the spread. Negative values indicate that the rate of spread is
                    increasing.

                </Descriptions.Item>
                <Descriptions.Item label="medIndicator">
                    Shows progress in medical performance from period to period. Positive values indicate
                    improvement. Negative values may indicate overload conditions. A negative value early on in
                    a
                    given location’s progress may indicate a lack of testing or diagnosis. A return to negative
                    later in the cycle can indicate an erosion in the quality of medical care.
                </Descriptions.Item>

                <Descriptions.Item label="iMort">
                    This is an approximation of Infection Mortality which is the likelihood that someone who
                    tests positive for the infection will die as a result of the infection. This number may be
                    exaggerated during the very early stages of the infection in a location due to lack of
                    diagnosis and testing.
                </Descriptions.Item>
                <Descriptions.Item label="HeatIndex">
                    This is a composite indicator designed to reflect a broad aspect of a location’s progress.
                    Higher values indicate locations with higher risk. This indicator combines Case Growth (cR),
                    Mortality Growth (mR), Social Distancing (sdIndicator) and Medical Indicator (medIndicator).
                    This indicator is designed to flag locations that are in need of attention, due to high
                    rates of
                    spread or that have begun to regress (e.g. as a result of loosened social distancing or
                    medical
                    overload).
                </Descriptions.Item>
            </Descriptions>
        </div>

    )
}
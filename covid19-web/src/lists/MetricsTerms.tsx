import {Descriptions} from "antd";
import React from "react";

export default function MetricsTerms() {
    return (
        <div style={{width: 700}}>
            <Descriptions column={1}>
                <Descriptions.Item label="Contagion Risk">
                    The estimated probability of meeting at least one actively infected person during 100 random encounters within
                    a given location.  This is based on an evolving estimate of the number of active infections which is subject to
                    refinement as more data becomes available.  It should be
                    used for comparing the relative risk of various locations.  It should not be taken as the actual probability of
                    becoming infected, which depends on many factors, including an individuals succeptibility, the behavior of
                    infected individuals, and the specifics of each encounter.
                </Descriptions.Item>
                <Descriptions.Item label="Infection State">
                    The qualitative state of an infection within a location.  Possible states are (from best to worst): 
                    Initial/Recovered, Recovering, Stabilized, Stabilizing, Emerging, and Spreading.  Emerging indicates
                    a quickly spreading infection that is still small enough to be contained.  See the "GITHUB" link at
                    the top of the main page for full documentation of each state.
                </Descriptions.Item>
                <Descriptions.Item label="R">
                    Estimation of the Effective Reproductive Growth Rate of the infection based on a composite of confirmed cases
                    and deaths. 
                    This can be understood as the average number of people infected by each infected individual during the course
                    of their infection.  If this number is greater than 1.0, the number of infections is growing,
                    while a value below 1.0 indicates that the number of infections is shrinking.
                    In the absence of immunity and social mitigation's,
                    this would be equivalent to R0 (the natural spread rate of a virus).
                </Descriptions.Item>
                <Descriptions.Item label="cR">
                    An estimate of R (see above) based on the growth rate of Confirmed Cases. This is an indicator of the
                    degree of spread and should decrease with social distancing.  It can misrepresent the effective
                    growth rate during times of rapid change in testing policy and availability.
                </Descriptions.Item>
                <Descriptions.Item label="mR">
                    An estimate of R (see above) based on the growth rate of Deaths. Though this lags the cR, it may be a better proxy for
                    actual number of infections because it is not confounded by test policy and availability.  This may
                    misrepresent the effective growth rate during times of rapid changes in medical capability.
                </Descriptions.Item>
                <Descriptions.Item label="sdIndicator">
                    Shows progress in social distancing behavior from period to period. Positive values indicate
                    improvement in social distancing while negative values indicate that the level of social distancing
                    is increasing.  Increased social distancing (while other factors are constant) results in decreased
                    rate of infection growth.
                </Descriptions.Item>
                <Descriptions.Item label="medIndicator">
                    Shows progress in medical performance from period to period. Positive values indicate
                    improvement. Negative values may indicate overload conditions. A negative value early on in
                    a given location’s progress may indicate a lack of testing or diagnosis. A return to negative
                    later in the cycle can indicate an erosion in the quality of medical care.
                </Descriptions.Item>
                <Descriptions.Item label="Case Fatality Rate (CFR)">
                    The likelihood that a person who tests positive for the virus will die from the infection.
                    This number may be
                    exaggerated during the very early stages of the infection in a location due to lack of
                    diagnosis and testing.
                </Descriptions.Item>
                <Descriptions.Item label="Infection Fatality Rate (IFR)">
                    The likelihood that a person who is infected will die from the infection.  This number is based
                    on an evolving estimate of the number of actual infections, should not be considered a final value.
                </Descriptions.Item>
                <Descriptions.Item label="Short-Term Indicator(STI)">
                    Negative values indicate a likely worsening of the infection rate R within one to three days.
                    Positive values indicate that the infection is likely to slow in the short term.
                </Descriptions.Item>
                <Descriptions.Item label="Early Warning Indicator(EWI)">
                    Identifies inflection points in the spread of the virus.  A negative value suggests
                    that an infection is transitioning from a neutral or recovering phase to a growth phase.
                    A positive value indicates a transition from growth to stability.  The magnitude indicates
                    the strength and speed of the transition.  A zero value indicates that no major transition is iminent.
                    The timeframe of this indicator is three days to two weeks.
                </Descriptions.Item>
                <Descriptions.Item label="HeatIndex">
                    This is a composite indicator designed to reflect a broad aspect of a location’s progress.
                    Higher values indicate locations with higher risk. This indicator combines Case Growth (cR),
                    Mortality Growth (mR), Social Distancing (sdIndicator), Medical Indicator (medIndicator), and
                    Contagion Risk.
                    This indicator is calibrated such that values of 1.0 or greater flag locations that are in need
                    of attention or intervention.
                </Descriptions.Item>
            </Descriptions>
        </div>

    )
}
import React from 'react';
import {Button, Card, Col, Layout, Popover, Row, Statistic} from "antd";
import VaccineTerms from "../VaccineTerms";


interface VaccineMeasuresProps {
    summaryData: any;
}

const VaccineMeasures = (props: VaccineMeasuresProps) => {

    const renderOptionalValue= (value: any, postfix: string = '') => {
        if (value || value !== 0) {
            return value + postfix
        } else {
            return 'No Data Available'
        }
    }
    return (
        <Layout style={{width:"100%"}}>
            <div style={{fontSize: 16, fontWeight: 'bold', paddingBottom: 10, paddingTop: 10}}>Vaccine Data
                <Popover key={'popover_vaccine_terms'} title={"Vaccine Terms"} content={<VaccineTerms/>}
                         trigger={"click"}><Button  type={"link"}>Vaccine
                    Terms</Button></Popover>
            </div>

            <Row>
                <Col span={12}>
                    <Card>
                        <Statistic
                            title={"Vaccine Total Distributed - " + props.summaryData.date_string}
                            value={renderOptionalValue(props.summaryData.vacc_total_dist)}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={12} style={{paddingLeft: 25}}>
                    <Card>
                        <Statistic
                            title={"Vaccine Total Administered - " + props.summaryData.date_string}
                            value={renderOptionalValue(props.summaryData.vacc_total_admin)}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
            </Row>
            <Row>
                <Col span={12}>
                    <Card>
                        <Statistic
                            title={"People partially vaccinated - " + props.summaryData.date_string}
                            value={renderOptionalValue(props.summaryData.vacc_total_people-props.summaryData.vacc_people_complete)}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={12} style={{paddingLeft: 25}}>
                    <Card>
                        <Statistic
                            title={"People fully vaccinated - " + props.summaryData.date_string}
                            value={renderOptionalValue(props.summaryData.vacc_people_complete)}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
            </Row>
            <Row>
                <Col span={12}>
                    <Card>
                        <Statistic
                            title={"Population fully vaccinated - " + props.summaryData.date_string}
                            value={renderOptionalValue(props.summaryData.vacc_complete_pct ,  "%")}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={12} style={{paddingLeft: 25}}>
                    <Card>
                        <Statistic
                            title={"Vaccine Dose Administered  - " + props.summaryData.date_string}
                            value={renderOptionalValue(props.summaryData.vacc_admin_pct, ' %')}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
            </Row>

            <Row>
                <Col span={12}>
                    <Card>
                        <Statistic
                            title={"People fully vaccinated in the week - " + props.summaryData.period_string}
                            value={renderOptionalValue(props.summaryData.vacc_period_complete)}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>
                <Col span={12} style={{paddingLeft: 25}}>
                    <Card>
                        <Statistic
                            title={"People getting at least one vaccine in the week - " + props.summaryData.period_string}
                            value={renderOptionalValue(props.summaryData.vacc_period_people)}
                            valueStyle={{color: '#cf1322'}}
                        />
                    </Card>
                </Col>

            </Row>



        </Layout>
    );


}

export default VaccineMeasures;
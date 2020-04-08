import React from "react";

import {Button, Drawer, Select} from "antd";



import {Space} from "antd/es";

const {Option} = Select;

interface Props {
    states: any;
    periods: any;
    defaultStatesValue: any;
    defaultPeriodValue: any;
    onFilterChange: (key: string, value: string) => void;
}


export function FilterDrawer(props: Props) {

    const [visible, setVisible] = React.useState(false);



    const renderStatesOptions = () => {
        return props.states.map((item: any) => {
            return <Option key={item.name} value={item.name} label={item.name}> {item.name}</Option>
        });
    };

    const renderPeriod = () => {
        if (props.periods) {
            return (
                <Select
                    style={{width: '100%'}}
                    placeholder="select a Period"
                    defaultValue={props.defaultPeriodValue}
                    onChange={(value: any) => props.onFilterChange('periodFilter', value)}
                    optionLabelProp="label"
                >
                    {renderPeriodsOptions()}
                </Select>
            );
        } else {
            return ('');
        }

    };

    const renderPeriodsOptions = () => {
        return props.periods.map((item: any) => {
            return <Option key={item.period} value={item.period} label={item.period}> {item.name}</Option>
        });
    };

    return (

        <div>

            <Drawer
                title="Apply Filters"
                placement={'right'}
                closable={false}
                onClose={() => setVisible(false)}
                visible={visible}
            >
                <Space direction={'vertical'}>
                            <div>Select (Multiple) States</div>
                            <Select
                                mode="multiple"
                                style={{ width: '100%' }}
                                placeholder="select one state"
                                defaultValue={props.defaultStatesValue}
                                onChange={(value: any) => props.onFilterChange('statesFilter',value)}
                                optionLabelProp="label"

                            >
                                {renderStatesOptions()}
                            </Select>

                            {renderPeriod()}

                    <Button type="primary" onClick={() => setVisible(false)}>
                        Close
                    </Button>
                </Space>

            </Drawer>

            <Button type="primary" onClick={() => setVisible(true)}>
                Filter
            </Button>
        </div>
    )


}


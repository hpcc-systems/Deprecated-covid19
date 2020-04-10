import {Select} from "antd";
import React from "react";
const {Option} = Select;

export interface FilterData {
    id: string;
    title: string;
}

interface Props {
    title: string;
    data: FilterData[];
    value: string|string[];
    mode: "multiple"|"tags"|undefined;
    onFilterChange: (value: string) => void;
}


export function FilterRenderer(props: Props) {

    const renderOptions = () => {
        return props.data.map((item) => {
            return <Option key={item.id} value={item.id} label={item.title}> {item.title}</Option>
        });
    };

    return (
        <div>
            <div>{props.title}</div>
            <Select
                mode={props.mode}
                style={{width: '100%'}}
                placeholder="select a Period"
                value={props.value}
                onChange={(value: any) => props.onFilterChange(value)}
                optionLabelProp="label"
            >
                {renderOptions()}
            </Select>
        </div>
    )

}
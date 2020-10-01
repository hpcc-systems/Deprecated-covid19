import React, {useEffect, useRef, useState} from 'react';
import {Map, View} from 'ol';
import {Vector as VectorLayer} from 'ol/layer';

import 'ol/ol.css';
import GeoJSON from 'ol/format/GeoJSON';
import VectorSource from "ol/source/Vector";
import Select from "ol/interaction/Select";
import {pointerMove} from "ol/events/condition";
import {Fill, Stroke, Style, Text} from 'ol/style';
import {FeatureLike} from "ol/Feature";
import Overlay from "ol/Overlay";
import {fromLonLat} from "ol/proj";
import {defaults as defaultInteractions} from 'ol/interaction.js'
import OverlayPositioning from "ol/OverlayPositioning";
import {Button, Card, Col, Modal, Row, Select as DropdownSelect, Space, Statistic} from "antd";
import {
    CaretLeftFilled,
    CaretRightFilled,
    LeftCircleFilled,
    PauseCircleFilled,
    RightCircleFilled,
    StepBackwardFilled,
    StepForwardFilled
} from '@ant-design/icons';
import {Bar} from "@antv/g2plot";
import {Chart} from "./Chart";


interface Props {
    geoFile: string;
    secondaryGeoFile?: string;
    geoLat: number;
    geoLong: number;
    selectKeyField: string;
    colorKeyField: string;
    zoom: number;
    height: string;
    heatMapType: string;
    data: any;
    maxData: any;
}

function useStateRef(initialValue: any) {
    const [value, setValue] = useState(initialValue);

    const ref = useRef(value);

    useEffect(() => {
        ref.current = value;
    }, [value]);

    return [value, setValue, ref];
}

export default function OlRangeMap(props: Props) {
    const container = useRef<HTMLElement | null>(null);
    const popup = useRef<HTMLElement | null>(null);
    const [period, setPeriod, periodRef] = useStateRef ("1");
    const heatMapTypeRef = useRef ("contagion_risk");
    const [timerOn, setTimerOn, timerOnRef] = useStateRef(false);
    const [selectedLocation, setSelectedLocation] = useState<any>("");
    const [dialogVisible, setDialogVisible] = useState(false);

    const toolTipHandler = (name: string):string => {
        return "";
    }

    const colorHandler = (name: string): string => {
        if (!name) return '#a1a080';

        let row = props.data.get(periodRef.current).map.get(name.toUpperCase());

        if (row) {
            //console.log('Color location: ' + name.toUpperCase() +  ', CR = ' + row.contagion_risk + ', Period = ' + periodRef.current);
            //console.log("color change: " + heatMapTypeRef.current);
            let d = 0;
            switch (heatMapTypeRef.current) {
                case 'cases':
                    d = row.cases / Math.max(1, props.maxData.casesMax);
                    break;
                case 'new_cases':
                    d = row.period_new_cases / Math.max(1, props.maxData.periodNewCasesMax);
                    break;
                case 'deaths':
                    d = row.deaths / Math.max(1, props.maxData.deathsMax);
                    break;
                case 'new_deaths':
                    d = row.period_new_deaths / Math.max(1, props.maxData.periodNewDeathsMax);
                    break;
                case 'cases_per_capita':
                    d = row.cases_per_capita / Math.max(1, 1000);
                    break;
                case 'deaths_per_capita':
                    d = row.deaths_per_capita / Math.max(1, 60);
                    break;
                case 'contagion_risk':
                    d = row.contagion_risk;
                    return d >= 0.5 ? '#a50026' :
                        d >= 0.25 ? '#d73027' :
                            d >= 0.15 ? '#fdae61' :
                                d >= 0.05 ? '#fee08b' :
                                    d > 0 ? '#66bd63' :
                                        '#1a9850';
                case 'status':
                    d = row.status_numb;
                    if (d >= 6) {
                        return '#a50026'
                    } else if (d === 5) {
                        return '#d73027'
                    } else if (d === 4) {
                        return '#fdae61'
                    } else if (d === 3) {
                        return '#fee08b'
                    } else if (d === 2) {
                        return '#66bd63'
                    } else {
                        return '#1a9850'
                    }

            }

            return d >= 0.9 ? '#a50026' :
                d > 0.6 ? '#d73027' :
                    d > 0.4 ? '#fdae61' :
                        d > 0.2 ? '#fee08b' :
                            d > 0.1 ? '#66bd63' :
                                '#1a9850';
        } else return '#2b2b2b';

    }

    const selectHandler = (name: string) => {
        if (!name) return '';


        setSelectedLocation(name.toUpperCase());
        setDialogVisible(true);
    }

    const measureHandler =  (name: string) => {
        if (!name) return '';

        let row = props.data.get(periodRef.current).map.get(name.toUpperCase());

        //console.log('Color location: ' + name.toUpperCase() +  ' -- ' + name.length + '  ' + row);

        if (row) {
            let d = '';
            switch (heatMapTypeRef.current) {
                case 'cases':
                    d = formatNumber(row.cases);
                    break;
                case 'new_cases':
                    d = formatNumber(row.period_new_cases);
                    break;
                case 'deaths':
                    d = formatNumber(row.deaths);
                    break;
                case 'new_deaths':
                    d = formatNumber(row.period_new_deaths);
                    break;
                case 'cases_per_capita':
                    d = formatNumber(row.cases_per_capita);
                    break;
                case 'deaths_per_capita':
                    d = formatNumber(row.deaths_per_capita);
                    break;
                case 'contagion_risk':
                    d = Math.round(row.contagion_risk * 100) +
                        "%";
                    break;
                case 'status': d= '' //d = row.status ;
            }

            return d;
        } else return '';

    }

    const formatNumber: any = (value: any) => {
        if (value) {
            return value.toLocaleString();
        } else {
            return '0';
        }
    }

    function selectFunction(feature: FeatureLike) {
        const style = new Style({
            fill: new Fill({
                color: getColor(feature),
            }),
            stroke: new Stroke({
                color: 'black',
                width: 3,
            }),
            text: new Text({
                font: '9px Calibri,sans-serif',
                fill: new Fill({
                    color: '#000',
                }),
                stroke: new Stroke({
                    color: 'gray',
                    width: 1,
                }),
            }),
        });

        let text = feature.get(props.selectKeyField).toUpperCase();
        style.getText().setText(text + ' ' + measureHandler(feature.get(props.colorKeyField)));
        return style;
    }

    function getColor(feature: any) {
        let color = colorHandler(feature.get(props.colorKeyField));
        //console.log("color " + color);
        return color;
    }

    const overlay = new Overlay({
        offset: [10, 0],
        positioning:OverlayPositioning.TOP_LEFT,

    });

    const map = useRef<Map | null>(null);

    function colorLayer(geoJsonFileName: string,
                        geoKeyField: string,
                        borderColor: string,
                        borderWidth: number,
                        fillColor: string,
                        showLabel: boolean) {
        return new VectorLayer({
            source: new VectorSource({
                url: geoJsonFileName,
                format: new GeoJSON()
            }),
            style: function (feature) {
                const style = new Style({
                    fill: new Fill({
                        color: fillColor === '' ? getColor(feature) : fillColor,
                    }),
                    stroke: new Stroke({
                        color: borderColor,
                        width: borderWidth,
                    }),
                    text: new Text({
                        font: '9px Calibri,sans-serif',
                        fill: new Fill({
                            color: '#000',
                        }),
                        stroke: new Stroke({
                            color: 'gray',
                            width: 1,
                        }),
                    }),
                });

                let text = feature.get(props.selectKeyField).toUpperCase();
                style.getText().setText(showLabel ?  text + ' ' + measureHandler(feature.get(props.colorKeyField)) : '');
                return style;
            },
        });
    }

    const initMap = () => {
        if (map.current !== null)
            map.current.dispose();


        map.current = new Map({
            overlays: [overlay],
            view: new View({
                center: [0, 0],
                zoom: 2
            }),
            interactions: defaultInteractions({
                doubleClickZoom: false,
                dragPan: true,
                mouseWheelZoom: false
            }),
        });

        if (container.current && popup.current && map.current !== null) {

            let layer: VectorLayer = colorLayer(props.geoFile, props.colorKeyField, '#319FD3', 1, '', true);
            map.current.addLayer(layer);

            if (props.secondaryGeoFile) {
                let secondaryLayer: VectorLayer = colorLayer(props.secondaryGeoFile,
                    'name',
                    'lightblue',
                    2, 'transparent', false);
                map.current.addLayer(secondaryLayer);
            }

            map.current.getView().setCenter(fromLonLat([props.geoLong, props.geoLat]))
            map.current.getView().setZoom(props.zoom);

            overlay.setElement(popup.current);
            map.current.setTarget(container.current);

            let selectMouseMove = new Select({
                layers: [layer],
                condition: pointerMove,
                style: selectFunction
            });

            selectMouseMove.on('select', function (e: any) {
                if (e.selected.length > 0) {
                    let feature = e.selected[0];
                    if (popup.current) {
                        popup.current.innerHTML = toolTipHandler(feature.get(props.colorKeyField));
                        overlay.setPosition(e.mapBrowserEvent.coordinate);
                    }
                } else {
                    toolTipHandler('');
                    if (popup.current) {
                        popup.current.innerHTML = '';
                    }
                }
            });

            map.current.addInteraction(selectMouseMove);

            map.current.on('singleclick', function (evt) {
                if (map.current !== null) {
                    map.current.forEachFeatureAtPixel(evt.pixel,
                        function (feature, l) {
                            if (l === layer) {
                                selectHandler(feature.get(props.colorKeyField));
                                return [feature, layer];
                            }
                        });
                }
            });

            map.current.updateSize();
            map.current.render();
        }

   }

    useEffect((initMap), [props.geoFile]);

    useEffect(() => {
        if (map.current !== null) {
            heatMapTypeRef.current = props.heatMapType;
        }
    }, [props.heatMapType]);

    useEffect(() => {
        if (map.current !== null) {
            //console.log("use effect " + props.heatMapType);
            map.current.getLayers().forEach((layer) => {
                (layer as VectorLayer).getSource().changed();
            })
        }
    })

    const chartModelData = (selectedData: any) => {

        return [{"name": "Contagion Risk", "value": selectedData.contagion_risk},
        {"name": "Infection Rate (R)", "value": selectedData.r},
        {"name": "Cases Rate (cR)", "value": selectedData.cr},
        {"name": "Mortality Rate (mR)", "value": selectedData.mr},
        {"name": "Social Distance Indicator", "value": selectedData.sd_indicator},
        {"name": "Medical Indicator", "value": selectedData.med_indicator},
        {"name": "Case Fatality Rate", "value": selectedData.cfr},
        {"name": "Infection Fatality Rate", "value": selectedData.ifr},
        {"name": "Heat Index", "value": selectedData.heat_index},
        {"name": "Short Term Indicator", "value": selectedData.sti},
        {"name": "Early Warning Indicator", "value": selectedData.ewi},
        {"name": "Immune Percent", "value": selectedData.immune_pct/100.0},
    ]};

    const chartModel = {
        padding: 'auto',
        title: {
            text: 'Weekly Metrics',
            visible: false,
            style: {fontSize: 14, fontWeight: 'bold'}
        },
        forceFit: true,
        label: {
            visible: true,
            style: {
                strokeColor: 'black'
            }
        },
        xAxis: {
            title: {visible: false}
        },
        color: (d: any) => {
            return d === 'Infection Rate (R)' ? '#6394f8' :
                d === 'Case Rate (cR)' ? '#61d9aa' :
                    d === 'Mortality Rate (mR)' ? '#657797' :
                        d === 'Social Distance Indicator' ? '#f6c02c' :
                            d === 'Medical Indicator' ? '#7a4e48' :
                                d === 'Case Fatality Rate' ? '#6dc8ec' :
                                    d === 'Short Term Indicator' ? 'gray':
                                        d === 'Infection Fatality Rate' ? 'red':
                                            d === 'Early Warning Indicator' ? 'cyan':
                                                d === 'Immune Percent' ? 'lightgray': '#9867bc'
        },
        colorField: 'name',
        data: [],
        xField: 'value',
        yField: 'name',

    }


    const renderPeriodSelectors = () => {
        const items: any = [];
        props.data.forEach((value:any,key:any,map:any) => {
            //console.log(key);
            items.push( <DropdownSelect.Option key={key} value={key}>{value.period}</DropdownSelect.Option>);
        });
        return items;
    }

    const nextPeriod = () => {
        let p =period.valueOf();
        p++;
        if (props.data.get(p.toString())) {
            setPeriod(p.toString());
        }
    }

    const previousPeriod = () => {
        let p =period.valueOf();
        p--;
        if (props.data.get(p.toString())) {
            setPeriod(p.toString());
        }
    }

    function sleep(ms:number) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async function pause() {
       setTimerOn(false);
    }

    async function forward() {
        setTimerOn(true);
        await playPeriods();
        setTimerOn(false);
    }

    async function backward() {
        setTimerOn(true);
        await playPeriodsReverse();
        setTimerOn(false);
    }

    async function playPeriods()  {
        let p =periodRef.current.valueOf();
        p--;
        if (props.data.get(p.toString())) {
            setPeriod(p.toString());
            await sleep(1000);
            if (timerOnRef.current) {
                await playPeriods();
            }
        }
    }

    async function playPeriodsReverse()  {
        let p =periodRef.current.valueOf();
        p++;
        if (props.data.get(p.toString())) {
            setPeriod(p.toString());
            await sleep(1000);
            if (timerOnRef.current) {
                await playPeriodsReverse();
            }
        }
    }

    function startPeriod()  {
        setPeriod((props.data.size).toString());
    }

   function endPeriod()  {
       setPeriod("1");
    }

    const renderCommaFormattedValue= (value: any) => {
        if (value) {
            return Math.trunc(value).toLocaleString()
        } else {
            return ''
        }
    }
    const renderOptionalValue= (value: any) => {
        if (value) {
            return '  (' + value + ' per 100K)'
        } else {
            return ''
        }
    }

    let selectedData = [];
    if (props.data.get(period)) {
        selectedData = props.data.get(period).map.get(selectedLocation);
    }
    if (!selectedData) {
        selectedData = [];
    }

    return (
        <div>
            <div style={{paddingBottom:4}}>
                <Space>
                <DropdownSelect value={period}  style={{ width: 300}} onChange={(value)=> setPeriod(value)}>
                    {renderPeriodSelectors()}
                </DropdownSelect>
                <Button title={"Previous Period"}  disabled={timerOn} shape="circle" icon={<LeftCircleFilled/>} onClick={()=> nextPeriod()}/>
                <Button title={"Next Period"} disabled={timerOn} shape="circle"  icon={<RightCircleFilled/>} onClick={()=> previousPeriod()}/>
                <Button title={"First Period"} disabled={timerOn} icon={<StepBackwardFilled/>} onClick={()=> startPeriod()}/>
                <Button title={"Play Reverse"} disabled={timerOn} icon={<CaretLeftFilled/>} onClick={()=> backward()}/>
                <Button title={"Play Forward"} disabled={timerOn} icon={<CaretRightFilled/>} onClick={()=> forward()}/>
                <Button title={"Pause"} disabled={!timerOn} icon={<PauseCircleFilled/>} onClick={()=> pause()}/>
                <Button title={"Last/Current Period"} disabled={timerOn} icon={<StepForwardFilled/>} onClick={()=> endPeriod()}/>
                </Space>
            </div>

            <div style={{background: '#2b2b2b', height: props.height}} ref={(e) => (container.current = e)}/>
            <div ref={(e) => (popup.current = e)}/>

            <Modal visible={dialogVisible} width={1200}  onCancel={() => setDialogVisible(false)} onOk={()=>setDialogVisible(false)}
                   title={selectedData.location}
                   footer={[
                       <Button title={"Previous Period"}  disabled={timerOn} shape="circle" icon={<LeftCircleFilled/>} onClick={()=> nextPeriod()}/>,
                       <Button title={"Next Period"} disabled={timerOn} shape="circle"  icon={<RightCircleFilled/>} onClick={()=> previousPeriod()}/>,
                       <Button title={"First Period"} disabled={timerOn} icon={<StepBackwardFilled/>} onClick={()=> startPeriod()}/>,
                       <Button title={"Play Reverse"} disabled={timerOn} icon={<CaretLeftFilled/>} onClick={()=> backward()}/>,
                       <Button title={"Play Forward"} disabled={timerOn} icon={<CaretRightFilled/>} onClick={()=> forward()}/>,
                       <Button title={"Pause"} disabled={!timerOn} icon={<PauseCircleFilled/>} onClick={()=> pause()}/>,
                       <Button title={"Last/Current Period"} disabled={timerOn} icon={<StepForwardFilled/>} onClick={()=> endPeriod()}/>
                   ]} >
                <div style={{width:"100%"}}>
                    <Row>
                        <Col span={12}>
                            <div style={{fontSize: 16, fontWeight: 'bold', paddingBottom: 10, paddingTop: 10}}>Summary Statistics and
                                Metrics
                            </div>
                            <Card>
                                <Statistic
                                    title={"Total Cases" }
                                    value={renderCommaFormattedValue(selectedData.cases) + renderOptionalValue(selectedData.cases_per_capita)}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title={"Total Deaths"}
                                    value={renderCommaFormattedValue(selectedData.deaths) + renderOptionalValue(selectedData.deaths_per_capita)}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>

                            <Card>
                                <Statistic
                                    title={"Weekly New Cases - " + selectedData.period_string}
                                    value={selectedData.period_new_cases}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                            <Card>
                                <Statistic
                                    title={"Weekly New Deaths - " + selectedData.period_string}
                                    value={selectedData.period_new_deaths}
                                    valueStyle={{color: '#cf1322'}}
                                />
                            </Card>
                        </Col>
                        <Col span={12} style={{paddingLeft: 25}}>
                            <Row>
                                <div style={{fontSize: 16, fontWeight: 'bold', paddingBottom: 10, paddingTop: 10}}>
                                    {'Weekly Metrics ' + selectedData.period_string}
                                </div>
                                <Col span={24}>
                                    <Chart chart={Bar} config={chartModel} data={chartModelData(selectedData)}/>
                                </Col>
                            </Row>

                        </Col>

                    </Row>



                </div>

            </Modal>
        </div>

    )
}
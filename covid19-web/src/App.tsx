import React from "react";
import {Layout, Space} from "antd";
import './App.css';
import LevelDetail from "./lists/LevelDetail";

const App = () => {
    return (
        <Layout style={{height: "100vh"}}>
            <Layout.Header style={{paddingLeft: 0, height: 50, background: '#3a3939'}}>
                <Space size={50}>
                    <div className="logo"/>
                    <a style={{color: 'lightblue', fontSize: '9px', fontWeight: 'bold'}}
                       rel="noopener noreferrer" target={"_blank"} href={"open_database_license.pdf"}>Open
                        Database License</a>
                    <a style={{color: 'lightblue', fontSize: '9px', fontWeight: 'bold'}}
                       rel="noopener noreferrer" target={"_blank"}
                       href={"https://github.com/hpcc-systems/covid19"}>GitHub</a>
                </Space>
            </Layout.Header>

            <LevelDetail />
        </Layout>
    );
}

export default App;
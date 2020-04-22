import React, {useEffect} from "react";
import {Button, Card, Checkbox, Col, Form, Input, Layout, Row} from "antd";
import {  UserOutlined, LockOutlined } from '@ant-design/icons';

interface Props {
    onAuthenticate: (values: any) => void;
}


export function AuthForm(props: Props) {
    const layout = {
        labelCol: { span: 4 },
        wrapperCol: { span: 16 },
    };
        const onFinish = (values:any) => {
            props.onAuthenticate(values);
        };

    return(
        <Layout style={{textAlign:'center', height:'100%', width:'100%', verticalAlign:'center', background:'lightgray'}}>
        <Row>
        <Col span={8}/>
        <Col span={8} style={{padding:100}}>
        <Card style={{width:'100%'}} title={'Please enter your credentials to authenticate'}>
            <Form
                name="normal_login"
                className="login-form"
                initialValues={{ remember: true }}
                onFinish={onFinish}
            >
                <Form.Item
                    name="username"
                    rules={[{ required: true, message: 'Please input your Username!' }]}
                >
                    <Input prefix={<UserOutlined className="site-form-item-icon" />} placeholder="Username" />
                </Form.Item>
                <Form.Item
                    name="password"
                    rules={[{ required: true, message: 'Please input your Password!' }]}
                >
                    <Input
                        prefix={<LockOutlined className="site-form-item-icon" />}
                        type="password"
                        placeholder="Password"
                    />
                </Form.Item>


                <Form.Item>
                    <Button type="primary" htmlType="submit" className="login-form-button">
                        Log in
                    </Button>

                </Form.Item>
            </Form>
        </Card>
        </Col>
            <Col span={8}/>
        </Row>
        </Layout>
    )

}
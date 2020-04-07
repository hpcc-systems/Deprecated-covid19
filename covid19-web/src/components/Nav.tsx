import React from "react";
import {Card, Menu} from "antd";
import ListService, {ListMetadata} from "../services/ListService";
import {Module} from "../services/ModuleService";

const {SubMenu} = Menu;

interface NavProps {
    onSelect: (key: string) => void;
    selectedKey: string;
    module: Module | null;
}

interface NavState {
    navItems: ListMetadata[];
    listModuleId: string;
}

export  default class Nav extends React.Component<NavProps, NavState> {
    state = { navItems: [], listModuleId: ''};

    listService : ListService;

    constructor(props: NavProps) {
        super(props);

        this.listService = new ListService();
    }

    initMenu(moduleId: string) {
        this.listService.getLists(moduleId).then(data => {

            this.setState ({listModuleId: moduleId, navItems: data});
        });
    }

    componentDidUpdate(prevProps: Readonly<NavProps>,
                       prevState: Readonly<NavState>,
                       snapshot?: any): void {

        if (prevProps.module !== this.props.module) {
            if (this.props.module) {
                this.initMenu(this.props.module.id);
            } else {
                this.props.onSelect('');
                this.setState({listModuleId: '', navItems: []})
            }
        }

    }


    renderMenu(list: ListMetadata[]) {
        return list.map((item: ListMetadata) => {
            if (item.children && item.children.length > 0) {
                return <SubMenu title={item.title}>{this.renderMenu(item.children)}</SubMenu>
            } else {
                return <Menu.Item key={item.id} title={item.title}>{item.title}</Menu.Item>
            }

        })
    }

    render() {
        return (

            <Card style={{height:'100%', margin:0}} title={<div style={{textAlign:'center', fontWeight:'bold'}}>{this.props.module?.title}</div>} >
            <Menu
                mode="inline"
                style={{height: '100%', borderRight: 0}}
                selectedKeys={[this.props.selectedKey]}
                onClick={(e) =>
                         this.props.onSelect(e.key)}

            >
                {this.renderMenu(this.state.navItems)}

            </Menu>
            </Card>

        );
    }

}
import React from "react";
import {Menu} from "antd";
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
    defaultSelection: string;
}

export  default class Nav extends React.Component<NavProps, NavState> {
    state = { navItems: [], listModuleId: '', defaultSelection:''};

    listService : ListService;

    constructor(props: NavProps) {
        super(props);

        this.listService = new ListService();
    }

    initMenu(moduleId: string) {
        this.listService.getLists(moduleId).then(data => {
            let defaultSelection = '';
            data.forEach((item:ListMetadata) => {
                if (item.isDefault) {
                    defaultSelection = item.id;
                }
            });

            this.setState ({listModuleId: moduleId, navItems: data, defaultSelection: defaultSelection});
            if(defaultSelection !== '') {
                this.props.onSelect(defaultSelection)
            }
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


            <Menu
                mode="horizontal"

                // theme={'dark'}
                // style={{ background:'#2d2c2c'}}
                defaultSelectedKeys={[this.state.defaultSelection]}
                selectedKeys={[this.props.selectedKey]}
                onClick={(e) =>
                         this.props.onSelect(e.key)}

            >
                {this.renderMenu(this.state.navItems)}

            </Menu>
            // </Card>


        );
    }

}
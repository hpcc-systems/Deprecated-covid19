import React, {Component} from 'react';
import {Layout,  Menu} from 'antd';
import './App.css';
import Nav from "./components/Nav";
import ModuleService, {Module} from "./services/ModuleService"
import ListBase from "./components/ListBase";
import {ListMetadata} from "./services/ListService";

const {SubMenu} = Menu;
const {Header,Sider} = Layout;

interface AppState {
    selectedListId: string;
    menuKey: string;
    menus: Module[];
    selectedModule: Module | null;
    defaultSelection: Module | null;
}

interface AppProps {


}
export class App extends Component<AppProps, AppState> {

    moduleService : ModuleService;

    constructor(props: AppProps) {
        super(props);

        this.state ={selectedListId: '', menus: [], selectedModule: null, defaultSelection:null, menuKey:''};

        this.moduleService = new ModuleService();
    }

    componentDidMount(): void {
        this.initMenu();
    }

    initMenu() {
        this.moduleService.getModules().then(data => {

            let defaultSelection: Module|null = null ;
            let defaultSelectionId = '';

            data.forEach((item:Module) => {
                if (item.isDefault) {
                    defaultSelection = item;
                    defaultSelectionId = item.id;
                }
            });

            console.log('default selection id ' + defaultSelectionId);

            this.setState ({menus: data, selectedModule:defaultSelection, menuKey: defaultSelectionId});
        });
    }

    initModule(moduleId: string) {

        this.moduleService.getModule(moduleId).then(data => {

            console.log('module id - ' + moduleId);
            this.setState ({selectedModule: data, selectedListId:'', menuKey: moduleId});
        });


    }

    renderMenu(menus: Module[]) {
        return menus.map((item: Module) => {
                if (item.children && item.children.length > 0) {
                    return <SubMenu key={item.id} title={item.title}>{this.renderMenu(item.children)}</SubMenu>
                } else {
                    return <Menu.Item key={item.id} title={item.title}>{item.title}</Menu.Item>
                }
        })
    }

    render() {

        return (
            <Layout style={{height: "100vh"}}>
                <Header>
                    <div className="logo"/>
                    <Menu
                        theme={'dark'}
                        mode="horizontal"
                        style={{ lineHeight: '64px' }}
                        selectedKeys={[this.state.menuKey]}
                        onClick={(e) =>
                            this.initModule(e.key)}
                    >
                        {
                            this.renderMenu(this.state.menus)
                        }

                    </Menu>
                </Header>

                <Layout >
                    <Sider width={300} >
                        <Nav onSelect={(key: string) => this.setState({selectedListId: key})}
                             selectedKey={this.state.selectedListId} module={this.state.selectedModule} />
                    </Sider>

                    <ListBase listId={this.state.selectedListId} />
                </Layout>
            </Layout>
        );
    }
}

export default App;
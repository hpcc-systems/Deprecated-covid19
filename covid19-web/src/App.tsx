import React, {Component} from 'react';
import {Layout,  Menu} from 'antd';
import './App.css';
import Nav from "./components/Nav";
import ModuleService, {Module} from "./services/ModuleService"
import ListBase from "./components/ListBase";

const {SubMenu} = Menu;
const {Header,Sider} = Layout;

interface AppState {
    menuKey: string;
    menus: Module[];
    selectedModule: Module | null
}

interface AppProps {


}
export class App extends Component<AppProps, AppState> {

    moduleService : ModuleService;

    constructor(props: AppProps) {
        super(props);

        this.state ={menuKey: '', menus: [], selectedModule: null};

        this.moduleService = new ModuleService();
    }

    componentDidMount(): void {
        this.initMenu();
    }

    initMenu() {
        this.moduleService.getModules().then(data => {
            this.setState ({menus: data});
        });
    }

    initModule(moduleId: string) {

        this.moduleService.getModule(moduleId).then(data => {

            console.log('module id - ' + moduleId);
            this.setState ({selectedModule: data, menuKey:''});
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
                        <Nav onSelect={(key: string) => this.setState({menuKey: key})}
                             selectedKey={this.state.menuKey} module={this.state.selectedModule} />
                    </Sider>

                    <ListBase listId={this.state.menuKey}/>
                </Layout>
            </Layout>
        );
    }
}

export default App;
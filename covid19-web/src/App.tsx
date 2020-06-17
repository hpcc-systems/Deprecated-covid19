import React, {Component} from 'react';
import {Button, Layout, Menu} from 'antd';
import './App.css';
import Nav from "./components/Nav";
import ModuleService, {Module} from "./services/ModuleService"
import ListBase from "./components/ListBase";
import {AuthForm} from "./components/AuthForm";
import AuthService from "./services/AuthService";

const {SubMenu} = Menu;
const {Header, Sider} = Layout;

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

    moduleService: ModuleService;
    authService: AuthService;

    constructor(props: AppProps) {
        super(props);

        this.state = {selectedListId: '', menus: [], selectedModule: null, defaultSelection: null, menuKey: ''};

        this.moduleService = new ModuleService();
        this.authService = new AuthService();
    }

    componentDidMount(): void {
        this.initMenu();
    }

    processAuthentication(values: any) {
        this.authService.authenticate(values.username, values.password);
        this.initMenu();
    }

    initMenu() {
        if(this.authService.isAuthenticated()) {
            this.moduleService.getModules().then(data => {

                let defaultSelection: Module | null = null;
                let defaultSelectionId = '';

                data.forEach((item: Module) => {
                    if (item.isDefault) {
                        defaultSelection = item;
                        defaultSelectionId = item.id;
                    }
                });

                console.log('default selection id ' + defaultSelectionId);

                this.setState({menus: data, selectedModule: defaultSelection, menuKey: defaultSelectionId});
            });
        }
    }

    initModule(moduleId: string) {

        this.moduleService.getModule(moduleId).then(data => {

            console.log('module id - ' + moduleId);
            this.setState({selectedModule: data, selectedListId: '', menuKey: moduleId});
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

    logout() {
        this.authService.logout();
        this.setState({menus: [], selectedModule: null, menuKey: ''});
    }

    renderAuthForm() {
        if (!this.authService.isAuthenticated()) {
            return <AuthForm onAuthenticate={(values: any) => this.processAuthentication(values)}/>
        } else {
            return '';
        }
    }

    renderMenuButtons() {//TODO: Placeholder for the logout button
        // if (this.authService.isAuthenticated()) {
        //     return <Button style={{float: "right", marginTop: 20}} type="link" onClick={() => this.logout()}>Logout</Button>
        // } else {
            //return '';
        // }
        return <Button style={{float: "right", marginTop: 20}} type="link" target={"_blank"} href={"open_database_license.pdf"} >Open Database License</Button>
    }


    render() {
        return (
            <Layout style={{height: "100vh"}}>
                <Header style={{background: '#3a3939'}}>
                    <div className="logo"/>
                    <Menu
                        theme={"dark"}
                        mode="horizontal"
                        style={{lineHeight: '64px', background: '#3a3939'}}
                        selectedKeys={[this.state.menuKey]}
                        onClick={(e) =>
                            this.initModule(e.key)}
                    >
                        {
                            this.renderMenu(this.state.menus)
                        }
                        {
                            this.renderMenuButtons()//logout, disclaimers
                        }
                    </Menu>

                </Header>

                <Layout>
                    <Sider width={240}>
                        <Nav onSelect={(key: string) => this.setState({selectedListId: key})}
                             selectedKey={this.state.selectedListId} module={this.state.selectedModule}/>
                    </Sider>

                    {this.renderAuthForm()}

                    <ListBase listId={this.state.selectedListId}/>


                </Layout>

            </Layout>
        );
    }
}

export default App;
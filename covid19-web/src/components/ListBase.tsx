import React from "react";
import ListService, {ListMetadata} from "../services/ListService";
import {Layout} from "antd";
import AllMetrics from "../lists/AllMetrics";
import LocationTrends from "../lists/LocationTrends";
import AuthService from "../services/AuthService";
import {AuthForm} from "./AuthForm";
import StateMetrics from "../lists/StateMetrics";
import StateMap from "../lists/StateMap";


const {Content} = Layout;

interface ListProps {
    listId: string
}



interface ListState {
    listMetadata: ListMetadata | null;

}


export  default class ListBase extends React.Component <ListProps, ListState> {


    listService: ListService;

    

    constructor(props: ListProps) {
        super(props);

        this.listService = new ListService();

    }

    componentDidUpdate(prevProps: Readonly<ListProps>,
                       prevState: Readonly<ListState>,
                       snapshot?: any): void {

        if (prevProps.listId !== this.props.listId) {
            this.initMetadata(this.props.listId);
        }

    }

    private initMetadata(listId: string) {
        this.listService.getList(listId).then(
            data => {
                this.setState({listMetadata: data});
            }
        );
    }

    private renderContent() {

            if (this.state && this.state.listMetadata) {

                switch (this.state.listMetadata.id) {
                    // case 'us_states/trends': return <SummaryStates title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                    case 'us_states/trends':
                        return <LocationTrends key={'states-trends'} title={this.state.listMetadata.title}
                                               description={this.state.listMetadata.description} locationAlias={'State'}
                                               typeFilter={'states'}/>;
                    case 'us_states/states_metrics':
                        return <AllMetrics key={'states-metrics'} locationAlias={'State'} typeFilter={'states'}
                                           title={this.state.listMetadata.title}
                                           description={this.state.listMetadata.description}/>;
                    case 'us_counties/counties_metrics':
                        return <AllMetrics key={'counties'} locationAlias={'County'} typeFilter={'counties'}
                                           title={this.state.listMetadata.title}
                                           description={this.state.listMetadata.description}/>;
                    case 'us_states/map':
                        // return <StateMetrics title={this.state.listMetadata.title} description={this.state.listMetadata.description}/>
                        return <StateMap key={'states-map'} title={this.state.listMetadata.title}
                                         description={this.state.listMetadata.description}/>
                    case 'world_countries/trends':
                        return <LocationTrends key={'countries-trends'} title={this.state.listMetadata.title}
                                               description={this.state.listMetadata.description}
                                               locationAlias={'Country'} typeFilter={'countries'}/>;
                    case 'world_countries/countries_metrics':
                        return <AllMetrics key={'countries-metrics'} locationAlias={'Country'} typeFilter={'countries'}
                                           title={this.state.listMetadata.title}
                                           description={this.state.listMetadata.description}/>
                    default:
                        return '';
                }
            } else {
                return '';
            }

    }



    render() {

        return (
           <Content>
               {this.renderContent()}
           </Content>
        )

    }


}
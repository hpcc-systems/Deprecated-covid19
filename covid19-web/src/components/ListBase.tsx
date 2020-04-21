import React from "react";
import ListService, {ListMetadata} from "../services/ListService";
import {Layout} from "antd";
import SummaryStates from "../lists/us-states/Trends";
import SummaryCountries from "../lists/world/Trends";
import AllMetrics from "../lists/AllMetrics";
import StatesProgress from "../lists/us-states/StatesProgress";
import {Home} from "../lists/Home";
import LocationTrends from "../lists/LocationTrends";




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
                case 'us_states/trends': return <LocationTrends title={this.state.listMetadata.title} description = {this.state.listMetadata.description} locationAlias={'State'} typeFilter={'states'}/>;
                case 'us_states/states_metrics': return <AllMetrics key={'states'} locationAlias={'State'} typeFilter={'states'} title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                case 'us_states/counties_metrics': return <AllMetrics key={'counties'} locationAlias={'County'} typeFilter={'counties'} title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                case 'us_states/states_progress': return <StatesProgress/>;
                case 'world_countries/trends': return <LocationTrends title={this.state.listMetadata.title} description = {this.state.listMetadata.description} locationAlias={'Country'} typeFilter={'countries'}/>;
                case 'world_countries/countries_metrics': return <AllMetrics locationAlias={'Country'} typeFilter={'countries'} title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                case 'home/summary': return <Home title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                default: return '';
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
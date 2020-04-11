import React from "react";
import ListService, {ListMetadata} from "../services/ListService";
import {Layout} from "antd";
import SummaryStates from "../lists/us-states/Summary";
import SummaryCountries from "../lists/world/Summary";
import AllMetrics from "../lists/AllMetrics";
import StatesProgress from "../lists/us-states/StatesProgress";
import {Home} from "../lists/Home";




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
                case 'us_states/summary': return <SummaryStates title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                case 'us_states/states_metrics': return <AllMetrics locationAlias={'State'} typeFilter={'states'} title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                case 'us_counties/counties_metrics': return <AllMetrics locationAlias={'County'} typeFilter={'counties'} title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
                case 'us_states/states_progress': return <StatesProgress/>;
                case 'world_countries/summary': return <SummaryCountries title={this.state.listMetadata.title} description = {this.state.listMetadata.description}/>;
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
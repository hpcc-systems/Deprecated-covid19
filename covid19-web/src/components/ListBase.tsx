import React from "react";
import ListService, {ListMetadata} from "../services/ListService";
import {Layout} from "antd";
import SummaryStates from "../lists/us-states/Summary";
import SummaryCountries from "../lists/world/Summary";
import StatesStats from "../lists/us-states/StatesStats";
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
                case 'us_states/summary': return <SummaryStates/>;
                case 'us_states/states_stats': return <StatesStats/>;
                case 'us_states/states_progress': return <StatesProgress/>;
                case 'world_countries/summary': return <SummaryCountries/>;
                case 'home/summary': return <Home/>;
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
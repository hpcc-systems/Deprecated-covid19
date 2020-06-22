import React from "react";
import ListService, {ListMetadata} from "../services/ListService";
import {Layout} from "antd";
import Hotspots from "../lists/Hotspots";
import LocationTrends from "../lists/LocationTrends";
import LocationMap from "../lists/LocationMap";


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
                        return <Hotspots key={'states-metrics'} locationAlias={'State'} typeFilter={'states'}
                                         title={this.state.listMetadata.title}
                                         description={this.state.listMetadata.description}/>;
                    case 'us_states/map':
                        return <LocationMap key={'states-map'} title={this.state.listMetadata.title}
                                            description={this.state.listMetadata.description}
                                            type={'states'} zoom={4.5} geoLat={38.2}
                                            geoLong={-98.6} geoFile={'us-states.geojson'} geoKeyField={'name'}/>
                    case 'us_counties/counties_metrics':
                        return <Hotspots key={'counties-metrics'} locationAlias={'County'} typeFilter={'counties'}
                                         title={this.state.listMetadata.title}
                                         description={this.state.listMetadata.description}/>;
                    case 'us_counties/trends':
                        return <LocationTrends key={'counties-trends'} title={this.state.listMetadata.title}
                                               description={this.state.listMetadata.description} locationAlias={'County'}
                                               typeFilter={'counties'}/>;
                    case 'us_counties/map':
                        return <LocationMap key={'counties-map'} title={this.state.listMetadata.title}
                                            description={this.state.listMetadata.description}
                                            type={'counties'} zoom={5} geoLat={38.2}
                                            geoLong={-98.6} geoFile={'us-counties.geojson'}
                                            secondaryGeoFile={'us-states.geojson'}
                                            geoKeyField={'GEOID'}/>

                    case 'world_countries/trends':
                        return <LocationTrends key={'countries-trends'} title={this.state.listMetadata.title}
                                               description={this.state.listMetadata.description}
                                               locationAlias={'Country'} typeFilter={'countries'}/>;
                    case 'world_countries/countries_metrics':
                        return <Hotspots key={'countries-metrics'} locationAlias={'Country'} typeFilter={'countries'}
                                         title={this.state.listMetadata.title}
                                         description={this.state.listMetadata.description}/>
                    case 'world_countries/countries_map':
                        return <LocationMap key={'countries-map'} title={this.state.listMetadata.title}
                                            description={this.state.listMetadata.description}
                                            type={'countries'} zoom={2} geoLat={0}
                                            geoLong={0} geoFile={'countries.geojson'} geoKeyField={'name'}/>
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
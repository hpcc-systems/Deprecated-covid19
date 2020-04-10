

export interface ListMetadata {
    moduleId: string;
    id: string;
    title: string;
    description: string;
    isDefault: boolean;
    children?: ListMetadata[];
}

export default class ListService {

    private lists = [{moduleId:'us_states', id:'us_states/summary', title: 'Summary', description: 'Daily snapshot of cases and deaths for US states. Please use the filter button to select the states.',  isDefault:true},
                     {moduleId:'us_states', id:'us_states/states_metrics', title: 'Metrics', description: 'Daily snapshot of metrics for US states. Please use the filter button to select the states and period.',isDefault: false},
                     {moduleId: 'world_countries', id: 'world_countries/summary', title: 'Summary', description: 'Daily snapshot of cases and deaths by countries. Please use the filter button to select the countries.', isDefault: true},
                     {moduleId:'world_countries', id:'world_countries/countries_metrics', title: 'Metrics', description: 'Daily snapshot of metrics for US states. Please use the filter button to select the states and period.',isDefault: false},
                     {moduleId: 'home', id: 'home/summary', title: 'Summary', description: `Summary of cases, deaths, cases increases, deaths increase as of ${new Date()}`, isDefault: true}
                     ];//Inline Data

    getLists(moduleId: string): Promise<ListMetadata[]> {
        return new Promise<ListMetadata[]>(resolve => {
            let moduleList: ListMetadata[] = [];
            this.lists.forEach((item:ListMetadata) => {

                if (item.moduleId === moduleId) {
                    moduleList.push(item);
                }

            });
            resolve(moduleList);
        })
    }

    getList(listId: string): Promise<ListMetadata> {
        return new Promise<ListMetadata>(resolve => {
            this.lists.forEach((item:ListMetadata) => {

                if (item.id === listId) {
                    resolve(item);
                    return;
                }
            });
            resolve(undefined);
        })
    }


}
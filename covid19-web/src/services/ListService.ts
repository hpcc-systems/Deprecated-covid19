

export interface ListMetadata {
    moduleId: string;
    id: string;
    title: string;
    isDefault: boolean;
    children?: ListMetadata[];
}

export default class ListService {

    private lists = [{moduleId:'us_states', id:'us_states/summary', title: 'Summary', isDefault:true},
                     {moduleId:'us_states', id:'us_states/states_stats', title: 'States Statistics', isDefault: false},
                     {moduleId: 'world_countries', id: 'world_countries/summary', title: 'Summary', isDefault: true},
                     {moduleId: 'home', id: 'home/summary', title: 'Summary', isDefault: true}
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

export interface Module {
  id: string,
  title: string,
  isDefault: boolean,
  children?: Module[]
}


export default class ModuleService {

    private modules = [{id:'home', title: 'Home', defaultListId: '', isDefault: true},
                       {id:'world_countries', title: 'World Countries', isDefault: false},
                       {id:'us_states', title: 'US States', isDefault: false},
                       {id:'us_counties', title: 'US Counties', isDefault: false},];//Inline Data

    getModules () : Promise <Module[]> {
        return new Promise<Module[]>(resolve => {
            resolve(this.modules);
        })
    }

    getModule(id: string): Promise <Module> {
        return new Promise<Module>(resolve => {
            this.modules.forEach((item:Module) => {

                if (item.id === id) {
                    resolve(item);
                    return;
                }
            })
        })
    }


}
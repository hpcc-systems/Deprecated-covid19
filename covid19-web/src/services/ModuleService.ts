
export interface Module {
  id: string,
  title: string,
  isDefault: boolean,
  children?: Module[]
}


export default class ModuleService {
//{id:'home', title: 'Home', defaultListId: '', isDefault: true},
    private modules = [
                       {id:'world_countries', title: 'World', isDefault: true},
                       {id:'us_states', title: 'US', isDefault: false},
                       {id:'us_counties', title: 'US Counties', isDefault: false}];//Inline Data

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
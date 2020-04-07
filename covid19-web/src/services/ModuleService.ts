
export interface Module {
  id: string,
  title: string,
  children?: Module[]
}


export default class ModuleService {

    private modules = [{id:'world_countries', title: 'World Countries'},
                       {id:'us_states', title: 'US States'},];//Inline Data

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
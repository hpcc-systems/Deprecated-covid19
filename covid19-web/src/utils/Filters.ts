export class Filters {
    private static instance: Filters;
    private readonly filtersMap: Map<string, string>;

    /**
     * The Singleton's constructor should always be private to prevent direct
     * construction calls with the `new` operator.
     */
    private constructor() {
        this.filtersMap = new Map<string, string>();
     }

    /**
     * The static method that controls the access to the singleton instance.
     *
     * This implementation let you subclass the Singleton class while keeping
     * just one instance of each subclass around.
     */
    public static getInstance(): Filters {
        if (!Filters.instance) {
            Filters.instance = new Filters();
        }

        return Filters.instance;
    }

    /**
     * Finally, any singleton should define some business logic, which can be
     * executed on its instance.
     */
    public set(key: string, value: string) {
        this.filtersMap.set(key, value);
        localStorage.setItem(key, value);
    }

    public get(key: string): string|undefined {
        return this.filtersMap.get(key);
    }

    public getMap(): Map<string, string> {
        return this.filtersMap;
    }
}
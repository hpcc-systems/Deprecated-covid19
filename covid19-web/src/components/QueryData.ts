
export  class QueryData {

    private queryName: string;
    private data: any;

    constructor(queryName: string) {
        this.queryName = queryName;
        this.data = {};
    }

    async initData(filters: Map<string, string>) {

        let filterStr = '';
        filters.forEach((value,key) => {
            let prefix = '&';
            if (filterStr.length > 0) {prefix = '&'}
            filterStr += prefix + key + '=' + value;
        });

        this.data = await this.getAPIData(filterStr);

    }

    getAPIData(filterStr: string): Promise<any> {
        return fetch(`http://play.hpccsystems.com:8002/WsEcl/submit/query/roxie/`+ this.queryName +`/json?`+ filterStr +`&submit_type=json`)
            .then(res => res.json())
    }


    getData(resultName: string): any {
        console.log(this.data);
        let stack: any[] = [];

        this.traverse(this.data, resultName, stack);
        console.log('stack ' + stack.length);

        if (stack.length > 0) {
            let resultData = stack.pop();
            console.log('result data: ' + resultData);
            return resultData;
        } else return [];
    }

    traverse(jsonObj:object, resultName:string, stack:any[]) {
        if( jsonObj !== null && typeof jsonObj == "object" ) {
            Object.entries(jsonObj).forEach(([key, value]) => {

                if (key===resultName) {
                    console.log('stack push ' + key);
                    console.log('stack push data' + value.Row);
                    stack.push(value.Row);
                } else {
                    this.traverse(value, resultName, stack);
                }
            });
        }
        else {
            // jsonObj is a number or string
        }
    }


}
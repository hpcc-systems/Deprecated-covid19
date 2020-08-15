export type StatesType = {
    readonly name: string;
    readonly code: string;
}

export type CountriesType = {
    readonly name: string;
}

export default class Catalog {

    static initMaps() {
        let maps: Map<string, any> = new Map<string, any>();
        maps.set('THE WORLD', {file:'countries.geojson', secondaryFile: '', colorKeyField: 'name' , selectKeyField: 'name' ,lat:0,long:0,zoom:0});
        maps.set('THE WORLD-US', {file:'us-states.geojson', secondaryFile: '', colorKeyField: 'name', selectKeyField: 'name' ,lat:37.2,long:-98.6,zoom:5});
        maps.set('THE WORLD-CANADA', {file:'canada-states.geojson', secondaryFile: '', colorKeyField: 'PRENAME', selectKeyField: 'PRENAME' ,lat:56.2,long:-106.6,zoom:4});
        maps.set('THE WORLD-SPAIN', {file:'spain-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1' ,lat:39.4,long:-3.7,zoom:6.5});
        maps.set('THE WORLD-ITALY', {file:'italy-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1' ,lat:41.8,long:12.57,zoom:6.5});
        maps.set('THE WORLD-GERMANY', {file:'germany-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1' ,lat:51.2,long:10.45,zoom:6.5});
        maps.set('THE WORLD-US-GEORGIA', {file:'us-counties-georgia.geojson', secondaryFile: '', colorKeyField: 'GEOID10', selectKeyField: 'NAME10' ,lat:33,long:-83.3,zoom:8.0});
        maps.set('THE WORLD-US-FLORIDA', {file:'us-counties-florida.geojson', secondaryFile: '', colorKeyField: 'COUNTY', selectKeyField: 'COUNTYNAME' ,lat:28,long:-83.5,zoom:8.0});
        maps.set('THE WORLD-US-TEXAS', {file:'us-counties.geojson', secondaryFile: 'us-states.geojson', colorKeyField: 'GEOID', selectKeyField: 'name' ,lat:31.9,long:-97,zoom:7});
        maps.set('THE WORLD-AUSTRALIA', {file:'australia-states.geojson', secondaryFile: '', colorKeyField: 'STATE_NAME', selectKeyField: 'STATE_NAME' ,lat:-25.27,long:133.77,zoom:5.0});
        maps.set('THE WORLD-INDIA', {file:'india-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1' ,lat:20.5,long:79,zoom:5.0});
        maps.set('THE WORLD-BRAZIL', {file:'brazil-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1' ,lat:-14.2,long:-51.9,zoom:4.5});
        maps.set('THE WORLD-UNITED KINGDOM', {file:'uk-countries.geojson', secondaryFile: '', colorKeyField: 'ctry19nm', selectKeyField: 'ctry19nm' ,lat:55.37,long:-2.07,zoom:6.0});
        maps.set('THE WORLD-US-WASHINGTON', {file:'us-counties-washington.geojson', secondaryFile: '', colorKeyField: 'JURISDIC_5', selectKeyField: 'JURISDIC_2', lat: 47.0, long: -120.0, zoom: 7.5,});
        return maps;
    }

    static maps: Map<string, any> = Catalog.initMaps();


    static us_states: StatesType[] = [{name: 'ALABAMA', code: 'AL'},
        {name: 'ALASKA', code: 'AK'},
        {name: 'ARIZONA', code: 'AZ'},
        {name: 'ARKANSAS', code: 'AR'},
        {name: 'CALIFORNIA', code: 'CA'},
        {name: 'COLORADO', code: 'CO'},
        {name: 'CONNECTICUT', code: 'CT'},
        {name: 'DELAWARE', code: 'DE'},
        {name: 'FLORIDA', code: 'FL'},
        {name: 'GEORGIA', code: 'GA'},
        {name: 'HAWAII', code: 'HI'},
        {name: 'IDAHO', code: 'ID'},
        {name: 'ILLINOIS', code: 'IL'},
        {name: 'INDIANA', code: 'IN'},
        {name: 'IOWA', code: 'IA'},
        {name: 'KANSAS', code: 'KS'},
        {name: 'KENTUCKY', code: 'KY'},
        {name: 'LOUISIANA', code: 'LA'},
        {name: 'MAINE', code: 'ME'},
        {name: 'MARYLAND', code: 'MD'},
        {name: 'MASSACHUSETTS', code: 'MA'},
        {name: 'MICHIGAN', code: 'MI'},
        {name: 'MINNESOTA', code: 'MN'},
        {name: 'MISSISSIPPI', code: 'MS'},
        {name: 'MISSOURI', code: 'MO'},
        {name: 'MONTANA', code: 'MT'},
        {name: 'NEBRASKA', code: 'NE'},
        {name: 'NEVADA', code: 'NV'},
        {name: 'NEW HAMPSHIRE', code: 'NH'},
        {name: 'NEW JERSEY', code: 'NJ'},
        {name: 'NEW MEXICO', code: 'NM'},
        {name: 'NEW YORK', code: 'NY'},
        {name: 'NORTH CAROLINA', code: 'NC'},
        {name: 'NORTH DAKOTA', code: 'ND'},
        {name: 'OHIO', code: 'OH'},
        {name: 'OKLAHOMA', code: 'OK'},
        {name: 'OREGON', code: 'OR'},
        {name: 'PENNSYLVANIA', code: 'PA'},
        {name: 'RHODE ISLAND', code: 'RI'},
        {name: 'SOUTH CAROLINA', code: 'SC'},
        {name: 'SOUTH DAKOTA', code: 'SD'},
        {name: 'TENNESSEE', code: 'TN'},
        {name: 'TEXAS', code: 'TX'},
        {name: 'UTAH', code: 'UT'},
        {name: 'VERMONT', code: 'VT'},
        {name: 'VIRGINIA', code: 'VA'},
        {name: 'WASHINGTON', code: 'WA'},
        {name: 'WEST VIRGINIA', code: 'WV'},
        {name: 'WISCONSIN', code: 'WI'},
        {name: 'WYOMING', code: 'WY'}];

    static countries: CountriesType[] = [
        {
            "name":"AFGHANISTAN"
        },
        {
            "name":"ALBANIA"
        },
        {
            "name":"ALGERIA"
        },
        {
            "name":"ANDORRA"
        },
        {
            "name":"ANGOLA"
        },
        {
            "name":"ANTIGUA AND BARBUDA"
        },
        {
            "name":"ARGENTINA"
        },
        {
            "name":"ARMENIA"
        },
        {
            "name":"ARUBA"
        },
        {
            "name":"AUSTRALIA"
        },
        {
            "name":"AUSTRIA"
        },
        {
            "name":"AZERBAIJAN"
        },
        {
            "name":"BAHAMAS"
        },
        {
            "name":"BAHAMAS, THE"
        },
        {
            "name":"BAHRAIN"
        },
        {
            "name":"BANGLADESH"
        },
        {
            "name":"BARBADOS"
        },
        {
            "name":"BELARUS"
        },
        {
            "name":"BELGIUM"
        },
        {
            "name":"BELIZE"
        },
        {
            "name":"BENIN"
        },
        {
            "name":"BHUTAN"
        },
        {
            "name":"BOLIVIA"
        },
        {
            "name":"BOSNIA AND HERZEGOVINA"
        },
        {
            "name":"BOTSWANA"
        },
        {
            "name":"BRAZIL"
        },
        {
            "name":"BRUNEI"
        },
        {
            "name":"BULGARIA"
        },
        {
            "name":"BURKINA FASO"
        },
        {
            "name":"BURMA"
        },
        {
            "name":"BURUNDI"
        },
        {
            "name":"CABO VERDE"
        },
        {
            "name":"CAMBODIA"
        },
        {
            "name":"CAMEROON"
        },
        {
            "name":"CANADA"
        },
        {
            "name":"CAPE VERDE"
        },
        {
            "name":"CENTRAL AFRICAN REPUBLIC"
        },
        {
            "name":"CHAD"
        },
        {
            "name":"CHILE"
        },
        {
            "name":"CHINA"
        },
        {
            "name":"COLOMBIA"
        },
        {
            "name":"CONGO (BRAZZAVILLE)"
        },
        {
            "name":"CONGO (KINSHASA)"
        },
        {
            "name":"COSTA RICA"
        },
        {
            "name":"COTE D'IVOIRE"
        },
        {
            "name":"CROATIA"
        },
        {
            "name":"CRUISE SHIP"
        },
        {
            "name":"CUBA"
        },
        {
            "name":"CYPRUS"
        },
        {
            "name":"CZECHIA"
        },
        {
            "name":"DENMARK"
        },
        {
            "name":"DIAMOND PRINCESS"
        },
        {
            "name":"DJIBOUTI"
        },
        {
            "name":"DOMINICA"
        },
        {
            "name":"DOMINICAN REPUBLIC"
        },
        {
            "name":"EAST TIMOR"
        },
        {
            "name":"ECUADOR"
        },
        {
            "name":"EGYPT"
        },
        {
            "name":"EL SALVADOR"
        },
        {
            "name":"EQUATORIAL GUINEA"
        },
        {
            "name":"ERITREA"
        },
        {
            "name":"ESTONIA"
        },
        {
            "name":"ESWATINI"
        },
        {
            "name":"ETHIOPIA"
        },
        {
            "name":"FIJI"
        },
        {
            "name":"FINLAND"
        },
        {
            "name":"FRANCE"
        },
        {
            "name":"FRENCH GUIANA"
        },
        {
            "name":"GABON"
        },
        {
            "name":"GAMBIA"
        },
        {
            "name":"GAMBIA, THE"
        },
        {
            "name":"GEORGIA"
        },
        {
            "name":"GERMANY"
        },
        {
            "name":"GHANA"
        },
        {
            "name":"GREECE"
        },
        {
            "name":"GREENLAND"
        },
        {
            "name":"GRENADA"
        },
        {
            "name":"GUADELOUPE"
        },
        {
            "name":"GUAM"
        },
        {
            "name":"GUATEMALA"
        },
        {
            "name":"GUERNSEY"
        },
        {
            "name":"GUINEA"
        },
        {
            "name":"GUINEA-BISSAU"
        },
        {
            "name":"GUYANA"
        },
        {
            "name":"HAITI"
        },
        {
            "name":"HOLY SEE"
        },
        {
            "name":"HONDURAS"
        },
        {
            "name":"HUNGARY"
        },
        {
            "name":"ICELAND"
        },
        {
            "name":"INDIA"
        },
        {
            "name":"INDONESIA"
        },
        {
            "name":"IRAN"
        },
        {
            "name":"IRAQ"
        },
        {
            "name":"IRELAND"
        },
        {
            "name":"ISRAEL"
        },
        {
            "name":"ITALY"
        },
        {
            "name":"JAMAICA"
        },
        {
            "name":"JAPAN"
        },
        {
            "name":"JERSEY"
        },
        {
            "name":"JORDAN"
        },
        {
            "name":"KAZAKHSTAN"
        },
        {
            "name":"KENYA"
        },
        {
            "name":"KOREA, SOUTH"
        },
        {
            "name":"KOSOVO"
        },
        {
            "name":"KUWAIT"
        },
        {
            "name":"KYRGYZSTAN"
        },
        {
            "name":"LAOS"
        },
        {
            "name":"LATVIA"
        },
        {
            "name":"LEBANON"
        },
        {
            "name":"LIBERIA"
        },
        {
            "name":"LIBYA"
        },
        {
            "name":"LIECHTENSTEIN"
        },
        {
            "name":"LITHUANIA"
        },
        {
            "name":"LUXEMBOURG"
        },
        {
            "name":"MADAGASCAR"
        },
        {
            "name":"MALAWI"
        },
        {
            "name":"MALAYSIA"
        },
        {
            "name":"MALDIVES"
        },
        {
            "name":"MALI"
        },
        {
            "name":"MALTA"
        },
        {
            "name":"MARTINIQUE"
        },
        {
            "name":"MAURITANIA"
        },
        {
            "name":"MAURITIUS"
        },
        {
            "name":"MAYOTTE"
        },
        {
            "name":"MEXICO"
        },
        {
            "name":"MOLDOVA"
        },
        {
            "name":"MONACO"
        },
        {
            "name":"MONGOLIA"
        },
        {
            "name":"MONTENEGRO"
        },
        {
            "name":"MOROCCO"
        },
        {
            "name":"MOZAMBIQUE"
        },
        {
            "name":"MS ZAANDAM"
        },
        {
            "name":"NAMIBIA"
        },
        {
            "name":"NEPAL"
        },
        {
            "name":"NETHERLANDS"
        },
        {
            "name":"NEW ZEALAND"
        },
        {
            "name":"NICARAGUA"
        },
        {
            "name":"NIGER"
        },
        {
            "name":"NIGERIA"
        },
        {
            "name":"NORTH MACEDONIA"
        },
        {
            "name":"NORWAY"
        },
        {
            "name":"OCCUPIED PALESTINIAN TERRITORY"
        },
        {
            "name":"OMAN"
        },
        {
            "name":"PAKISTAN"
        },
        {
            "name":"PANAMA"
        },
        {
            "name":"PAPUA NEW GUINEA"
        },
        {
            "name":"PARAGUAY"
        },
        {
            "name":"PERU"
        },
        {
            "name":"PHILIPPINES"
        },
        {
            "name":"POLAND"
        },
        {
            "name":"PORTUGAL"
        },
        {
            "name":"PUERTO RICO"
        },
        {
            "name":"QATAR"
        },
        {
            "name":"REPUBLIC OF THE CONGO"
        },
        {
            "name":"REUNION"
        },
        {
            "name":"ROMANIA"
        },
        {
            "name":"RUSSIA"
        },
        {
            "name":"RWANDA"
        },
        {
            "name":"SAINT KITTS AND NEVIS"
        },
        {
            "name":"SAINT LUCIA"
        },
        {
            "name":"SAINT VINCENT AND THE GRENADINES"
        },
        {
            "name":"SAN MARINO"
        },
        {
            "name":"SAUDI ARABIA"
        },
        {
            "name":"SENEGAL"
        },
        {
            "name":"SERBIA"
        },
        {
            "name":"SEYCHELLES"
        },
        {
            "name":"SIERRA LEONE"
        },
        {
            "name":"SINGAPORE"
        },
        {
            "name":"SLOVAKIA"
        },
        {
            "name":"SLOVENIA"
        },
        {
            "name":"SOMALIA"
        },
        {
            "name":"SOUTH AFRICA"
        },
        {
            "name":"SOUTH KOREA"
        },
        {
            "name":"SOUTH SUDAN"
        },
        {
            "name":"SPAIN"
        },
        {
            "name":"SRI LANKA"
        },
        {
            "name":"SUDAN"
        },
        {
            "name":"SURINAME"
        },
        {
            "name":"SWEDEN"
        },
        {
            "name":"SWITZERLAND"
        },
        {
            "name":"SYRIA"
        },
        {
            "name":"TAIWAN*"
        },
        {
            "name":"TANZANIA"
        },
        {
            "name":"THAILAND"
        },
        {
            "name":"THE BAHAMAS"
        },
        {
            "name":"THE GAMBIA"
        },
        {
            "name":"TIMOR-LESTE"
        },
        {
            "name":"TOGO"
        },
        {
            "name":"TRINIDAD AND TOBAGO"
        },
        {
            "name":"TUNISIA"
        },
        {
            "name":"TURKEY"
        },
        {
            "name":"UGANDA"
        },
        {
            "name":"UKRAINE"
        },
        {
            "name":"UNITED ARAB EMIRATES"
        },
        {
            "name":"UNITED KINGDOM"
        },
        {
            "name":"URUGUAY"
        },
        {
            "name":"US"
        },
        {
            "name":"UZBEKISTAN"
        },
        {
            "name":"VENEZUELA"
        },
        {
            "name":"VIETNAM"
        },
        {
            "name":"WEST BANK AND GAZA"
        },
        {
            "name":"WESTERN SAHARA"
        },
        {
            "name":"ZAMBIA"
        },
        {
            "name":"ZIMBABWE"
        }
    ];
}

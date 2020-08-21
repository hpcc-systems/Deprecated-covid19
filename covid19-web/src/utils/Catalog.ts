export type StatesType = {
  readonly name: string;
  readonly code: string;
};

export type CountriesType = {
  readonly name: string;
};

export default class Catalog {
  static initMaps() {
    let maps: Map<string, any> = new Map<string, any>();
    maps.set('THE WORLD', { file: 'countries.geojson', secondaryFile: '', colorKeyField: 'name', selectKeyField: 'name', lat: 0, long: 0, zoom: 0, });
    maps.set('THE WORLD-US', { file: 'us-states.geojson', secondaryFile: '', colorKeyField: 'name', selectKeyField: 'name', lat: 37.2, long: -98.6, zoom: 5, });
    maps.set('THE WORLD-CANADA', { file: 'canada-states.geojson', secondaryFile: '', colorKeyField: 'PRENAME', selectKeyField: 'PRENAME', lat: 56.2, long: -106.6, zoom: 4, });
    maps.set('THE WORLD-SPAIN', { file: 'spain-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1', lat: 39.4, long: -3.7, zoom: 6.5, });
    maps.set('THE WORLD-ITALY', { file: 'italy-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1', lat: 41.8, long: 12.57, zoom: 6.5, });
    maps.set('THE WORLD-GERMANY', { file: 'germany-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1', lat: 51.2, long: 10.45, zoom: 6.5, });
    maps.set('THE WORLD-US-GEORGIA', { file: 'us-counties-georgia.geojson', secondaryFile: '', colorKeyField: 'GEOID10', selectKeyField: 'NAME10', lat: 33, long: -83.3, zoom: 8.0, });
    maps.set('THE WORLD-US-FLORIDA', { file: 'us-counties-florida.geojson', secondaryFile: '', colorKeyField: 'COUNTY', selectKeyField: 'COUNTYNAME', lat: 28, long: -83.5, zoom: 8.0, });
    maps.set('THE WORLD-AUSTRALIA', { file: 'australia-states.geojson', secondaryFile: '', colorKeyField: 'STATE_NAME', selectKeyField: 'STATE_NAME', lat: -25.27, long: 133.77, zoom: 5.0, });
    maps.set('THE WORLD-INDIA', { file: 'india-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1', lat: 20.5, long: 79, zoom: 5.0, });
    maps.set('THE WORLD-BRAZIL', { file: 'brazil-states.geojson', secondaryFile: '', colorKeyField: 'NAME_1', selectKeyField: 'NAME_1', lat: -14.2, long: -51.9, zoom: 4.5, });
    maps.set('THE WORLD-UNITED KINGDOM', { file: 'uk-countries.geojson', secondaryFile: '', colorKeyField: 'ctry19nm', selectKeyField: 'ctry19nm', lat: 55.37, long: -2.07, zoom: 6.0, });
    maps.set('THE WORLD-US-WASHINGTON', { file: 'us-counties-washington.geojson', secondaryFile: '', colorKeyField: 'JURISDIC_5', selectKeyField: 'JURISDIC_2', lat: 47.0, long: -120.0, zoom: 7.5, });
    maps.set('THE WORLD-US-OREGON', { file: 'us-counties-oregon.geojson', secondaryFile: '', colorKeyField: 'instcode', selectKeyField: 'altname', lat: 43.7, long: -120.0, zoom: 7.0, });
    maps.set('THE WORLD-US-ALABAMA', { file: 'us-counties-alabama.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: -87.8, long: 37.0, zoom: 6.5, });
    maps.set('THE WORLD-US-ALASKA', { file: 'us-counties-alaska.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 63, long: -150.0, zoom: 6.5, });
    maps.set('THE WORLD-US-AMERICANSAMOA', { file: 'us-counties-americansamoa.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: -14.26, long: -170.6, zoom: 6.5, });
    maps.set('THE WORLD-US-ARKANSAS', { file: 'us-counties-arkansas.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 35.146, long: -92.33, zoom: 6.5, });
    maps.set('THE WORLD-US-CONNECTICUT', { file: 'us-counties-connecticut.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: -72.492, long: 41.947, zoom: 6.5, });
    maps.set('THE WORLD-US-DELAWARE', { file: 'us-counties-delaware.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 39.38, long: -75.481, zoom: 8.5, });
    maps.set('THE WORLD-US-ARIZONA', { file: 'us-counties-arizona.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 34.0, long: -111, zoom: 7.5, });
    maps.set('THE WORLD-US-MAINE', { file: 'us-counties-maine.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 45.0, long: -68.0, zoom: 7.5, });
    maps.set('THE WORLD-US-IDAHO', { file: 'us-counties-idaho.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: -114.0, long: 44.0, zoom: 7.5, });
    maps.set('THE WORLD-US-NEVADA', { file: 'us-counties-nevada.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 39.0, long: -116.0, zoom: 6.5, });
    maps.set('THE WORLD-US-CALIFORNIA', { file: 'us-counties-california.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 38.43, long: -122.68, zoom: 6.5, });
    maps.set('THE WORLD-US-DISTRICTOFCOLUMBIA', { file: 'us-counties-districtofcolumbia.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: -77.119, long: 38.934, zoom: 6.5, });
    maps.set('THE WORLD-US-GUAM', { file: 'us-counties-guam.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 13.442, long: 144.76, zoom: 6.5, });
    maps.set('THE WORLD-US-HAWAII', { file: 'us-counties-hawaii.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 23.7186, long: -164.736, zoom: 6.5, });
    maps.set('THE WORLD-US-ILLINOIS', { file: 'us-counties-illinois.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 40.507, long: -89.513, zoom: 6.5, });
    maps.set('THE WORLD-US-INDIANA', { file: 'us-counties-indiana.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 40.3016, long: -86.475, zoom: 6.5, });
    maps.set('THE WORLD-US-IOWA', { file: 'us-counties-iowa.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 42.383, long: -93.2404, zoom: 6.5, });
    maps.set('THE WORLD-US-KANSAS', { file: 'us-counties-kansas.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 38.4789, long: -98.756, zoom: 6.5, });
    maps.set('THE WORLD-US-KENTUCKY', { file: 'us-counties-kentucky.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 37.058, long: -88.9993, zoom: 6.5, });
    maps.set('THE WORLD-US-LOUISIANA', { file: 'us-counties-louisiana.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 30.728, long: -92.405904, zoom: 7.25, });
    maps.set('THE WORLD-US-MARYLAND', { file: 'us-counties-maryland.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 38.994, long: -76.567, zoom: 7.5, });
    maps.set('THE WORLD-US-MASSACHUSETTS', { file: 'us-counties-massachusetts.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 41.8, long: -71.391, zoom: 8.5, });
    maps.set('THE WORLD-US-MICHIGAN', { file: 'us-counties-michigan.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 44.335, long: -84.6115, zoom: 6.5, });
    maps.set('THE WORLD-US-MINNESOTA', { file: 'us-counties-minnesota.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 46.9496, long: -94.325, zoom: 7.25, });
    maps.set('THE WORLD-US-MISSISSIPPI', { file: 'us-counties-mississippi.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 33.086, long: -89.581, zoom: 7.0, });
    maps.set('THE WORLD-US-MONTANA', { file: 'us-counties-montana.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 46.9, long: -109.5, zoom: 7.0, });
    maps.set('THE WORLD-US-NEBRASKA', { file: 'us-counties-nebraska.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 41.394264035, long: -99.7261437929, zoom: 7.0, });
    maps.set('THE WORLD-US-NEW HAMPSHIRE', { file: 'us-counties-newhampshire.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 43.5179685655, long: -71.4226936036, zoom: 7.5, });
    maps.set('THE WORLD-US-NEW JERSEY', { file: 'us-counties-newjersey.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 40.2875173436, long: -74.1582023922, zoom: 7.25, });
    maps.set('THE WORLD-US-NEW MEXICO', { file: 'us-counties-newmexico.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 34.6404921514, long: -105850819579, zoom: 7.0, });
    maps.set('THE WORLD-US-NEW YORK', { file: 'us-counties-newyork.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 43.2417469044, long: -75.4358401731, zoom: 7.0, });
    maps.set('THE WORLD-US-NORTH CAROLINA', { file: 'us-counties-northcarolina.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 35.4751864248, long: -79.1714836119, zoom: 7.25, });
    maps.set('THE WORLD-US-NORTH DAKOTA', { file: 'us-counties-northdakota.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 47.6069508739, long: -101.321804009, zoom: 7.25, });
    maps.set('THE WORLD-US-NORTHERN MARIANA ISLANDS', { file: 'us-counties-northernmarianaislands.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 18.1183693017, long: 145.631090555, zoom: 7.5, });
    maps.set('THE WORLD-US-OHIO', { file: 'us-counties-ohio.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 40.5240865228, long: -82.7940677882, zoom: 7.25, });
    maps.set('THE WORLD-US-OKLAHOMA', { file: 'us-counties-oklahoma.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 35.5515100533, long: -97.4072328405, zoom: 7.0, });
    maps.set('THE WORLD-US-PENNSYLVANIA', { file: 'us-counties-pennsylvania.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 40.9193457751, long: -77.8199601615, zoom: 7.5, });
    maps.set('THE WORLD-US-PUERTO RICO', { file: 'us-counties-puertorico.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 18.2149040847, long: -66.4339884969, zoom: 7.5, });
    maps.set('THE WORLD-US-RHODE ISLAND', { file: 'us-counties-rhodeisland.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 41.5, long: -71.5790218623, zoom: 9.5, });
    maps.set('THE WORLD-US-SOUTH CAROLINA', { file: 'us-counties-southcarolina.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 34.0218460217, long: -80.9030859572, zoom: 7.5, });
    maps.set('THE WORLD-US-SOUTH DAKOTA', { file: 'us-counties-southdakota.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 44.7155640273, long: -100.132245565, zoom: 7.5, });
    maps.set('THE WORLD-US-TENNESSEE', { file: 'us-counties-tennessee.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 35.8427065264, long: -86.4167378958, zoom: 7.5, });
    maps.set('THE WORLD-US-TEXAS', { file: 'us-counties-texas.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 31.1988711407, long: -99.3474783776, zoom: 6.75, });
    maps.set('THE WORLD-US-UTAH', { file: 'us-counties-utah.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 39.3739160769, long: -111.57635488, zoom: 7.5, });
    maps.set('THE WORLD-US-VERMONT', { file: 'us-counties-vermont.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 44.2733844798, long: -72.6149783508, zoom: 7.5, });
    maps.set('THE WORLD-US-VIRGINIA', { file: 'us-counties-', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 37.5722077541, long: -72.6149783508, zoom: 7.5, });
    maps.set('THE WORLD-US-VIRGIN ISLANDS', { file: 'us-counties-virginislands.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 18.3286016876, long: -64.9670827857, zoom: 7.5, });
    maps.set('THE WORLD-US-WEST VIRGINIA', { file: 'us-counties-westvirginia.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 38.6998727176, long: -80.7192881391, zoom: 7.5, });
    maps.set('THE WORLD-US-WISCONSIN', { file: 'us-counties-wisconsin.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 44.4760263134, long: -89.501400671, zoom: 7.5, });
    maps.set('THE WORLD-US-MISSOURI', { file: 'us-counties-missouri.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 38.428, long: -92.629, zoom: 7.5, });
    maps.set('THE WORLD-US-WISCONSIN', { file: 'us-counties-wisconsin.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 44.4760263134, long: -89.501400671, zoom: 7.5, });
    maps.set('THE WORLD-US-COLORADO', { file: 'us-counties-colorado.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 39.365, long: -106.151, zoom: 7.5, });
    maps.set('THE WORLD-US-WYOMING', { file: 'us-counties-wyoming.geojson', secondaryFile: '', colorKeyField: 'geoid', selectKeyField: 'name', lat: 42.9622404458, long: -106.798493803, zoom: 7.25, });
    return maps;
  }

  static maps: Map<string, any> = Catalog.initMaps();

  static us_states: StatesType[] = [
    { name: 'ALABAMA', code: 'AL' },
    { name: 'ALASKA', code: 'AK' },
    { name: 'ARIZONA', code: 'AZ' },
    { name: 'ARKANSAS', code: 'AR' },
    { name: 'CALIFORNIA', code: 'CA' },
    { name: 'COLORADO', code: 'CO' },
    { name: 'CONNECTICUT', code: 'CT' },
    { name: 'DELAWARE', code: 'DE' },
    { name: 'FLORIDA', code: 'FL' },
    { name: 'GEORGIA', code: 'GA' },
    { name: 'HAWAII', code: 'HI' },
    { name: 'IDAHO', code: 'ID' },
    { name: 'ILLINOIS', code: 'IL' },
    { name: 'INDIANA', code: 'IN' },
    { name: 'IOWA', code: 'IA' },
    { name: 'KANSAS', code: 'KS' },
    { name: 'KENTUCKY', code: 'KY' },
    { name: 'LOUISIANA', code: 'LA' },
    { name: 'MAINE', code: 'ME' },
    { name: 'MARYLAND', code: 'MD' },
    { name: 'MASSACHUSETTS', code: 'MA' },
    { name: 'MICHIGAN', code: 'MI' },
    { name: 'MINNESOTA', code: 'MN' },
    { name: 'MISSISSIPPI', code: 'MS' },
    { name: 'MISSOURI', code: 'MO' },
    { name: 'MONTANA', code: 'MT' },
    { name: 'NEBRASKA', code: 'NE' },
    { name: 'NEVADA', code: 'NV' },
    { name: 'NEW HAMPSHIRE', code: 'NH' },
    { name: 'NEW JERSEY', code: 'NJ' },
    { name: 'NEW MEXICO', code: 'NM' },
    { name: 'NEW YORK', code: 'NY' },
    { name: 'NORTH CAROLINA', code: 'NC' },
    { name: 'NORTH DAKOTA', code: 'ND' },
    { name: 'OHIO', code: 'OH' },
    { name: 'OKLAHOMA', code: 'OK' },
    { name: 'OREGON', code: 'OR' },
    { name: 'PENNSYLVANIA', code: 'PA' },
    { name: 'RHODE ISLAND', code: 'RI' },
    { name: 'SOUTH CAROLINA', code: 'SC' },
    { name: 'SOUTH DAKOTA', code: 'SD' },
    { name: 'TENNESSEE', code: 'TN' },
    { name: 'TEXAS', code: 'TX' },
    { name: 'UTAH', code: 'UT' },
    { name: 'VERMONT', code: 'VT' },
    { name: 'VIRGINIA', code: 'VA' },
    { name: 'WASHINGTON', code: 'WA' },
    { name: 'WEST VIRGINIA', code: 'WV' },
    { name: 'WISCONSIN', code: 'WI' },
    { name: 'WYOMING', code: 'WY' },
  ];

  static countries: CountriesType[] = [
    {
      name: 'AFGHANISTAN',
    },
    {
      name: 'ALBANIA',
    },
    {
      name: 'ALGERIA',
    },
    {
      name: 'ANDORRA',
    },
    {
      name: 'ANGOLA',
    },
    {
      name: 'ANTIGUA AND BARBUDA',
    },
    {
      name: 'ARGENTINA',
    },
    {
      name: 'ARMENIA',
    },
    {
      name: 'ARUBA',
    },
    {
      name: 'AUSTRALIA',
    },
    {
      name: 'AUSTRIA',
    },
    {
      name: 'AZERBAIJAN',
    },
    {
      name: 'BAHAMAS',
    },
    {
      name: 'BAHAMAS, THE',
    },
    {
      name: 'BAHRAIN',
    },
    {
      name: 'BANGLADESH',
    },
    {
      name: 'BARBADOS',
    },
    {
      name: 'BELARUS',
    },
    {
      name: 'BELGIUM',
    },
    {
      name: 'BELIZE',
    },
    {
      name: 'BENIN',
    },
    {
      name: 'BHUTAN',
    },
    {
      name: 'BOLIVIA',
    },
    {
      name: 'BOSNIA AND HERZEGOVINA',
    },
    {
      name: 'BOTSWANA',
    },
    {
      name: 'BRAZIL',
    },
    {
      name: 'BRUNEI',
    },
    {
      name: 'BULGARIA',
    },
    {
      name: 'BURKINA FASO',
    },
    {
      name: 'BURMA',
    },
    {
      name: 'BURUNDI',
    },
    {
      name: 'CABO VERDE',
    },
    {
      name: 'CAMBODIA',
    },
    {
      name: 'CAMEROON',
    },
    {
      name: 'CANADA',
    },
    {
      name: 'CAPE VERDE',
    },
    {
      name: 'CENTRAL AFRICAN REPUBLIC',
    },
    {
      name: 'CHAD',
    },
    {
      name: 'CHILE',
    },
    {
      name: 'CHINA',
    },
    {
      name: 'COLOMBIA',
    },
    {
      name: 'CONGO (BRAZZAVILLE)',
    },
    {
      name: 'CONGO (KINSHASA)',
    },
    {
      name: 'COSTA RICA',
    },
    {
      name: "COTE D'IVOIRE",
    },
    {
      name: 'CROATIA',
    },
    {
      name: 'CRUISE SHIP',
    },
    {
      name: 'CUBA',
    },
    {
      name: 'CYPRUS',
    },
    {
      name: 'CZECHIA',
    },
    {
      name: 'DENMARK',
    },
    {
      name: 'DIAMOND PRINCESS',
    },
    {
      name: 'DJIBOUTI',
    },
    {
      name: 'DOMINICA',
    },
    {
      name: 'DOMINICAN REPUBLIC',
    },
    {
      name: 'EAST TIMOR',
    },
    {
      name: 'ECUADOR',
    },
    {
      name: 'EGYPT',
    },
    {
      name: 'EL SALVADOR',
    },
    {
      name: 'EQUATORIAL GUINEA',
    },
    {
      name: 'ERITREA',
    },
    {
      name: 'ESTONIA',
    },
    {
      name: 'ESWATINI',
    },
    {
      name: 'ETHIOPIA',
    },
    {
      name: 'FIJI',
    },
    {
      name: 'FINLAND',
    },
    {
      name: 'FRANCE',
    },
    {
      name: 'FRENCH GUIANA',
    },
    {
      name: 'GABON',
    },
    {
      name: 'GAMBIA',
    },
    {
      name: 'GAMBIA, THE',
    },
    {
      name: 'GEORGIA',
    },
    {
      name: 'GERMANY',
    },
    {
      name: 'GHANA',
    },
    {
      name: 'GREECE',
    },
    {
      name: 'GREENLAND',
    },
    {
      name: 'GRENADA',
    },
    {
      name: 'GUADELOUPE',
    },
    {
      name: 'GUAM',
    },
    {
      name: 'GUATEMALA',
    },
    {
      name: 'GUERNSEY',
    },
    {
      name: 'GUINEA',
    },
    {
      name: 'GUINEA-BISSAU',
    },
    {
      name: 'GUYANA',
    },
    {
      name: 'HAITI',
    },
    {
      name: 'HOLY SEE',
    },
    {
      name: 'HONDURAS',
    },
    {
      name: 'HUNGARY',
    },
    {
      name: 'ICELAND',
    },
    {
      name: 'INDIA',
    },
    {
      name: 'INDONESIA',
    },
    {
      name: 'IRAN',
    },
    {
      name: 'IRAQ',
    },
    {
      name: 'IRELAND',
    },
    {
      name: 'ISRAEL',
    },
    {
      name: 'ITALY',
    },
    {
      name: 'JAMAICA',
    },
    {
      name: 'JAPAN',
    },
    {
      name: 'JERSEY',
    },
    {
      name: 'JORDAN',
    },
    {
      name: 'KAZAKHSTAN',
    },
    {
      name: 'KENYA',
    },
    {
      name: 'KOREA, SOUTH',
    },
    {
      name: 'KOSOVO',
    },
    {
      name: 'KUWAIT',
    },
    {
      name: 'KYRGYZSTAN',
    },
    {
      name: 'LAOS',
    },
    {
      name: 'LATVIA',
    },
    {
      name: 'LEBANON',
    },
    {
      name: 'LIBERIA',
    },
    {
      name: 'LIBYA',
    },
    {
      name: 'LIECHTENSTEIN',
    },
    {
      name: 'LITHUANIA',
    },
    {
      name: 'LUXEMBOURG',
    },
    {
      name: 'MADAGASCAR',
    },
    {
      name: 'MALAWI',
    },
    {
      name: 'MALAYSIA',
    },
    {
      name: 'MALDIVES',
    },
    {
      name: 'MALI',
    },
    {
      name: 'MALTA',
    },
    {
      name: 'MARTINIQUE',
    },
    {
      name: 'MAURITANIA',
    },
    {
      name: 'MAURITIUS',
    },
    {
      name: 'MAYOTTE',
    },
    {
      name: 'MEXICO',
    },
    {
      name: 'MOLDOVA',
    },
    {
      name: 'MONACO',
    },
    {
      name: 'MONGOLIA',
    },
    {
      name: 'MONTENEGRO',
    },
    {
      name: 'MOROCCO',
    },
    {
      name: 'MOZAMBIQUE',
    },
    {
      name: 'MS ZAANDAM',
    },
    {
      name: 'NAMIBIA',
    },
    {
      name: 'NEPAL',
    },
    {
      name: 'NETHERLANDS',
    },
    {
      name: 'NEW ZEALAND',
    },
    {
      name: 'NICARAGUA',
    },
    {
      name: 'NIGER',
    },
    {
      name: 'NIGERIA',
    },
    {
      name: 'NORTH MACEDONIA',
    },
    {
      name: 'NORWAY',
    },
    {
      name: 'OCCUPIED PALESTINIAN TERRITORY',
    },
    {
      name: 'OMAN',
    },
    {
      name: 'PAKISTAN',
    },
    {
      name: 'PANAMA',
    },
    {
      name: 'PAPUA NEW GUINEA',
    },
    {
      name: 'PARAGUAY',
    },
    {
      name: 'PERU',
    },
    {
      name: 'PHILIPPINES',
    },
    {
      name: 'POLAND',
    },
    {
      name: 'PORTUGAL',
    },
    {
      name: 'PUERTO RICO',
    },
    {
      name: 'QATAR',
    },
    {
      name: 'REPUBLIC OF THE CONGO',
    },
    {
      name: 'REUNION',
    },
    {
      name: 'ROMANIA',
    },
    {
      name: 'RUSSIA',
    },
    {
      name: 'RWANDA',
    },
    {
      name: 'SAINT KITTS AND NEVIS',
    },
    {
      name: 'SAINT LUCIA',
    },
    {
      name: 'SAINT VINCENT AND THE GRENADINES',
    },
    {
      name: 'SAN MARINO',
    },
    {
      name: 'SAUDI ARABIA',
    },
    {
      name: 'SENEGAL',
    },
    {
      name: 'SERBIA',
    },
    {
      name: 'SEYCHELLES',
    },
    {
      name: 'SIERRA LEONE',
    },
    {
      name: 'SINGAPORE',
    },
    {
      name: 'SLOVAKIA',
    },
    {
      name: 'SLOVENIA',
    },
    {
      name: 'SOMALIA',
    },
    {
      name: 'SOUTH AFRICA',
    },
    {
      name: 'SOUTH KOREA',
    },
    {
      name: 'SOUTH SUDAN',
    },
    {
      name: 'SPAIN',
    },
    {
      name: 'SRI LANKA',
    },
    {
      name: 'SUDAN',
    },
    {
      name: 'SURINAME',
    },
    {
      name: 'SWEDEN',
    },
    {
      name: 'SWITZERLAND',
    },
    {
      name: 'SYRIA',
    },
    {
      name: 'TAIWAN*',
    },
    {
      name: 'TANZANIA',
    },
    {
      name: 'THAILAND',
    },
    {
      name: 'THE BAHAMAS',
    },
    {
      name: 'THE GAMBIA',
    },
    {
      name: 'TIMOR-LESTE',
    },
    {
      name: 'TOGO',
    },
    {
      name: 'TRINIDAD AND TOBAGO',
    },
    {
      name: 'TUNISIA',
    },
    {
      name: 'TURKEY',
    },
    {
      name: 'UGANDA',
    },
    {
      name: 'UKRAINE',
    },
    {
      name: 'UNITED ARAB EMIRATES',
    },
    {
      name: 'UNITED KINGDOM',
    },
    {
      name: 'URUGUAY',
    },
    {
      name: 'US',
    },
    {
      name: 'UZBEKISTAN',
    },
    {
      name: 'VENEZUELA',
    },
    {
      name: 'VIETNAM',
    },
    {
      name: 'WEST BANK AND GAZA',
    },
    {
      name: 'WESTERN SAHARA',
    },
    {
      name: 'ZAMBIA',
    },
    {
      name: 'ZIMBABWE',
    },
  ];
}

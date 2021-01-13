EXPORT oxcgrt := MODULE 

//Please refer to the following doc for definitions:
//https://github.com/OxCGRT/covid-policy-tracker/blob/master/documentation/codebook.md 

EXPORT filepath := '~hpccsystems::covid19::file::raw::oxcgrt::v2::oxcgrt_latest.csv';
EXPORT layout := RECORD
    STRING CountryName;
    STRING CountryCode;
    STRING RegionName;
    STRING RegionCode;
    STRING Jurisdiction;
    STRING Date;
    REAL C1_School_closing;
    STRING C1_Flag;
    REAL C2_Workplace_closing;
    STRING C2_Flag;
    REAL C3_Cancel_public_events;
    STRING C3_Flag;
    REAL C4_Restrictions_on_gatherings;
    STRING C4_Flag;
    REAL C5_Close_public_transport;
    STRING C5_Flag;
    REAL C6_Stay_at_home_requirements;
    STRING C6_Flag;
    REAL C7_Restrictions_on_internal_movement;
    STRING C7_Flag;
    REAL C8_International_travel_controls;
    REAL E1_Income_support;
    STRING E1_Flag;
    REAL E2_Debt_contract_relief;
    REAL E3_Fiscal_measures;
    REAL E4_International_support;
    REAL H1_Public_information_campaigns;
    STRING H1_Flag;
    REAL H2_Testing_policy;
    REAL H3_Contact_tracing;
    REAL H4_Emergency_investment_in_healthcare;
    REAL H5_Investment_in_vaccines;
    REAL H6_Facial_Coverings;
    STRING H6_Flag;
    REAL H7_Vaccination_policy;
    STRING H7_Flag;
    REAL M1_Wildcard;
    REAL ConfirmedCases;
    REAL ConfirmedDeaths;
    REAL StringencyIndex;
    STRING StringencyIndexForDisplay;
    REAL StringencyLegacyIndex;
    STRING StringencyLegacyIndexForDisplay;
    REAL GovernmentResponseIndex;
    STRING GovernmentResponseIndexForDisplay;
    REAL ContainmentHealthIndex;
    STRING ContainmentHealthIndexForDisplay;
    REAL EconomicSupportIndex;
    STRING EconomicSupportIndexForDisplay;
END;

EXPORT ds := DATASET(filepath, Layout, CSV(HEADING(1)));

END;
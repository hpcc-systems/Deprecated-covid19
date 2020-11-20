EXPORT oxcgrt := MODULE 

EXPORT filepath := '~hpccsystems::covid19::file::raw::oxcgrt::v1::oxcgrt_latest.csv';
EXPORT layout := RECORD
    STRING CountryName;
    STRING CountryCode;
    STRING RegionName;
    STRING RegionCode;
    STRING Date;
    STRING C1_School_closing;
    STRING C1_Flag;
    STRING C2_Workplace_closing;
    STRING C2_Flag;
    STRING C3_Cancel_public_events;
    STRING C3_Flag;
    STRING C4_Restrictions_on_gatherings;
    STRING C4_Flag;
    STRING C5_Close_public_transport;
    STRING C5_Flag;
    STRING C6_Stay_at_home_requirements;
    STRING C6_Flag;
    STRING C7_Restrictions_on_internal_movement;
    STRING C7_Flag;
    STRING C8_International_travel_controls;
    STRING E1_Income_support;
    STRING E1_Flag;
    STRING E2_Debt_contract_relief;
    STRING E3_Fiscal_measures;
    STRING E4_International_support;
    STRING H1_Public_information_campaigns;
    STRING H1_Flag;
    STRING H2_Testing_policy;
    STRING H3_Contact_tracing;
    STRING H4_Emergency_investment_in_healthcare;
    STRING H5_Investment_in_vaccines;
    STRING H6_Facial_Coverings;
    STRING H6_Flag;
    STRING M1_Wildcard;
    STRING ConfirmedCases;
    STRING ConfirmedDeaths;
    STRING StringencyIndex;
    STRING StringencyIndexForDisplay;
    STRING StringencyLegacyIndex;
    STRING StringencyLegacyIndexForDisplay;
    STRING GovernmentResponseIndex;
    STRING GovernmentResponseIndexForDisplay;
    STRING ContainmentHealthIndex;
    STRING ContainmentHealthIndexForDisplay;
    STRING EconomicSupportIndex;
    STRING EconomicSupportIndexForDisplay;
END;

EXPORT ds := DATASET(filepath, Layout, CSV(HEADING(1)));

END;
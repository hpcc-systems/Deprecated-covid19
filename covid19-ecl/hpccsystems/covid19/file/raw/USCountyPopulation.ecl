EXPORT USCountyPopulation := MODULE

  EXPORT filePath := '~hpccsystems::covid19::file::raw::uscountypopulation::v1::co-est2019-alldata.csv';  
                       

  EXPORT layout := RECORD
    STRING SUMLEV;
    STRING REGION;
    STRING DIVISION;
    STRING STATE;
    STRING COUNTY;
    STRING STNAME;
    STRING CTYNAME;
    STRING CENSUS2010POP;
    STRING ESTIMATESBASE2010;
    STRING POPESTIMATE2010;
    STRING POPESTIMATE2011;
    STRING POPESTIMATE2012;
    STRING POPESTIMATE2013;
    STRING POPESTIMATE2014;
    STRING POPESTIMATE2015;
    STRING POPESTIMATE2016;
    STRING POPESTIMATE2017;
    STRING POPESTIMATE2018;
    STRING POPESTIMATE2019;
    STRING NPOPCHG_2010;
    STRING NPOPCHG_2011;
    STRING NPOPCHG_2012;
    STRING NPOPCHG_2013;
    STRING NPOPCHG_2014;
    STRING NPOPCHG_2015;
    STRING NPOPCHG_2016;
    STRING NPOPCHG_2017;
    STRING NPOPCHG_2018;
    STRING NPOPCHG_2019;
    STRING BIRTHS2010;
    STRING BIRTHS2011;
    STRING BIRTHS2012;
    STRING BIRTHS2013;
    STRING BIRTHS2014;
    STRING BIRTHS2015;
    STRING BIRTHS2016;
    STRING BIRTHS2017;
    STRING BIRTHS2018;
    STRING BIRTHS2019;
    STRING DEATHS2010;
    STRING DEATHS2011;
    STRING DEATHS2012;
    STRING DEATHS2013;
    STRING DEATHS2014;
    STRING DEATHS2015;
    STRING DEATHS2016;
    STRING DEATHS2017;
    STRING DEATHS2018;
    STRING DEATHS2019;
    STRING NATURALINC2010;
    STRING NATURALINC2011;
    STRING NATURALINC2012;
    STRING NATURALINC2013;
    STRING NATURALINC2014;
    STRING NATURALINC2015;
    STRING NATURALINC2016;
    STRING NATURALINC2017;
    STRING NATURALINC2018;
    STRING NATURALINC2019;
    STRING INTERNATIONALMIG2010;
    STRING INTERNATIONALMIG2011;
    STRING INTERNATIONALMIG2012;
    STRING INTERNATIONALMIG2013;
    STRING INTERNATIONALMIG2014;
    STRING INTERNATIONALMIG2015;
    STRING INTERNATIONALMIG2016;
    STRING INTERNATIONALMIG2017;
    STRING INTERNATIONALMIG2018;
    STRING INTERNATIONALMIG2019;
    STRING DOMESTICMIG2010;
    STRING DOMESTICMIG2011;
    STRING DOMESTICMIG2012;
    STRING DOMESTICMIG2013;
    STRING DOMESTICMIG2014;
    STRING DOMESTICMIG2015;
    STRING DOMESTICMIG2016;
    STRING DOMESTICMIG2017;
    STRING DOMESTICMIG2018;
    STRING DOMESTICMIG2019;
    STRING NETMIG2010;
    STRING NETMIG2011;
    STRING NETMIG2012;
    STRING NETMIG2013;
    STRING NETMIG2014;
    STRING NETMIG2015;
    STRING NETMIG2016;
    STRING NETMIG2017;
    STRING NETMIG2018;
    STRING NETMIG2019;
    STRING RESIDUAL2010;
    STRING RESIDUAL2011;
    STRING RESIDUAL2012;
    STRING RESIDUAL2013;
    STRING RESIDUAL2014;
    STRING RESIDUAL2015;
    STRING RESIDUAL2016;
    STRING RESIDUAL2017;
    STRING RESIDUAL2018;
    STRING RESIDUAL2019;
    STRING GQESTIMATESBASE2010;
    STRING GQESTIMATES2010;
    STRING GQESTIMATES2011;
    STRING GQESTIMATES2012;
    STRING GQESTIMATES2013;
    STRING GQESTIMATES2014;
    STRING GQESTIMATES2015;
    STRING GQESTIMATES2016;
    STRING GQESTIMATES2017;
    STRING GQESTIMATES2018;
    STRING GQESTIMATES2019;
    STRING RBIRTH2011;
    STRING RBIRTH2012;
    STRING RBIRTH2013;
    STRING RBIRTH2014;
    STRING RBIRTH2015;
    STRING RBIRTH2016;
    STRING RBIRTH2017;
    STRING RBIRTH2018;
    STRING RBIRTH2019;
    STRING RDEATH2011;
    STRING RDEATH2012;
    STRING RDEATH2013;
    STRING RDEATH2014;
    STRING RDEATH2015;
    STRING RDEATH2016;
    STRING RDEATH2017;
    STRING RDEATH2018;
    STRING RDEATH2019;
    STRING RNATURALINC2011;
    STRING RNATURALINC2012;
    STRING RNATURALINC2013;
    STRING RNATURALINC2014;
    STRING RNATURALINC2015;
    STRING RNATURALINC2016;
    STRING RNATURALINC2017;
    STRING RNATURALINC2018;
    STRING RNATURALINC2019;
    STRING RINTERNATIONALMIG2011;
    STRING RINTERNATIONALMIG2012;
    STRING RINTERNATIONALMIG2013;
    STRING RINTERNATIONALMIG2014;
    STRING RINTERNATIONALMIG2015;
    STRING RINTERNATIONALMIG2016;
    STRING RINTERNATIONALMIG2017;
    STRING RINTERNATIONALMIG2018;
    STRING RINTERNATIONALMIG2019;
    STRING RDOMESTICMIG2011;
    STRING RDOMESTICMIG2012;
    STRING RDOMESTICMIG2013;
    STRING RDOMESTICMIG2014;
    STRING RDOMESTICMIG2015;
    STRING RDOMESTICMIG2016;
    STRING RDOMESTICMIG2017;
    STRING RDOMESTICMIG2018;
    STRING RDOMESTICMIG2019;
    STRING RNETMIG2011;
    STRING RNETMIG2012;
    STRING RNETMIG2013;
    STRING RNETMIG2014;
    STRING RNETMIG2015;
    STRING RNETMIG2016;
    STRING RNETMIG2017;
    STRING RNETMIG2018;
    STRING RNETMIG2019;
  END;


  EXPORT ds := DATASET(filePath, layout, CSV(HEADING(1)));  


   EXPORT filePath_agegender := '~hpccsystems::covid19::file::raw::uscountypopulation::v1::cc-est2018-alldata.csv';  
                       

  EXPORT layout_agegender := RECORD
    STRING SUMLEV;
    STRING STATE;
    STRING COUNTY;
    STRING STNAME;
    STRING CTYNAME;
    STRING YEAR;
    STRING AGEGRP;
    STRING TOT_POP;
    STRING TOT_MALE;
    STRING TOT_FEMALE;
    STRING WA_MALE;
    STRING WA_FEMALE;
    STRING BA_MALE;
    STRING BA_FEMALE;
    STRING IA_MALE;
    STRING IA_FEMALE;
    STRING AA_MALE;
    STRING AA_FEMALE;
    STRING NA_MALE;
    STRING NA_FEMALE;
    STRING TOM_MALE;
    STRING TOM_FEMALE;
    STRING WAC_MALE;
    STRING WAC_FEMALE;
    STRING BAC_MALE;
    STRING BAC_FEMALE;
    STRING IAC_MALE;
    STRING IAC_FEMALE;
    STRING AAC_MALE;
    STRING AAC_FEMALE;
    STRING NAC_MALE;
    STRING NAC_FEMALE;
    STRING NH_MALE;
    STRING NH_FEMALE;
    STRING NHWA_MALE;
    STRING NHWA_FEMALE;
    STRING NHBA_MALE;
    STRING NHBA_FEMALE;
    STRING NHIA_MALE;
    STRING NHIA_FEMALE;
    STRING NHAA_MALE;
    STRING NHAA_FEMALE;
    STRING NHNA_MALE;
    STRING NHNA_FEMALE;
    STRING NHTOM_MALE;
    STRING NHTOM_FEMALE;
    STRING NHWAC_MALE;
    STRING NHWAC_FEMALE;
    STRING NHBAC_MALE;
    STRING NHBAC_FEMALE;
    STRING NHIAC_MALE;
    STRING NHIAC_FEMALE;
    STRING NHAAC_MALE;
    STRING NHAAC_FEMALE;
    STRING NHNAC_MALE;
    STRING NHNAC_FEMALE;
    STRING H_MALE;
    STRING H_FEMALE;
    STRING HWA_MALE;
    STRING HWA_FEMALE;
    STRING HBA_MALE;
    STRING HBA_FEMALE;
    STRING HIA_MALE;
    STRING HIA_FEMALE;
    STRING HAA_MALE;
    STRING HAA_FEMALE;
    STRING HNA_MALE;
    STRING HNA_FEMALE;
    STRING HTOM_MALE;
    STRING HTOM_FEMALE;
    STRING HWAC_MALE;
    STRING HWAC_FEMALE;
    STRING HBAC_MALE;
    STRING HBAC_FEMALE;
    STRING HIAC_MALE;
    STRING HIAC_FEMALE;
    STRING HAAC_MALE;
    STRING HAAC_FEMALE;
    STRING HNAC_MALE;
    STRING HNAC_FEMALE;
  END;


  EXPORT ds_agegender := DATASET(filePath_agegender, layout_agegender, CSV(HEADING(1)));   


END;
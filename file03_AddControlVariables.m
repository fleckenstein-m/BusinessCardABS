clear; clc;

filePath = "E:\Dropbox\Work\Research\BusinessCardABS\Analysis\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\BusinessCardABS\Analysis\";
fileName = "file02_CleanupPanelDataset.mat";
load(strcat(filePath,fileName),'Advanta_ABCMT_Tbl','Advanta_ABCMT_Mat')


% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 41);
% Specify sheet and range
opts.Sheet = "Static";
opts.DataRange = "A2:AO9296";
% Specify column names and types
opts.VariableNames = ["Date_yyyymmdd",  "SP500_Index_TR","BB_USCorpAggr_Index_TR","BB_USCorpHY_Index_TR","BB_USAgg_Index_TR","BB_USTreas_Index_TR","Moodys_AAA_Index", "Moodys_BAA_Index", "Moodys_AllCorp_Index", "Tbill_1m", "Tbill_3m", "VIX_Index", "MOVE_Index", "GDP_QoQ", "ADP_Empl_YoY", "ADP_Empl_MoM", "MichConsSent_Index", "MichEconCond_Index", "ChicFed_NatActiv_Index", "ChicFed_FinCond_Index", "ChicFed_FinCreditCond_Index", "ChicFed_NonfinLeverage_Index", "EmprStSrv_GenBusCond_Index", "EmprStSrv_HighBusExpPrct_Index", "EmprStSrv_LowBusExpPrct_Index", "SFP_AnxiousIndex_CurrQrt", "SFP_UnemplNatRate", "SFP_NomGDP_CurrYrPlusOne", "SFP_NonCorpProfits_CurrYrPlusOne", "SFP_RealGDP_CurrQrtPlus4", "SFP_UnemplRate_currYr", "SFP_AnxiousIndex_currQrtPlus4", "SFP_RealCons_CurrQrtPlus4", "ConfBrd_BusConfidenceBad_Index", "ConfBrd_ConsConf_Index", "ConfBrd_LeadIndicator_Index_YoY", "ConfBrd_LeadIndicator_Index_MoM", "ConfBrd_LeadCreditIndicator_Index", "ConfBrd_InitJoblClaimsWkly_Index", "ConfBrd_EmploymentTrend_Index", "Bloomberg_EconBusCycleSurpr_Index"];
opts.VariableTypes = ["double", "double", "double","double", "double", "double", "double","double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Import the data
ControlVariables = readtable("E:\Dropbox\Work\Research\BusinessCardABS\Data\Controlvariables\ControlVariables.xlsx", opts, "UseExcel", false);
% Clear temporary variables
clear opts
[tmpYr,tmpMnth,tmpDay] = Convert_yyyymmdd(ControlVariables.Date_yyyymmdd);
ControlVariables.Date = datetime(tmpYr,tmpMnth,tmpDay);
ControlVariables.Date_yyyymmdd = [];
ControlVariables = table2timetable(ControlVariables,'RowTimes','Date');
ControlVariables = standardizeMissing(ControlVariables,-999);
%to monthly
ControlVariables_m = retime(ControlVariables,'monthly','lastvalue');
ControlVariables_m.Date = eomdate(year(ControlVariables_m.Date),month(ControlVariables_m.Date),'datetime');



%get Fama French Factors
opts = delimitedTextImportOptions("NumVariables", 6);
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["dateff", "MktRf", "Smb", "Hml", "Rf", "Umd"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Import the data
FamaFrenchFactors = readtable("E:\Dropbox\Work\Research\BusinessCardABS\Data\Controlvariables\FamaFrenchFactors.csv", opts);
[tmpYear,tmpMonth,tmpDay] = Convert_yyyymmdd(FamaFrenchFactors.dateff);
FamaFrenchFactors.Date = datetime(tmpYear,tmpMonth,tmpDay);
FamaFrenchFactors = table2timetable(FamaFrenchFactors,'RowTimes','Date');
FamaFrenchFactors.dateff = [];
FamaFrenchFactors{:,:} = FamaFrenchFactors{:,:}.*100;
FamaFrenchFactors.Date = eomdate(year(FamaFrenchFactors.Date),month(FamaFrenchFactors.Date),'datetime');
%merge
ControlVariables_m = outerjoin(ControlVariables_m,FamaFrenchFactors,'Type','left');
ControlVariables_m = movevars(ControlVariables_m,["MktRf","Smb","Hml","Rf","Umd"],'Before',1);
ControlVariables_m.Date_yyyymm = year(ControlVariables_m.Date)*100+month(ControlVariables_m.Date);
ControlVariables_m = movevars(ControlVariables_m,'Date_yyyymm','Before',1);


%Variables
% Variable Name             Unit
% SP500_Index               Level
% BB_USCorpAggr_Index_TR	Level
% BB_USCorpHY_Index_TR      Level
% BB_USAgg_Index_TR         Level
% BB_USTreas_Index_TR       Level
% 	
% Moodys_AAA_Index          Percent
% Moodys_BAA_Index          Percent
% Moodys_AllCorp_Index      Percent
% Tbill_1m                  Percent
% Tbill_3m                  Percent
% 	
% VIX_Index                 Level
% MOVE_Index                Level
% 	
% GDP_QoQ                   Percent
% ADP_Empl_YoY              Percent
% ADP_Empl_MoM              Percent
% 	
% MichConsSent_Index        Level
% MichEconCond_Index        Level
% 	
% ChicFed_NatActiv_Index        Level
% ChicFed_FinCond_Index	Level
% ChicFed_FinCreditCond_Index	Level
% ChicFed_NonfinLeverage_Index	Level
% 	
% EmprStSrv_GenBusCond_Index        Level
% EmprStSrv_HighBusExpPrct_Index	Level
% EmprStSrv_LowBusExpPrct_Index     Level
%       
% SFP_AnxiousIndex_CurrQrt      Level
% SFP_UnemplNatRate             Percent
% SFP_NomGDP_CurrYrPlusOne      Level
% SFP_NonCorpProfits_CurrYrPlusOne	Level
% SFP_RealGDP_CurrQrtPlus4      Level
% SFP_UnemplRate_currYr         Percent
% SFP_AnxiousIndex_currQrtPlus4	Level
% SFP_RealCons_CurrQrtPlus4     Level
% 	
% ConfBrd_BusConfidenceBad_Index	Percent (100=All respondents)
% ConfBrd_ConsConf_Index            Level
% ConfBrd_LeadIndicator_Index_YoY	Percent
% ConfBrd_LeadIndicator_Index_MoM	Percent
% ConfBrd_LeadCreditIndicator_Index	Level
% ConfBrd_InitJoblClaimsWkly_Index	Level
% ConfBrd_EmploymentTrend_Index     Level
% 	
% Bloomberg_EconBusCycleSurpr_Index	Percent


summary(ControlVariables_m)


%monthly returns
ControlVariablesRx_m = ControlVariables_m;
ControlVariablesRx_m{:,:}=NaN;

ControlVariablesRx_m.Date_yyyymm = ControlVariables_m.Date_yyyymm;

ControlVariablesRx_m.SP500_Index_TR = [NaN; ControlVariables_m.SP500_Index_TR(2:end)./ControlVariables_m.SP500_Index_TR(1:end-1)-1];
ControlVariablesRx_m.BB_USCorpAggr_Index_TR = [NaN; ControlVariables_m.BB_USCorpAggr_Index_TR(2:end)./ControlVariables_m.BB_USCorpAggr_Index_TR(1:end-1)-1];
ControlVariablesRx_m.BB_USCorpHY_Index_TR = [NaN; ControlVariables_m.BB_USCorpHY_Index_TR(2:end)./ControlVariables_m.BB_USCorpHY_Index_TR(1:end-1)-1];
ControlVariablesRx_m.BB_USAgg_Index_TR = [NaN; ControlVariables_m.BB_USAgg_Index_TR(2:end)./ControlVariables_m.BB_USAgg_Index_TR(1:end-1)-1];
ControlVariablesRx_m.BB_USTreas_Index_TR = [NaN; ControlVariables_m.BB_USTreas_Index_TR(2:end)./ControlVariables_m.BB_USTreas_Index_TR(1:end-1)-1];

ControlVariablesRx_m.Moodys_AAA_Index = [NaN; ControlVariables_m.Moodys_AAA_Index(2:end)-ControlVariables_m.Moodys_AAA_Index(1:end-1)-1]./100;
ControlVariablesRx_m.Moodys_BAA_Index = [NaN; ControlVariables_m.Moodys_BAA_Index(2:end)-ControlVariables_m.Moodys_BAA_Index(1:end-1)-1]./100;
ControlVariablesRx_m.Moodys_AllCorp_Index = [NaN; ControlVariables_m.Moodys_AllCorp_Index(2:end)-ControlVariables_m.Moodys_AllCorp_Index(1:end-1)-1]./100;
ControlVariablesRx_m.Tbill_1m = [NaN; ControlVariables_m.Tbill_1m(2:end)-ControlVariables_m.Tbill_1m(1:end-1)-1]./100;
ControlVariablesRx_m.Tbill_3m = [NaN; ControlVariables_m.Tbill_3m(2:end)-ControlVariables_m.Tbill_3m(1:end-1)-1]./100;

ControlVariablesRx_m.VIX_Index = [NaN; ControlVariables_m.VIX_Index(2:end)./ControlVariables_m.VIX_Index(1:end-1)-1];
ControlVariablesRx_m.MOVE_Index = [NaN; ControlVariables_m.MOVE_Index(2:end)./ControlVariables_m.MOVE_Index(1:end-1)-1];

ControlVariablesRx_m.GDP_QoQ = ControlVariables_m.GDP_QoQ./100;
ControlVariablesRx_m.ADP_Empl_YoY = ControlVariables_m.ADP_Empl_YoY./100;
ControlVariablesRx_m.ADP_Empl_MoM = ControlVariables_m.ADP_Empl_MoM./100;

ControlVariablesRx_m.MichConsSent_Index = [NaN; ControlVariables_m.MichConsSent_Index(2:end)-ControlVariables_m.MichConsSent_Index(1:end-1)];
ControlVariablesRx_m.MichEconCond_Index = [NaN; ControlVariables_m.MichEconCond_Index(2:end)-ControlVariables_m.MichEconCond_Index(1:end-1)];

ControlVariablesRx_m.ChicFed_NatActiv_Index = [NaN; ControlVariables_m.ChicFed_NatActiv_Index(2:end)-ControlVariables_m.ChicFed_NatActiv_Index(1:end-1)];
ControlVariablesRx_m.ChicFed_FinCond_Index = [NaN; ControlVariables_m.ChicFed_FinCond_Index(2:end)-ControlVariables_m.ChicFed_FinCond_Index(1:end-1)];
ControlVariablesRx_m.ChicFed_FinCreditCond_Index = [NaN; ControlVariables_m.ChicFed_FinCreditCond_Index(2:end)-ControlVariables_m.ChicFed_FinCreditCond_Index(1:end-1)];
ControlVariablesRx_m.ChicFed_NonfinLeverage_Index = [NaN; ControlVariables_m.ChicFed_NonfinLeverage_Index(2:end)-ControlVariables_m.ChicFed_NonfinLeverage_Index(1:end-1)];

ControlVariablesRx_m.EmprStSrv_GenBusCond_Index = [NaN; ControlVariables_m.EmprStSrv_GenBusCond_Index(2:end)-ControlVariables_m.EmprStSrv_GenBusCond_Index(1:end-1)]./100;
ControlVariablesRx_m.EmprStSrv_HighBusExpPrct_Index = [NaN; ControlVariables_m.EmprStSrv_HighBusExpPrct_Index(2:end)-ControlVariables_m.EmprStSrv_HighBusExpPrct_Index(1:end-1)]./100;
ControlVariablesRx_m.EmprStSrv_LowBusExpPrct_Index  = [NaN; ControlVariables_m.EmprStSrv_LowBusExpPrct_Index(2:end)-ControlVariables_m.EmprStSrv_LowBusExpPrct_Index(1:end-1)]./100;

ControlVariablesRx_m.SFP_AnxiousIndex_CurrQrt(6:end) = ControlVariables_m.SFP_AnxiousIndex_CurrQrt(6:end)-ControlVariables_m.SFP_AnxiousIndex_CurrQrt(3:end-3);
ControlVariablesRx_m.SFP_UnemplNatRate = ControlVariables_m.SFP_UnemplNatRate./100;
ControlVariablesRx_m.SFP_NomGDP_CurrYrPlusOne(6:end) = ControlVariables_m.SFP_NomGDP_CurrYrPlusOne(6:end)./ControlVariables_m.SFP_NomGDP_CurrYrPlusOne(3:end-3)-1;
ControlVariablesRx_m.SFP_NonCorpProfits_CurrYrPlusOne(6:end) = ControlVariables_m.SFP_NonCorpProfits_CurrYrPlusOne(6:end)./ControlVariables_m.SFP_NonCorpProfits_CurrYrPlusOne(3:end-3)-1;
ControlVariablesRx_m.SFP_RealGDP_CurrQrtPlus4(6:end) = ControlVariables_m.SFP_RealGDP_CurrQrtPlus4(6:end)./ControlVariables_m.SFP_RealGDP_CurrQrtPlus4(3:end-3)-1;
ControlVariablesRx_m.SFP_UnemplRate_currYr(6:end) = (ControlVariables_m.SFP_UnemplRate_currYr(6:end)-ControlVariables_m.SFP_UnemplRate_currYr(3:end-3))./100;
ControlVariablesRx_m.SFP_AnxiousIndex_currQrtPlus4(6:end) = ControlVariables_m.SFP_AnxiousIndex_currQrtPlus4(6:end)-ControlVariables_m.SFP_AnxiousIndex_currQrtPlus4(3:end-3);
ControlVariablesRx_m.SFP_RealCons_CurrQrtPlus4(6:end) = ControlVariables_m.SFP_RealCons_CurrQrtPlus4(6:end)./ControlVariables_m.SFP_RealCons_CurrQrtPlus4(3:end-3)-1;

ControlVariablesRx_m.ConfBrd_BusConfidenceBad_Index = [NaN; ControlVariables_m.ConfBrd_BusConfidenceBad_Index(2:end)-ControlVariables_m.ConfBrd_BusConfidenceBad_Index(1:end-1)];
ControlVariablesRx_m.ConfBrd_ConsConf_Index = [NaN; ControlVariables_m.ConfBrd_ConsConf_Index(2:end)-ControlVariables_m.ConfBrd_ConsConf_Index(1:end-1)];
ControlVariablesRx_m.ConfBrd_LeadIndicator_Index_YoY = ControlVariables_m.ConfBrd_LeadIndicator_Index_YoY./100;
ControlVariablesRx_m.ConfBrd_LeadIndicator_Index_MoM = ControlVariables_m.ConfBrd_LeadIndicator_Index_MoM./100;
ControlVariablesRx_m.ConfBrd_LeadCreditIndicator_Index = [NaN; ControlVariables_m.ConfBrd_LeadCreditIndicator_Index(2:end)-ControlVariables_m.ConfBrd_LeadCreditIndicator_Index(1:end-1)];
ControlVariablesRx_m.ConfBrd_InitJoblClaimsWkly_Index = [NaN; ControlVariables_m.ConfBrd_InitJoblClaimsWkly_Index(2:end)-ControlVariables_m.ConfBrd_InitJoblClaimsWkly_Index(1:end-1)];
ControlVariablesRx_m.ConfBrd_EmploymentTrend_Index = [NaN; ControlVariables_m.ConfBrd_EmploymentTrend_Index(2:end)-ControlVariables_m.ConfBrd_EmploymentTrend_Index(1:end-1)];

ControlVariablesRx_m.Bloomberg_EconBusCycleSurpr_Index = [NaN; ControlVariables_m.Bloomberg_EconBusCycleSurpr_Index(2:end)-ControlVariables_m.Bloomberg_EconBusCycleSurpr_Index(1:end-1)]./100;
ControlVariablesRx_m.MktRf = ControlVariables_m.MktRf./100;
ControlVariablesRx_m.Smb = ControlVariables_m.Smb./100;
ControlVariablesRx_m.Hml = ControlVariables_m.Hml./100;
ControlVariablesRx_m.Rf = ControlVariables_m.Rf./100;
ControlVariablesRx_m.Umd = ControlVariables_m.Umd./100;


summary(ControlVariablesRx_m)


%merge
[tmpYear,tmpMonth,tmpDay] = Convert_yyyymmdd(Advanta_ABCMT_Mat.Date_m);
tmpTbl = Advanta_ABCMT_Mat;
tmpTbl.Date = datetime(tmpYear,tmpMonth,tmpDay);
tmpTbl = table2timetable(tmpTbl,'RowTimes','Date');
file03_AdvantaRx_ControlsRx = outerjoin(tmpTbl,ControlVariablesRx_m,'Type','left');
file03_AdvantaRx_ControlsRx = movevars(file03_AdvantaRx_ControlsRx, ["Long_Comp_Name_Txt","Ticker_Txt","Series_Txt","Class_Txt","CUSIP_Txt"],'After',width(file03_AdvantaRx_ControlsRx));
file03_AdvantaRx_ControlsLevels = outerjoin(tmpTbl,ControlVariables_m,'Type','left');
file03_AdvantaRx_ControlsLevels = movevars(file03_AdvantaRx_ControlsLevels, ["Long_Comp_Name_Txt","Ticker_Txt","Series_Txt","Class_Txt","CUSIP_Txt"],'After',width(file03_AdvantaRx_ControlsLevels));


%format output
file03_AdvantaRx_ControlsRx.Date_yyyymm = [];
file03_AdvantaRx_ControlsLevels.Date_yyyymm = [];
file03_AdvantaRx_ControlsRx.Is_Junior = [];
file03_AdvantaRx_ControlsLevels.Is_Junior = [];
file03_AdvantaRx_ControlsRx = sortrows(file03_AdvantaRx_ControlsRx,["ID_Num","Date"]);
file03_AdvantaRx_ControlsLevels = sortrows(file03_AdvantaRx_ControlsLevels,["ID_Num","Date"]);


%write to csv
tmpTbl = timetable2table(file03_AdvantaRx_ControlsLevels,'ConvertRowTimes',false);
tmpTbl(:,1:58) = fillmissing(tmpTbl(:,1:58),'constant',-999);
writetable(tmpTbl,'file03_AdvantaRx_ControlsLevels.csv')
tmpTbl = timetable2table(file03_AdvantaRx_ControlsRx,'ConvertRowTimes',false);
tmpTbl(:,1:58) = fillmissing(tmpTbl(:,1:58),'constant',-999);
writetable(tmpTbl,'file03_AdvantaRx_ControlsRx.csv')


%save
filePath = "E:\Dropbox\Work\Research\BusinessCardABS\Data\Controlvariables\";
%filePath ="C:\Users\mflec\Dropbox\Work\Research\BusinessCardABS\Data\Controlvariables\";
fileName = "file03_CleanupPanelDataset.mat";
save(strcat(filePath,fileName),'ControlVariablesRx_m','ControlVariables_m',...
    'file03_AdvantaRx_ControlsLevels','file03_AdvantaRx_ControlsRx')






clear; clc;

filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file01_CreatePanelDataset.mat";
load(strcat(filePath,fileName))

tmpTbl = Advanta_ABCMT_Tbl;

%delete observations prior to and after issue date
noRows = length(tmpTbl.Date);
indRemove = zeros(noRows,1);
for rowSelect=1:noRows
   
    currDate = tmpTbl.Date(rowSelect);
    currIssDate = tmpTbl.Issued(rowSelect);
    currMatDate = tmpTbl.Maturity(rowSelect);
    
    if currDate < currIssDate || currDate > currMatDate
        indRemove(rowSelect)=1;
    end
        
end
%delete all rows where "Include" variable is 0
for rowSelect=1:noRows
   
    if tmpTbl.Include(rowSelect)==0
        indRemove(rowSelect)=1;
    end
        
end
%delete all rows where "Px_Last" is missing
for rowSelect=1:noRows
   
    if isnan(tmpTbl.Px_Last(rowSelect))
        indRemove(rowSelect)=1;
    end
        
end

%delete all rows where "Cpn_ActAct" cannot be computed, this happens when
%no swap available to swap into fixed. Must be deleted because the Treasury
%pricee is computed even though the coupon rate is NaN
for rowSelect=1:noRows
   
    if isnan(tmpTbl.CpnSwapped_ActAct(rowSelect))
        indRemove(rowSelect)=1;
    end
        
end

%make deletions
tmpTbl = tmpTbl(indRemove==0,:);
Advanta_ABCMT_Tbl = tmpTbl;
clearvars tmpTbl



%% add column is_Junior
noRows = length(Advanta_ABCMT_Tbl.Date);
Advanta_ABCMT_Tbl.Is_Junior = NaN(noRows,1);
for rowSelect=1:noRows
    currClass = Advanta_ABCMT_Tbl.Class(rowSelect);
    if currClass == "A" || currClass == "B" || currClass == "C"
        Advanta_ABCMT_Tbl.Is_Junior(rowSelect) = 0;
    elseif currClass == "D"
        Advanta_ABCMT_Tbl.Is_Junior(rowSelect) = 1;
    end
end


%% calculate subordination


tmpTimeTbl = Advanta_ABCMT_Tbl;
tmpTimeTbl.Attach_Pct = NaN(height(tmpTimeTbl),1);
tmpTimeTbl.Detach_Pct = NaN(height(tmpTimeTbl),1);
for dateSelect=1:length(tmpTimeTbl.Date)
    
    
    currClass = tmpTimeTbl.Class(dateSelect);
    
    if currClass == "A"
        tmpTimeTbl.Attach_Pct(dateSelect) = 21.5805/100;
        tmpTimeTbl.Detach_Pct(dateSelect) = 1.00;
    elseif currClass == "B"
        tmpTimeTbl.Attach_Pct(dateSelect) = 8.9918/100;
        tmpTimeTbl.Detach_Pct(dateSelect) = 21.5805/100;
    elseif currClass == "C"
        tmpTimeTbl.Attach_Pct(dateSelect) = 3.6269/100;
        tmpTimeTbl.Detach_Pct(dateSelect) = 8.9918/100;
    elseif currClass == "D"
        tmpTimeTbl.Attach_Pct(dateSelect) = 0.0; 
        tmpTimeTbl.Detach_Pct(dateSelect) = 3.6269/100;
    end
            
end
Advanta_ABCMT_Tbl = tmpTimeTbl;


Advanta_ABCMT_Tbl = movevars(Advanta_ABCMT_Tbl,{'Long_Comp_Name','Ticker','Series','Class','Is_Junior',...
    'PxDatetime','MonthsToExpMat','Less1yrToExpMat',...
    'Mtg_Hist_Portf_Yld','Px_Last','Mtg_Hist_Exs_1m',...
    'Mtg_Hist_Charge_Off_1mo','Mtg_Hist_Charge_Off_3mo','Card_Mpr','Hist_Losses','Hist_Interest_Distributed','Hist_Interest_Shortfall','Hist_Principal_Distributed',...
    'Attach_Pct','Detach_Pct','Cpn','Cpn_Typ','Cpn_Freq','Flt_Spread','Reset_Idx','Day_Cnt_Des',...
    'Swap','Cpn_ActAct','Flt_Spread_ActAct','CpnSwapped_ActAct','AccrInt_ActAct','PxFull_Last',...
    'Mtg_Hist_Cpn','Orig_Amt',...
    'Issued','Issue_Px','Maturity','Par_Amt','Mtg_Exp_Mty_Dt',...
    'Mtg_Deal_Name','Name','Mtg_Cmo_Series','Mtg_Cmo_Class','Var','Px_TreasDisc','DeltaPxTreas'},'Before',1);

Advanta_ABCMT_Tbl.Sub_Pct = [];


%% Supplement with 2019 data download

load("E:\Dropbox\Work\Research\CreditCardABS\Analysis\CreateDataSets\MatOutput\CCAbsPanel.mat")
%load("C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Analysis\CreateDataSets\MatOutput\CCAbsPanel.mat")

CCAbsPanel_m = table2timetable(CCAbsPanel_m,'RowTimes',CCAbsPanel_m.date);
CCAbsPanel_m.Properties.DimensionNames(1) = {'Date'};
CCAbsPanel_m.BB_ID = strrep(upper(strrep(CCAbsPanel_m.bbid,"bbid_","!!")),"MTGE"," Mtge");

tmpCnt =  0;
for dateSelect=1:height(Advanta_ABCMT_Tbl)
    
    currDate = Advanta_ABCMT_Tbl.Date(dateSelect);
    currBBID = Advanta_ABCMT_Tbl.BB_ID(dateSelect);
    currMPR = Advanta_ABCMT_Tbl.Card_Mpr(dateSelect);
    currLosses = Advanta_ABCMT_Tbl.Hist_Losses(dateSelect);
    currChargeOff1m = Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo(dateSelect);
    currExcessSpread = Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m(dateSelect);
    currPortfYield = Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld(dateSelect);
    
    
    %lookup old data
    idx = find(CCAbsPanel_m.Date == currDate & CCAbsPanel_m.BB_ID == currBBID);
    if ~isempty(idx)
        lookupMPR = CCAbsPanel_m.card_mpr(idx);
        lookupLosses = CCAbsPanel_m.hist_losses(idx);
        lookupChargeOff1m = CCAbsPanel_m.mtg_hist_charge_off_1mo(idx);
        lookupExcessSpread = CCAbsPanel_m.mtg_hist_exs_1m(idx);
        lookupPortfYield = CCAbsPanel_m.mtg_hist_portf_yld(idx);
        
        if ismissing(currMPR) && ~ismissing(lookupMPR)
            Advanta_ABCMT_Tbl.Card_Mpr(dateSelect) = lookupMPR;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currLosses) && ~ismissing(lookupLosses)
            Advanta_ABCMT_Tbl.Hist_Losses(dateSelect) = lookupLosses;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currChargeOff1m) && ~ismissing(lookupChargeOff1m)
            Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo(dateSelect) = lookupChargeOff1m;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currExcessSpread) && ~ismissing(lookupExcessSpread)
            Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m(dateSelect) = lookupExcessSpread;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currPortfYield) && ~ismissing(lookupPortfYield)
            Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld(dateSelect) = lookupPortfYield;
            tmpCnt = tmpCnt + 1;
        end
    end
    
end
sprintf('== Additional observations added: %d ==\n',tmpCnt)


Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld(1) = Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld(1);
Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m(1:2) = Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m(3);
Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo(2) = Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo(3);
Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_3mo(1) = Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_3mo(1);
Advanta_ABCMT_Tbl.Card_Mpr(2) = Advanta_ABCMT_Tbl.Card_Mpr(1);
Advanta_ABCMT_Tbl.Hist_Losses(1:3) = Advanta_ABCMT_Tbl.Hist_Losses(3);


%% Fill missing observations
% Socialized structure, means that Mtg_Hist_Portf_Yld, Mtg_Hist_Exs_1m,
% Mtg_Hist_Charge_Off_1mo, Mtg_Hist_Charge_Off_3mo, Card_Mpr are the same
% for all series and classes each month

tmpTbl = groupsummary(Advanta_ABCMT_Tbl,"Date",["mean","min","max"],...
    ["Mtg_Hist_Portf_Yld","Mtg_Hist_Exs_1m","Mtg_Hist_Charge_Off_1mo",...
    "Mtg_Hist_Charge_Off_3mo","Card_Mpr","Hist_Losses"]);
tmpTbl = table2timetable(tmpTbl,'RowTimes','Date');

tmpCnt =  0;
for dateSelect=1:height(Advanta_ABCMT_Tbl)
    
    currDate = Advanta_ABCMT_Tbl.Date(dateSelect);
    currBBID = Advanta_ABCMT_Tbl.BB_ID(dateSelect);
    currMPR = Advanta_ABCMT_Tbl.Card_Mpr(dateSelect);
    currLosses = Advanta_ABCMT_Tbl.Hist_Losses(dateSelect);
    currChargeOff1m = Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo(dateSelect);
    currChargeOff3m = Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_3mo(dateSelect);
    currExcessSpread = Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m(dateSelect);
    currPortfYield = Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld(dateSelect);
    
    
    %lookup 
        lookupMPR = tmpTbl{currDate,'mean_Card_Mpr'};
        lookupLosses = tmpTbl{currDate,'mean_Hist_Losses'};
        lookupChargeOff1m = tmpTbl{currDate,'mean_Mtg_Hist_Charge_Off_1mo'};
        lookupChargeOff3m = tmpTbl{currDate,'mean_Mtg_Hist_Charge_Off_3mo'};
        lookupExcessSpread = tmpTbl{currDate,'mean_Mtg_Hist_Exs_1m'};
        lookupPortfYield = tmpTbl{currDate,'mean_Mtg_Hist_Portf_Yld'};
        
        if ismissing(currMPR) && ~ismissing(lookupMPR)
            Advanta_ABCMT_Tbl.Card_Mpr(dateSelect) = lookupMPR;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currLosses) && ~ismissing(lookupLosses)
            Advanta_ABCMT_Tbl.Hist_Losses(dateSelect) = lookupLosses;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currChargeOff1m) && ~ismissing(lookupChargeOff1m)
            Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo(dateSelect) = lookupChargeOff1m;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currChargeOff3m) && ~ismissing(lookupChargeOff3m)
            Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_3mo(dateSelect) = lookupChargeOff3m;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currExcessSpread) && ~ismissing(lookupExcessSpread)
            Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m(dateSelect) = lookupExcessSpread;
            tmpCnt = tmpCnt + 1;
        end
        
        if ismissing(currPortfYield) && ~ismissing(lookupPortfYield)
            Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld(dateSelect) = lookupPortfYield;
            tmpCnt = tmpCnt + 1;
        end
    
end
sprintf('== Additional observations added: %d ==\n',tmpCnt)



%%


%write to Excel
tmpTbl = timetable2table(Advanta_ABCMT_Tbl,'ConvertRowTimes',true);
tmpTbl.Date = datestr(Advanta_ABCMT_Tbl.Date);
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file02_Advanta_ABCMT.xlsx";
writetable(tmpTbl,strcat(filePath,fileName));

%save
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file02_CleanupPanelDataset.mat";
save(strcat(filePath,fileName),'Advanta_ABCMT_Tbl')




%% File Format for Fortran

%Note: 1XXX denotes ABCMT, 2XXX a different master trust etc.


Advanta_ABCMT_Mat = Advanta_ABCMT_Tbl(:,{'Number'});
Advanta_ABCMT_Mat.Date_m = year(Advanta_ABCMT_Tbl.Date)*100+month(Advanta_ABCMT_Tbl.Date);
Advanta_ABCMT_Mat.ID_Num = Advanta_ABCMT_Mat.Number + 1000;
Advanta_ABCMT_Mat.Series = grp2idx(Advanta_ABCMT_Tbl.Series);
Advanta_ABCMT_Mat.Class = NaN(length(Advanta_ABCMT_Tbl.Reset_Idx),1);
for rowSelect=1:length(Advanta_ABCMT_Tbl.Class)
    currClass = Advanta_ABCMT_Tbl.Class(rowSelect);
    if currClass ==  "A" 
        Advanta_ABCMT_Mat.Class(rowSelect) = 1;
    elseif currClass ==  "B"
        Advanta_ABCMT_Mat.Class(rowSelect) = 2;
    elseif currClass ==  "C"
        Advanta_ABCMT_Mat.Class(rowSelect) = 3;
    elseif currClass ==  "D"
        Advanta_ABCMT_Mat.Class(rowSelect) = 4;
    end
end
Advanta_ABCMT_Mat.Is_Junior = Advanta_ABCMT_Tbl.Is_Junior;
Advanta_ABCMT_Mat.PxDate = year(Advanta_ABCMT_Tbl.PxDatetime)*10000+month(Advanta_ABCMT_Tbl.PxDatetime)*100+...
    day(Advanta_ABCMT_Tbl.PxDatetime);
Advanta_ABCMT_Mat.MonthsToExpMat = Advanta_ABCMT_Tbl.MonthsToExpMat;
Advanta_ABCMT_Mat.Less1yrToExpMat = Advanta_ABCMT_Tbl.Less1yrToExpMat;
Advanta_ABCMT_Mat.Attach_Pct = Advanta_ABCMT_Tbl.Attach_Pct;
Advanta_ABCMT_Mat.Detach_Pct = Advanta_ABCMT_Tbl.Detach_Pct;


Advanta_ABCMT_Mat.IssueDate = year(Advanta_ABCMT_Tbl.Issued)*100+month(Advanta_ABCMT_Tbl.Issued);
Advanta_ABCMT_Mat.Maturity_Exp = year(Advanta_ABCMT_Tbl.Mtg_Exp_Mty_Dt)*100+month(Advanta_ABCMT_Tbl.Mtg_Exp_Mty_Dt);
Advanta_ABCMT_Mat.Maturity_Contr = year(Advanta_ABCMT_Tbl.Maturity)*100+month(Advanta_ABCMT_Tbl.Maturity);
Advanta_ABCMT_Mat.Par_Amt = Advanta_ABCMT_Tbl.Par_Amt;
Advanta_ABCMT_Mat.Float_Ind = NaN(length(Advanta_ABCMT_Tbl.Reset_Idx),1);
Advanta_ABCMT_Mat.Float_Index = NaN(length(Advanta_ABCMT_Tbl.Reset_Idx),1);
for rowSelect=1:length(Advanta_ABCMT_Tbl.Reset_Idx)
    currReset_Idx = Advanta_ABCMT_Tbl.Reset_Idx(rowSelect);
    if currReset_Idx ==  "US0001M" 
        Advanta_ABCMT_Mat.Float_Index(rowSelect) = 1;
        Advanta_ABCMT_Mat.Float_Ind(rowSelect) = 1;
    elseif currReset_Idx ==  "US0003M"
        Advanta_ABCMT_Mat.Float_Index(rowSelect) = 3;
        Advanta_ABCMT_Mat.Float_Ind(rowSelect) = 1;
    else 
        Advanta_ABCMT_Mat.Float_Index(rowSelect) = 0;
        Advanta_ABCMT_Mat.Float_Ind(rowSelect) = 0;
    end
end
Advanta_ABCMT_Mat.Coupon = Advanta_ABCMT_Tbl.Cpn_ActAct;
Advanta_ABCMT_Mat.Coupon_Freq = Advanta_ABCMT_Tbl.Cpn_Freq;
Advanta_ABCMT_Mat.Spread = Advanta_ABCMT_Tbl.Flt_Spread_ActAct;
Advanta_ABCMT_Mat.Swap_ToFixedRate = Advanta_ABCMT_Tbl.Swap;
Advanta_ABCMT_Mat.CpnSwapped = Advanta_ABCMT_Tbl.CpnSwapped_ActAct;
Advanta_ABCMT_Mat.AccrInt = Advanta_ABCMT_Tbl.AccrInt_ActAct;
Advanta_ABCMT_Mat.Price = Advanta_ABCMT_Tbl.Px_Last;
Advanta_ABCMT_Mat.PriceFull = Advanta_ABCMT_Tbl.PxFull_Last;
Advanta_ABCMT_Mat.MPR = Advanta_ABCMT_Tbl.Card_Mpr;
Advanta_ABCMT_Mat.Yield = Advanta_ABCMT_Tbl.Mtg_Hist_Portf_Yld;
Advanta_ABCMT_Mat.Excess_Spread = Advanta_ABCMT_Tbl.Mtg_Hist_Exs_1m;
Advanta_ABCMT_Mat.Losses = Advanta_ABCMT_Tbl.Hist_Losses;
Advanta_ABCMT_Mat.ChargeOff_1m =  Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_1mo;
Advanta_ABCMT_Mat.ChargeOff_3m = Advanta_ABCMT_Tbl.Mtg_Hist_Charge_Off_3mo;
Advanta_ABCMT_Mat.Number = [];
Advanta_ABCMT_Mat = timetable2table(Advanta_ABCMT_Mat,'ConvertRowTimes',false);
Advanta_ABCMT_Mat = fillmissing(Advanta_ABCMT_Mat,'constant',-999);
%Text data
Advanta_ABCMT_Mat.Long_Comp_Name_Txt = Advanta_ABCMT_Tbl.Long_Comp_Name;
Advanta_ABCMT_Mat.Ticker_Txt = Advanta_ABCMT_Tbl.Ticker;
Advanta_ABCMT_Mat.Series_Txt = Advanta_ABCMT_Tbl.Series;
Advanta_ABCMT_Mat.Class_Txt = Advanta_ABCMT_Tbl.Class;
Advanta_ABCMT_Mat.CUSIP_Txt = Advanta_ABCMT_Tbl.ID_Cusip;
%helper columns
Advanta_ABCMT_Mat.Px_TreasDisc = Advanta_ABCMT_Tbl.Px_TreasDisc;
Advanta_ABCMT_Mat.DeltaPxTreas = Advanta_ABCMT_Tbl.DeltaPxTreas;


%replace missing with -999
Advanta_ABCMT_Mat(:,1:30) = fillmissing(Advanta_ABCMT_Mat(:,1:30),'constant',-999);
Advanta_ABCMT_Mat(:,36:37) = fillmissing(Advanta_ABCMT_Mat(:,36:37),'constant',-999);

%save
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file02_CleanupPanelDataset.mat";
save(strcat(filePath,fileName),'Advanta_ABCMT_Tbl','Advanta_ABCMT_Mat')


%write to Excel
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file02_Advanta_ABCMT_Mat.csv";
writetable(Advanta_ABCMT_Mat,strcat(filePath,fileName));




%%
% 1.	For each Issuer, for each month: Have one row for each
% separate C tranche. So if only one C tranche, then just one
% row for that month. If 10 C tranches, then 10 rows. For each
% of these rows, if there is a matching A and B tranche, include
% that information. We will use that to validate our extrapolation
% method. If there is no exactly matching A and B tranche, then
% just put in  -999s.
% 
% 2.	For months with no C tranche, then go first to A tranches. For 
% each A tranche, find the B tranche with a maturity within one
% month. So if 20 A tranches, we have 20 rows for that month. No
% redundancies. Of course, the C tranche info will be -999 for that
% month.


%NOTE: THIS IS A SPECIAL CASE, WE CAN ONLY USE A/B BECAUSE THERE IS D CLASS
%AND WE HAVE NO DATA ON D
tmpTbl = table2timetable(Advanta_ABCMT_Mat,'RowTimes',Advanta_ABCMT_Tbl.Date);
tmpTbl.ID_Num = [];
tmpTbl.Properties.DimensionNames(1) = {'Date'};
tmpTbl = standardizeMissing(tmpTbl,-999);
tmpTblIdxClassA = (tmpTbl.Class_Txt=="A");
tmpTblIdxClassB = (tmpTbl.Class_Txt=="B");
tmpTblIdxClassC = (tmpTbl.Class_Txt=="D");
tmpTbl_A = tmpTbl(tmpTblIdxClassA,:);
tmpTbl_B = tmpTbl(tmpTblIdxClassB,:);
tmpTbl_C = tmpTbl(tmpTblIdxClassC,:);


%rename variables
%Note: here we use C_ but is actuallt class D, to be consistent with the
%notion of equity tranche
tmpTbl_A.Properties.VariableNames = strcat("A_",string(tmpTbl_A.Properties.VariableNames));
tmpTbl_B.Properties.VariableNames = strcat("B_",string(tmpTbl_B.Properties.VariableNames));
tmpTbl_C.Properties.VariableNames = strcat("C_",string(tmpTbl_C.Properties.VariableNames));


%join tables
tmpTbl_AB = outerjoin(tmpTbl_A,tmpTbl_B,...
    'LeftKeys',{'Date','A_Ticker_Txt'},'RightKeys',{'Date','B_Ticker_Txt'},...
    'MergeKeys',true,'Type','left');
tmpTbl_AB.Properties.VariableNames("A_Ticker_Txt_B_Ticker_Txt") = "Ticker_Txt";
%remove missing datarows
idxMiss_MPR = ismissing(tmpTbl_AB.A_MPR) & ismissing(tmpTbl_AB.B_MPR);
tmpTbl_AB = tmpTbl_AB(~idxMiss_MPR,:);
idxMiss_Yield = ismissing(tmpTbl_AB.A_Yield) & ismissing(tmpTbl_AB.B_Yield);
tmpTbl_AB = tmpTbl_AB(~idxMiss_Yield,:);
idxMiss_ExcessSpread = ismissing(tmpTbl_AB.A_Excess_Spread) & ismissing(tmpTbl_AB.B_Excess_Spread);
tmpTbl_AB = tmpTbl_AB(~idxMiss_ExcessSpread,:);
%calculate difference in months to maturity for AB
tmpTbl_AB.Delta_MonthsToMaturity_AB = abs(tmpTbl_AB.A_MonthsToExpMat-tmpTbl_AB.B_MonthsToExpMat);
%drop those that have exp. maturity dates more than one month apart
idxLessOneMonth = (tmpTbl_AB.Delta_MonthsToMaturity_AB<=1);
tmpTbl_AB = tmpTbl_AB(idxLessOneMonth,:);
%get min difference by date and A series
[g,grp]=findgroups(tmpTbl_AB.Date,tmpTbl_AB.A_Series);
[mn,mix]=splitapply(@(idx) minbygroup(tmpTbl_AB.Delta_MonthsToMaturity_AB(idx),idx),[1:height(tmpTbl_AB)].',g);
tmpTbl_AB = tmpTbl_AB(mix,:);
tmpTbl_AB.Delta_MonthsToMaturity_AB = [];

%merge with C. Note: full outer, because we can use C without A+B
tmpTbl_ABC = outerjoin(tmpTbl_AB,tmpTbl_C,...
    'LeftKeys',{'Date','Ticker_Txt'},'RightKeys',{'Date','C_Ticker_Txt'},...
    'MergeKeys',true,'Type','full');
tmpTbl_ABC.Properties.VariableNames("Ticker_Txt_C_Ticker_Txt") = "Ticker_Txt";

%drop rows with missing
idxMiss_MPR = ismissing(tmpTbl_ABC.A_MPR) & ismissing(tmpTbl_ABC.B_MPR) & ismissing(tmpTbl_ABC.C_MPR);
tmpTbl_ABC = tmpTbl_ABC(~idxMiss_MPR,:);
idxMiss_Yield = ismissing(tmpTbl_ABC.A_Yield) & ismissing(tmpTbl_ABC.B_Yield) & ismissing(tmpTbl_ABC.C_Yield);
tmpTbl_ABC = tmpTbl_ABC(~idxMiss_Yield,:);
idxMiss_ExcessSpread = ismissing(tmpTbl_ABC.A_Excess_Spread) & ismissing(tmpTbl_ABC.B_Excess_Spread) & ismissing(tmpTbl_ABC.C_Excess_Spread);
tmpTbl_ABC = tmpTbl_ABC(~idxMiss_ExcessSpread,:);








%Drop Class names (i.e. A,B,C)
tmpTbl_ABC.A_Class_Txt = [];
tmpTbl_ABC.B_Class_Txt = [];
tmpTbl_ABC.C_Class_Txt = [];
tmpTbl_ABC.A_Class = [];
tmpTbl_ABC.B_Class = [];
tmpTbl_ABC.C_Class = [];
tmpTbl_ABC.Properties.VariableNames("A_Series") = "Series";
tmpTbl_ABC.Properties.VariableNames("A_Series_Txt") = "Series_Txt";
tmpTbl_ABC.B_Series = [];
tmpTbl_ABC.C_Series = [];
tmpTbl_ABC.B_Series_Txt = [];
tmpTbl_ABC.C_Series_Txt = [];
tmpTbl_ABC.Properties.VariableNames("A_Long_Comp_Name_Txt") = "Long_Comp_Name_Txt";
tmpTbl_ABC.B_Long_Comp_Name_Txt = [];
tmpTbl_ABC.C_Long_Comp_Name_Txt = [];




%get averages across A,B,C
tmpTbl_ABC.MPR = mean([tmpTbl_ABC.A_MPR tmpTbl_ABC.B_MPR tmpTbl_ABC.C_MPR],2,'omitnan');
tmpTbl_ABC.Yield = mean([tmpTbl_ABC.A_Yield tmpTbl_ABC.B_Yield tmpTbl_ABC.C_Yield],2,'omitnan');
tmpTbl_ABC.Excess_Spread = mean([tmpTbl_ABC.A_Excess_Spread tmpTbl_ABC.B_Excess_Spread tmpTbl_ABC.C_Excess_Spread],2,'omitnan');
tmpTbl_ABC.Losses = mean([tmpTbl_ABC.A_Losses tmpTbl_ABC.B_Losses tmpTbl_ABC.C_Losses],2,'omitnan');
tmpTbl_ABC.ChargeOff_1m = mean([tmpTbl_ABC.A_ChargeOff_1m tmpTbl_ABC.B_ChargeOff_1m tmpTbl_ABC.C_ChargeOff_1m],2,'omitnan');
tmpTbl_ABC.ChargeOff_3m = mean([tmpTbl_ABC.A_ChargeOff_3m tmpTbl_ABC.B_ChargeOff_3m tmpTbl_ABC.C_ChargeOff_3m],2,'omitnan');
%drop A,B,C variables
tmpTbl_ABC(:,["A_MPR","B_MPR","C_MPR"]) =  [];
tmpTbl_ABC(:,["A_Yield","B_Yield","C_Yield"]) =  [];
tmpTbl_ABC(:,["A_Excess_Spread","B_Excess_Spread","C_Excess_Spread"]) =  [];
tmpTbl_ABC(:,["A_Losses","B_Losses","C_Losses"]) =  [];
tmpTbl_ABC(:,["A_ChargeOff_1m","B_ChargeOff_1m","C_ChargeOff_1m"]) =  [];
tmpTbl_ABC(:,["A_ChargeOff_3m","B_ChargeOff_3m","C_ChargeOff_3m"]) =  [];
%order variables
tmpTbl_ABC = movevars(tmpTbl_ABC,["Series","MPR","Yield","Excess_Spread","Losses","ChargeOff_1m","ChargeOff_3m"],'Before',1);
tmpTbl_ABC = movevars(tmpTbl_ABC,["Long_Comp_Name_Txt","Series_Txt","Ticker_Txt","A_CUSIP_Txt","B_CUSIP_Txt","C_CUSIP_Txt"],'After',"C_PriceFull");
tmpTbl_ABC = movevars(tmpTbl_ABC,["A_Px_TreasDisc","A_DeltaPxTreas",...
    "B_Px_TreasDisc","B_DeltaPxTreas",...
    "C_Px_TreasDisc","C_DeltaPxTreas"],'Before',"Long_Comp_Name_Txt");

%make date yyyymm column
tmpTbl_ABC.Date_m = year(tmpTbl_ABC.Date)*100+month(tmpTbl_ABC.Date);
tmpTbl_ABC = movevars(tmpTbl_ABC,'Date_m','Before',1);
tmpTbl_ABC = timetable2table(tmpTbl_ABC,'ConvertRowTimes',false);

%recode missing values as -999
tmpTbl_ABC(:,1:77) = fillmissing(tmpTbl_ABC(:,1:77),'constant',-999);


%Final Output
Advanta_ABCMT_Mat2 = tmpTbl_ABC;
clear -regexp ^tmp

%save
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file02_CleanupPanelDataset.mat";
save(strcat(filePath,fileName),'Advanta_ABCMT_Tbl','Advanta_ABCMT_Mat','Advanta_ABCMT_Mat2')

%write to Excel
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file02_Advanta_ABCMT_Mat2.csv";
writetable(Advanta_ABCMT_Mat2,strcat(filePath,fileName));






%% get discount factors

load('E:\Dropbox\Work\Research\CreditCardABS\Analysis\CreateSwapsDataset\DT_Table_Matlab.mat')
tmpTbl = Advanta_ABCMT_Tbl(:,"PxDatetime");
tmpTbl = outerjoin(tmpTbl,DT_Table,'LeftKeys','PxDatetime','RightKeys','Date','MergeKeys',true,'Type','left');
tmpTbl.Date_m = year(tmpTbl.Date)*100+month(tmpTbl.Date);
tmpTbl.PxDate = year(tmpTbl.PxDatetime_Date)*10000+month(tmpTbl.PxDatetime_Date)*100+...
    day(tmpTbl.PxDatetime_Date);
tmpTbl.ID_Num = Advanta_ABCMT_Mat.ID_Num;
tmpTbl = movevars(tmpTbl,{'ID_Num','Date_m','PxDate'},'Before',1);
tmpTbl.PxDatetime_Date = [];
tmpTbl = timetable2table(tmpTbl,'ConvertRowTimes',false);
Advanta_ABCMT_DiscountFactors_Mat = tmpTbl;
clear tmpTbl;

%write to Excel
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file03_Advanta_ABCMT_DiscountFactors_Mat.csv";
writetable(Advanta_ABCMT_DiscountFactors_Mat,strcat(filePath,fileName));





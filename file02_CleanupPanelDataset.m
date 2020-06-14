
clear; clc;

filePath = "E:\Dropbox\Work\Research\BusinessCardABS\Analysis\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\\BusinessCardABS\Analysis\";
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
%delete all rows where "RxTotal_Notswapped" is missing
for rowSelect=1:noRows
   
    if isnan(tmpTbl.RxTotal_Notswapped(rowSelect))
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


Advanta_ABCMT_Tbl = movevars(Advanta_ABCMT_Tbl,{'Long_Comp_Name','Ticker','Series','Class','Number',...
    'Maturity','Mtg_Exp_Mty_Dt','MonthsToExpMat','Less1yrToExpMat','Attach_Pct','Detach_Pct',...
    'RxTotal_Notswapped','RxTotal_SwappedToFixed','RxTotal_TreasuryPrice'},'Before',1);



%% File Format for Fortran

%Note: 1XXX denotes ABCMT, 2XXX a different master trust etc.


Advanta_ABCMT_Mat = Advanta_ABCMT_Tbl(:,{'Number'});
Advanta_ABCMT_Mat.Date_m = year(Advanta_ABCMT_Tbl.Date)*10000+month(Advanta_ABCMT_Tbl.Date)*100+day(Advanta_ABCMT_Tbl.Date);
Advanta_ABCMT_Mat.Year = year(Advanta_ABCMT_Tbl.Date);
Advanta_ABCMT_Mat.Month = month(Advanta_ABCMT_Tbl.Date);
Advanta_ABCMT_Mat.ID_Num = Advanta_ABCMT_Mat.Number;
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
Advanta_ABCMT_Mat.MonthsToExpMat = Advanta_ABCMT_Tbl.MonthsToExpMat;
Advanta_ABCMT_Mat.Less1yrToExpMat = Advanta_ABCMT_Tbl.Less1yrToExpMat;
Advanta_ABCMT_Mat.Attach_Pct = Advanta_ABCMT_Tbl.Attach_Pct;
Advanta_ABCMT_Mat.Detach_Pct = Advanta_ABCMT_Tbl.Detach_Pct;
Advanta_ABCMT_Mat.Maturity_Exp = year(Advanta_ABCMT_Tbl.Mtg_Exp_Mty_Dt)*10000+month(Advanta_ABCMT_Tbl.Mtg_Exp_Mty_Dt)*100+day(Advanta_ABCMT_Tbl.Mtg_Exp_Mty_Dt);
Advanta_ABCMT_Mat.Maturity_Contr = year(Advanta_ABCMT_Tbl.Maturity)*10000+month(Advanta_ABCMT_Tbl.Maturity)*100+day(Advanta_ABCMT_Tbl.Maturity);
Advanta_ABCMT_Mat.RxTotal = Advanta_ABCMT_Tbl.RxTotal_Notswapped;
Advanta_ABCMT_Mat.RxTotal_SwappedToFixed = Advanta_ABCMT_Tbl.RxTotal_SwappedToFixed;
Advanta_ABCMT_Mat.RxTotal_TreasuryPrice = Advanta_ABCMT_Tbl.RxTotal_TreasuryPrice;

Advanta_ABCMT_Mat.Number = [];
Advanta_ABCMT_Mat = timetable2table(Advanta_ABCMT_Mat,'ConvertRowTimes',false);
Advanta_ABCMT_Mat = fillmissing(Advanta_ABCMT_Mat,'constant',-999);
%Text data
Advanta_ABCMT_Mat.Long_Comp_Name_Txt = Advanta_ABCMT_Tbl.Long_Comp_Name;
Advanta_ABCMT_Mat.Ticker_Txt = Advanta_ABCMT_Tbl.Ticker;
Advanta_ABCMT_Mat.Series_Txt = Advanta_ABCMT_Tbl.Series;
Advanta_ABCMT_Mat.Class_Txt = Advanta_ABCMT_Tbl.Class;
Advanta_ABCMT_Mat.CUSIP_Txt = Advanta_ABCMT_Tbl.ID_Cusip;


%remove returns on swapped and treasury-implied price
Advanta_ABCMT_Mat.RxTotal_SwappedToFixed = [];
Advanta_ABCMT_Mat.RxTotal_TreasuryPrice  = [];


%%

%save
filePath = "E:\Dropbox\Work\Research\BusinessCardABS\Analysis\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\BusinessCardABS\Analysis\";
fileName = "file02_CleanupPanelDataset.mat";
save(strcat(filePath,fileName),'Advanta_ABCMT_Tbl','Advanta_ABCMT_Mat')

%write to csv
fileName = "file02_Advanta_ABCMT_Mat.csv";
writetable(Advanta_ABCMT_Mat,strcat(filePath,fileName));







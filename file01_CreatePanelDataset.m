clear; clc;

%This file creates the panel dataset for Advanta


%% Import Card_Mpr

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);

% Specify sheet and range
opts.Sheet = "Card_Mpr";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Card_Mpr",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Card_Mpr")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Card_Mpr = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Card_Mpr);
end


%Note: data recorded as of the first of the month
%to make month-end data, set first of the month values to month-end values
BloombergBulkDataTable.Date = eomdate( BloombergBulkDataTable.Date - caldays(2));

Card_Mpr_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable


%% Import Hist_Interest_Distributed

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);


% Specify sheet and range
opts.Sheet = "Hist_Interest_Distributed";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Hist_Interest_Distributed",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Hist_Interest_Distributed")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Hist_Interest_Distributed = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Hist_Interest_Distributed);
end

%Note: interest distributed on the 15th of each month
%set month end-vaoue to the 15th in this case
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date);

Hist_Interest_Distributed_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable



%% Import Hist_Interest_Shortfall

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);


% Specify sheet and range
opts.Sheet = "Hist_Interest_Shortfall";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Hist_Interest_Shortfall",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Hist_Interest_Shortfall")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Hist_Interest_Shortfall = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Hist_Interest_Shortfall);
end

%Note: interest shortfall recorded on the 15th of each month
%set month end-value to the 15th in this case
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date);

Hist_Interest_Shortfall_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable




%% Import Hist_Principal_Distributed

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);


% Specify sheet and range
opts.Sheet = "Hist_Principal_Distributed";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Hist_Principal_Distributed",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Hist_Principal_Distributed")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Hist_Principal_Distributed = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Hist_Principal_Distributed);
end

%Note: principal distributed recorded on the 15th of each month
%set month end-value to the 15th in this case
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date);

Hist_Principal_Distributed_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable



%% Import Mtg_Hist_Cpn


numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);


% Specify sheet and range
opts.Sheet = "Mtg_Hist_Cpn";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Mtg_Hist_Cpn",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Mtg_Hist_Cpn")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Mtg_Hist_Cpn = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Mtg_Hist_Cpn);
end

%Note: historical coupon rates recorded on the 15th of each month
%set month end-value to the 15th in this case
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date);

Mtg_Hist_Cpn_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable



%% Import Hist_Losses


numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);


% Specify sheet and range
opts.Sheet = "Hist_Losses";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Hist_Losses",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Hist_Losses")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Hist_Losses = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Hist_Losses);
end

%Note: historical losses recorded on the 15th of each month
%set month end-value to the 15th in this case
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date);

Hist_Losses_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable



%% Import Mtg_Hist_Charge_Off_1mo


numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);


% Specify sheet and range
opts.Sheet = "Mtg_Hist_Charge_Off_1mo";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Mtg_Hist_Charge_Off_1mo",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Mtg_Hist_Charge_Off_1mo")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Mtg_Hist_Charge_Off_1mo = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Mtg_Hist_Charge_Off_1mo);
end

%Note: historical charge-offs recorded on the 1st of each month
%set month-end value of prior month to the value on the first
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date - caldays(2));

Mtg_Hist_Charge_Off_1mo_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable



%% Import Mtg_Hist_Charge_Off_3mo

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);

% Specify sheet and range
opts.Sheet = "Mtg_Hist_Charge_Off_3mo";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Mtg_Hist_Charge_Off_3mo",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Mtg_Hist_Charge_Off_3mo")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Mtg_Hist_Charge_Off_3mo = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Mtg_Hist_Charge_Off_3mo);
end

%Note: historical charge-offs recorded on the 1st of each month
%set month-end value of prior month to the value on the first
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date - caldays(2));

Mtg_Hist_Charge_Off_3mo_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable


%% Import Mtg_Hist_Exs_1m

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);

% Specify sheet and range
opts.Sheet = "Mtg_Hist_Exs_1m";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Mtg_Hist_Exs_1m",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Mtg_Hist_Exs_1m")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Mtg_Hist_Exs_1m = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Mtg_Hist_Exs_1m);
end

%Note: historical charge-offs recorded on the 1st of each month
%set month-end value of prior month to the value on the first
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date - caldays(2));

Mtg_Hist_Exs_1m_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable




%% Import Mtg_Hist_Portf_Yld

numColumns = 134;
numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numColumns);

% Specify sheet and range
opts.Sheet = "Mtg_Hist_Portf_Yld";
opts.DataRange = "A3:ED50";
% Specify column names and types
varTypes = repmat(["datetime", "double"],1,numVariables);
varNames = strings(1,numColumns);
for idx = 1:numColumns
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = varNames;
opts.VariableTypes = varTypes;

for idx = 1:2:numColumns
    opts = setvaropts(opts, varNames(idx), "InputFormat", "");
end


% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";
BloombergBulkData = readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear filePath fileName opts varNames varTypes idx


%separate dates and data
tmpDatesTbl = BloombergBulkData(:,1:2:end-1);
tmpDatesTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpDatesTblStacked = stack(tmpDatesTbl,tmpDatesTbl.Properties.VariableNames,...
    'NewDataVariableName',"Date",'IndexVariableName',"Var");

tmpValsTbl = BloombergBulkData(:,2:2:end);
tmpValsTbl.Properties.VariableNames = join([repmat("v",numVariables,1) transpose(1:numVariables)],"_");
tmpValsTblStacked = stack(tmpValsTbl,tmpValsTbl.Properties.VariableNames,...
    'NewDataVariableName',"Mtg_Hist_Portf_Yld",'IndexVariableName',"Var");

%concate Tables
BloombergBulkDataTable = [tmpDatesTblStacked tmpValsTblStacked(:,"Mtg_Hist_Portf_Yld")];
BloombergBulkDataTable = table2timetable(BloombergBulkDataTable,'RowTimes','Date');
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
idxMiss = ismissing(BloombergBulkDataTable.Date);
BloombergBulkDataTable = BloombergBulkDataTable(~idxMiss,:);
BloombergBulkDataTable = sortrows(BloombergBulkDataTable,{'Var','Date'});
BloombergBulkDataTable.Var = string(BloombergBulkDataTable.Var);

%empty data, set arbitrary date
if isempty(BloombergBulkDataTable)
    Date = datetime({'12/31/1995'});
    Var  = join([repmat("v",1,1) transpose(1:1)],"_");
    Mtg_Hist_Portf_Yld = NaN;
    BloombergBulkDataTable = timetable(Date,Var,Mtg_Hist_Portf_Yld);
end

%Note: historical charge-offs recorded on the 1st of each month
%set month-end value of prior month to the value on the first
BloombergBulkDataTable.Date = eomdate(BloombergBulkDataTable.Date - caldays(2));

Mtg_Hist_Portf_Yld_Table = BloombergBulkDataTable;

clear tmpDatesTbl tmpValsTblStacked BloombergBulkData BloombergBulkDataTable





%% Import Specs
numVariables = 67;
numSpecs = 42;
opts = spreadsheetImportOptions("NumVariables", numSpecs);

opts.Sheet = "BloombergFields";
opts.DataRange = "A2:AP68";

opts.VariableNames = ["Number", "BB_ID", "Ticker", "Series", "Class", "Type", "Cntr", "Sub_Sector", "Curr", "Maturity", "Issued", "Cpn", "Orig_Amt", "Private_Pl", "Include", "Sub_Pct", "Name", "Long_Comp_Name", "Mtg_Deal_Name", "Mtg_Cmo_Series", "Mtg_Cmo_Class", "Par_Amt", "Mtg_Deal_Orig_Face", "Mtg_Class_Deal_Pct_Orig", "Crncy", "Issue_Px", "Issue_Spread_Bnchmrk", "Mtg_Exp_Mty_Dt", "Mtg_Orig_Wal", "Day_Cnt_Des", "Cpn_Typ", "Cpn_Freq", "Flt_Spread", "Reset_Idx", "Original_Support_Pct", "Callable", "Mtg_Deal_Call_Pct", "Rtg_SP_Initial", "Rtg_Mdy_Initial", "Rtg_Fitch_Initial", "ID_Cusip", "Central_Index_Key_Number"];
opts.VariableTypes = ["double", "string", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "datetime", "datetime", "double", "double", "categorical", "double", "double", "string", "categorical", "categorical", "string", "categorical", "double", "double", "double", "categorical", "double", "categorical", "datetime", "double", "categorical", "categorical", "double", "double", "categorical", "double", "categorical", "double", "categorical", "categorical", "categorical", "string", "string"];
opts = setvaropts(opts, ["BB_ID", "Name", "Mtg_Cmo_Series", "ID_Cusip", "Central_Index_Key_Number"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["BB_ID", "Ticker", "Series", "Class", "Type", "Cntr", "Sub_Sector", "Curr", "Private_Pl", "Name", "Long_Comp_Name", "Mtg_Deal_Name", "Mtg_Cmo_Series", "Mtg_Cmo_Class", "Crncy", "Issue_Spread_Bnchmrk", "Day_Cnt_Des", "Cpn_Typ", "Reset_Idx", "Callable", "Rtg_SP_Initial", "Rtg_Mdy_Initial", "Rtg_Fitch_Initial", "ID_Cusip", "Central_Index_Key_Number"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Maturity", "InputFormat", "");
opts = setvaropts(opts, "Issued", "InputFormat", "");
opts = setvaropts(opts, "Mtg_Exp_Mty_Dt", "InputFormat", "");



filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "StaticAdvanta_ABCMT.xlsm";

BloombergSpecsDataTable = readtable(strcat(filePath,fileName), opts, "UseExcel", false);

%create variablenames
varNames = strings(1,numVariables);
for idx = 1:numVariables
    varNames(idx) = strcat("v_",num2str(idx));
end
BloombergSpecsDataTable.Var = transpose(varNames);

clear numSpecs numVariables opts


%convert spread and fixed coupon to act/act
BloombergSpecsDataTable.Cpn_ActAct = NaN(length(BloombergSpecsDataTable.Var),1);
BloombergSpecsDataTable.Flt_Spread_ActAct = NaN(length(BloombergSpecsDataTable.Var),1);
for rowSelect=1:length(BloombergSpecsDataTable.Var)
    currSpecs = BloombergSpecsDataTable(rowSelect,:);
    currDayCount = currSpecs.Day_Cnt_Des;
    currCpn = currSpecs.Cpn;
    currSpread = currSpecs.Flt_Spread;
    
    if currDayCount == "30/360(104)"
        BloombergSpecsDataTable.Cpn_ActAct(rowSelect) = currCpn;
        BloombergSpecsDataTable.Flt_Spread_ActAct(rowSelect) = currSpread;
    elseif currDayCount == "ACT/360(102)"
        BloombergSpecsDataTable.Cpn_ActAct(rowSelect) = currCpn.*365/360;
        BloombergSpecsDataTable.Flt_Spread_ActAct(rowSelect) = currSpread.*365/360;
    else
        BloombergSpecsDataTable.Cpn_ActAct(rowSelect) = currCpn;
        BloombergSpecsDataTable.Flt_Spread_ActAct(rowSelect) = currSpread;
    end
    
end


%% Import prices - daily


numVariables = 67;
opts = spreadsheetImportOptions("NumVariables", numVariables+1); %+1 for date column

% Specify sheet and range
opts.Sheet = "PxLast";
opts.DataRange = "A3:BP6567";
opts.Sheet = 'PxLast_Static';


varTypes = repmat("double",1,numVariables);
varNames = strings(1,numVariables);
for idx = 1:numVariables
    varNames(idx) = strcat("v_",num2str(idx));
end
opts.VariableNames = ["Date",varNames];
opts.VariableTypes = ["datetime", varTypes];

% Specify variable properties
opts = setvaropts(opts, varNames, "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Date", "InputFormat", "");

% Import the data
filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "Advanta_ABCMT_PxDaily.xlsx";
BloombergPriceDataTable =  readtable(strcat(filePath,fileName), opts, "UseExcel", false);
clear varTypes varNames opts numVariables

%to timetable
BloombergPriceDataTable = table2timetable(BloombergPriceDataTable,'RowTimes','Date');


%get accrued interest period fraction (i.e. number of days in accr. interest period divided by days in coupon period)
%also get date of price observation (this is used to look up the matching swap rate on the price observation date)
BloombergAccrDaysDataTable = BloombergPriceDataTable;
BloombergAccrDaysDataTable{:,:} = NaN;
BloombergPxObsDateTable = BloombergPriceDataTable;
BloombergPxObsDateTable{:,:} = NaN;
noVars  = length(BloombergAccrDaysDataTable.Properties.VariableNames);
noDates = length(BloombergAccrDaysDataTable.Date);
for varSelect=1:noVars
    for dateSelect=1:noDates
        currVar =  BloombergPriceDataTable.Properties.VariableNames(varSelect); 
        currPx  = BloombergPriceDataTable{dateSelect,varSelect};
        currDate = BloombergPriceDataTable.Date(dateSelect);
        currDateNum = datenum(currDate);
        if isnan(currPx)
            continue;
        else 
            idxCurrVar = BloombergSpecsDataTable.Var==currVar;
            currSpecs = BloombergSpecsDataTable(idxCurrVar,:);
            currMaturityDate = currSpecs.Maturity;
            currCpnFreq = currSpecs.Cpn_Freq;
            
            %%%%%%%% NOTE: BELOW IS CODE FOR THE SPECIFIED DAYCOUNT
            %%%%%%%% CONVENTION. BUT WE ARE CONVERTING EVERYTHING TO
            %%%%%%%% ACTUAL/ACTUAL, so the ACCR FRACT MUST BE
            %%%%%%%% CALCULATED USING ACT/ACT AS WELL.
            %currDayCount = currSpecs.Day_Cnt_Des;
            %if currDayCount == "30/360(104)"
            %    currBasis = 4;
            %elseif currDayCount == "ACT/360(102)"
            %    currBasis = 2; %actual/360
            %else
            %    currBasis = 0;
            %end
            %currAccrFract = accrfrac(currDate,currMaturityDate,currCpnFreq,currBasis);  
            %%%%%%%%
            currBasis = 0; %ACT/ACT
            currAccrFract = accrfrac(currDate,currMaturityDate,currCpnFreq,currBasis);  
            BloombergAccrDaysDataTable{currDate,currVar} = currAccrFract;
            BloombergPxObsDateTable{currDate,currVar} = currDateNum;
        end
    end
end

%to month-end prices
BloombergPriceDataTable_m = retime(BloombergPriceDataTable,'monthly','lastvalue');
BloombergPriceDataTable_m.Date = eomdate(year(BloombergPriceDataTable_m.Date),month(BloombergPriceDataTable_m.Date),'datetime');
BloombergPriceDataTable = BloombergPriceDataTable_m;

%to month-end accr. period fractions
BloombergAccrDaysDataTable_m = retime(BloombergAccrDaysDataTable,'monthly','lastvalue');
BloombergAccrDaysDataTable_m.Date = eomdate(year(BloombergAccrDaysDataTable_m.Date),month(BloombergAccrDaysDataTable_m.Date),'datetime');
BloombergAccrDaysDataTable = BloombergAccrDaysDataTable_m;

%to get corresponding month-end price observations dates
BloombergPxObsDateTable_m = retime(BloombergPxObsDateTable,'monthly','lastvalue');
BloombergPxObsDateTable_m.Date = eomdate(year(BloombergPxObsDateTable_m.Date),month(BloombergPxObsDateTable_m.Date),'datetime');
BloombergPxObsDateTable = BloombergPxObsDateTable_m;



%stack observations
tmpTbl = stack(BloombergPriceDataTable, BloombergPriceDataTable.Properties.VariableNames,...
    'NewDataVariableName',"Px_Last",'IndexVariableName',"Var");
BloombergPriceDataTable = sortrows(tmpTbl,["Var","Date"]);
BloombergPriceDataTable.Var = string(BloombergPriceDataTable.Var);

tmpTbl = stack(BloombergAccrDaysDataTable, BloombergAccrDaysDataTable.Properties.VariableNames,...
    'NewDataVariableName',"AccrFract",'IndexVariableName',"Var");
BloombergAccrDaysDataTable = sortrows(tmpTbl,["Var","Date"]);
BloombergAccrDaysDataTable.Var = string(BloombergAccrDaysDataTable.Var);

tmpTbl = stack(BloombergPxObsDateTable, BloombergPxObsDateTable.Properties.VariableNames,...
    'NewDataVariableName',"PxDate",'IndexVariableName',"Var");
BloombergPxObsDateTable = sortrows(tmpTbl,["Var","Date"]);
BloombergPxObsDateTable.Var = string(BloombergPxObsDateTable.Var);





%% merge bulk data 

tmpTbl = outerjoin(BloombergPriceDataTable,BloombergAccrDaysDataTable,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl;
clear tmpTbl

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,BloombergPxObsDateTable,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl;
clear tmpTbl

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Card_Mpr_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl;
clear tmpTbl

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Hist_Interest_Distributed_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Hist_Interest_Shortfall_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Hist_Principal_Distributed_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Mtg_Hist_Cpn_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Hist_Losses_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Mtg_Hist_Charge_Off_1mo_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Mtg_Hist_Charge_Off_3mo_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Mtg_Hist_Exs_1m_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

tmpTbl = outerjoin(Advanta_ABCMT_Tbl,Mtg_Hist_Portf_Yld_Table,'Keys',["Date","Var"],'MergeKeys',true,'Type','left');
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;

% merge specs
tmpTbl = join(Advanta_ABCMT_Tbl,BloombergSpecsDataTable,'Keys',"Var");
Advanta_ABCMT_Tbl = tmpTbl; 
clear tmpTbl;


%sort
Advanta_ABCMT_Tbl = sortrows(Advanta_ABCMT_Tbl,["Var","Date"]);
clearvars -except Advanta_ABCMT_Tbl



%% load swaps data

fileName = 'E:\Dropbox\Work\Research\CreditCardABS\Analysis\CreateSwapsDataset\SwapLiborFixedTable.mat';
load(fileName,'SwapLibor3mVsFixedTable_d','SwapLibor3mVsFixedTable_m',...
    'SwapLibor1mVsFixedTable_m','SwapLibor1mVsFixedTable_d','LiborTable');



tmpTblAbs = Advanta_ABCMT_Tbl;
tmpTblAbs.Swap = NaN(length(Advanta_ABCMT_Tbl.Date),1);
tmpTblAbs.PxDatetime = datetime(year(tmpTblAbs.PxDate),month(tmpTblAbs.PxDate),day(tmpTblAbs.PxDate));
tmpTblAbs.MonthsToExpMat = NaN(length(Advanta_ABCMT_Tbl.Date),1);
tmpTblAbs.Less1yrToExpMat = NaN(length(Advanta_ABCMT_Tbl.Date),1);

PxObsDates = tmpTblAbs.PxDatetime;
PxObsDates = unique(PxObsDates(~ismissing(PxObsDates)));
SwapLibor1mVsFixedTable_d = retime(SwapLibor1mVsFixedTable_d,PxObsDates,'previous');
SwapLibor3mVsFixedTable_d = retime(SwapLibor3mVsFixedTable_d,PxObsDates,'previous');


for rowSelect=1:length(tmpTblAbs.Date)
    
    currDate = tmpTblAbs.Date(rowSelect);
    currPxDate = tmpTblAbs.PxDate(rowSelect);
    currFloatIndex = tmpTblAbs.Reset_Idx(rowSelect);
    
    currExpMat = datetime(datestr(string(tmpTblAbs.Mtg_Exp_Mty_Dt(rowSelect))));
    currNoMonthsToExpMaturity = max(1,months(datenum(currDate),datenum(currExpMat)));
    if currNoMonthsToExpMaturity>360
        currNoMonthsToExpMaturity=360;
    end
    tmpTblAbs.MonthsToExpMat(rowSelect) =  max(0,months(datenum(currDate),datenum(currExpMat)));
    currSwapVarname = strcat("x",string(currNoMonthsToExpMaturity));
    if currNoMonthsToExpMaturity < 12
        tmpTblAbs.Less1yrToExpMat(rowSelect) = 1;
    else
        tmpTblAbs.Less1yrToExpMat(rowSelect) = 0;
    end
    
    if currFloatIndex == "US0001M"
        
        tmpSwapDates = datenum(SwapLibor1mVsFixedTable_d.Date);
        currPxDateNum  = datenum(currPxDate);
        idx = find(tmpSwapDates==currPxDateNum,1,'first');
        if isempty(idx)
            currSwapRate = NaN;
        else
            currSwapRate = SwapLibor1mVsFixedTable_d{idx,currSwapVarname};
        end
                
    elseif currFloatIndex == "US0003M"
        tmpSwapDates = datenum(SwapLibor3mVsFixedTable_d.Date);
        currPxDateNum  = datenum(currPxDate);
        idx = find(tmpSwapDates==currPxDateNum,1,'first');
        if isempty(idx)
            currSwapRate = NaN;
        else
            currSwapRate = SwapLibor3mVsFixedTable_d{idx,currSwapVarname};
        end
        
    else
        
        currSwapRate = NaN;
    
    end
    
    tmpTblAbs.Swap(rowSelect) = currSwapRate;
        
        
end
Advanta_ABCMT_Tbl = tmpTblAbs;



%% calculate swapped coupon and accrued interest

filePath = 'E:\Dropbox\Work\Research\CreditCardABS\Analysis\CreateSwapsDataset\DT_Table_Matlab.mat';
%filePath = 'C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Analysis\CreateSwapsDataset\DT_Table_Matlab.mat';
load(filePath,'IRObj_Table')
IRObj_Table = retime(IRObj_Table,PxObsDates,'previous');


Advanta_ABCMT_Tbl.CpnSwapped_ActAct = NaN(length(Advanta_ABCMT_Tbl.Var),1);
Advanta_ABCMT_Tbl.AccrInt_ActAct = NaN(length(Advanta_ABCMT_Tbl.Var),1);
Advanta_ABCMT_Tbl.PxFull_Last = NaN(length(Advanta_ABCMT_Tbl.Var),1);
for dateSelect=1:length(Advanta_ABCMT_Tbl.Date)
    
    currDate = Advanta_ABCMT_Tbl.Date(dateSelect);
    currAccrFrac = Advanta_ABCMT_Tbl.AccrFract(dateSelect);
    currCpnActAct = Advanta_ABCMT_Tbl.Cpn_ActAct(dateSelect)./100;
    currCpnType = Advanta_ABCMT_Tbl.Cpn_Typ(dateSelect);
    currFltSpread = Advanta_ABCMT_Tbl.Flt_Spread(dateSelect)./10000;
    currFltSpreadActAct = Advanta_ABCMT_Tbl.Flt_Spread_ActAct(dateSelect)./10000;
    currFltIndex = Advanta_ABCMT_Tbl.Reset_Idx(dateSelect);
    currSwap = Advanta_ABCMT_Tbl.Swap(dateSelect)./100;
    currPx  = Advanta_ABCMT_Tbl.Px_Last(dateSelect);
    currCpnFreq = Advanta_ABCMT_Tbl.Cpn_Freq(dateSelect);
    currIssDate = Advanta_ABCMT_Tbl.Issued(dateSelect);
    currMatDate = Advanta_ABCMT_Tbl.Mtg_Exp_Mty_Dt(dateSelect);
    currPxObsDate = Advanta_ABCMT_Tbl.PxDatetime(dateSelect);
    
    
    if currCpnType == "FIXED"
                        
        %Reannuitize to monthly
        if currCpnFreq ~= 12
            
            tmpSettle = datenum(currPxObsDate);
            tmpMatDate = datenum(currMatDate);
            tmpIssDate = datenum(currIssDate);
            
            if (tmpSettle >= tmpIssDate) && (tmpSettle < tmpMatDate)
                tmpDTDates = datenum(IRObj_Table.Date);
                idx = find(tmpDTDates==tmpSettle,1,'first');
                tmpIRObj = IRObj_Table{idx,'IRObj'}{:};
                tmpDayCnt = 0; %act/act daycount
                tmpCpnRate = currCpnActAct;
                tmpCpnFreq = currCpnFreq; %monthly coupons
                tmpCpnDates_act = cfdates(tmpSettle,tmpMatDate,tmpCpnFreq,tmpDayCnt);
                tmpCpnDates_m = cfdates(tmpSettle,tmpMatDate,12,tmpDayCnt);
                %%%%%%%tmpDT_act = getDiscountFactors(tmpIRObj, tmpCpnDates);
                %%%%%%%tmpDT_m = getDiscountFactors(tmpIRObj, tmpCpnDates_m);
                %%%%%%%currCpnRate = tmpCpnRate.*(12./tmpCpnFreq).*(sum(tmpDT_act)./sum(tmpDT_m));
                tmpZeroRates_act = getZeroRates(tmpIRObj, tmpCpnDates_act);
                tmpZeroRates_m = getZeroRates(tmpIRObj, tmpCpnDates_m);
                tmpBondSpec_act = [datenum(tmpMatDate) tmpCpnRate 100 tmpCpnFreq tmpDayCnt];
                tmpFun = @(x) prbyzero([datenum(tmpMatDate) x 100 12 tmpDayCnt], tmpSettle, tmpZeroRates_m, tmpCpnDates_m)-prbyzero(tmpBondSpec_act, tmpSettle, tmpZeroRates_act, tmpCpnDates_act);    
                tmpCurrCpnActAct = fzero(tmpFun,tmpCpnRate);
                currCpnActAct = tmpCurrCpnActAct;
                currCpnFreq = 12;
            end
            
        end
        currAccrInt = (currCpnActAct./currCpnFreq).*currAccrFrac.*100;
        Advanta_ABCMT_Tbl.CpnSwapped_ActAct(dateSelect) = currCpnActAct;
        Advanta_ABCMT_Tbl.AccrInt_ActAct(dateSelect) = currAccrInt;
        Advanta_ABCMT_Tbl.PxFull_Last(dateSelect) = currPx + currAccrInt;
        Advanta_ABCMT_Tbl.Cpn_Freq(dateSelect) = currCpnFreq;
        
    elseif currCpnType == "FLOATING"
                
        %Reannuitize to monthly
        if currCpnFreq ~= 12
            
            tmpSettle = datenum(currPxObsDate);
            tmpMatDate = datenum(currMatDate);
            tmpIssDate = datenum(currIssDate);
            
            if (tmpSettle >= tmpIssDate) && (tmpSettle < tmpMatDate)
                 tmpDTDates = datenum(IRObj_Table.Date);
                idx = find(tmpDTDates==tmpSettle,1,'first');
                tmpIRObj = IRObj_Table{idx,'IRObj'}{:};
                tmpDayCnt = 0; %act/act daycount
                tmpCpnRate = currFltSpreadActAct;
                tmpCpnFreq = currCpnFreq; %monthly coupons
                tmpCpnDates_act = cfdates(tmpSettle,tmpMatDate,tmpCpnFreq,tmpDayCnt);
                tmpCpnDates_m = cfdates(tmpSettle,tmpMatDate,12,tmpDayCnt);
                %%%%%%%tmpDT_act = getDiscountFactors(tmpIRObj, tmpCpnDates);
                %%%%%%%tmpDT_m = getDiscountFactors(tmpIRObj, tmpCpnDates_m);
                %%%%%%%currCpnRate = tmpCpnRate.*(12./tmpCpnFreq).*(sum(tmpDT_act)./sum(tmpDT_m));
                tmpZeroRates_act = getZeroRates(tmpIRObj, tmpCpnDates_act);
                tmpZeroRates_m = getZeroRates(tmpIRObj, tmpCpnDates_m);
                tmpBondSpec_act = [datenum(tmpMatDate) tmpCpnRate 100 tmpCpnFreq tmpDayCnt];
                tmpFun = @(x) prbyzero([datenum(tmpMatDate) x 100 12 tmpDayCnt], tmpSettle, tmpZeroRates_m, tmpCpnDates_m)-prbyzero(tmpBondSpec_act, tmpSettle, tmpZeroRates_act, tmpCpnDates_act);    
                tmpCurrFltSpreadActAct = fzero(tmpFun,tmpCpnRate);
                currFltSpreadActAct = tmpCurrFltSpreadActAct;
                currCpnFreq = 12;
            end
            
        end
        
        currCpnRate = currFltSpreadActAct + currSwap;
        currAccrInt = (currCpnRate./currCpnFreq).*currAccrFrac.*100;
        Advanta_ABCMT_Tbl.CpnSwapped_ActAct(dateSelect) = currCpnRate;
        Advanta_ABCMT_Tbl.AccrInt_ActAct(dateSelect) = currAccrInt;
        Advanta_ABCMT_Tbl.PxFull_Last(dateSelect) = currPx + currAccrInt;
        Advanta_ABCMT_Tbl.Cpn_Freq(dateSelect) = currCpnFreq;
    end
    
end

%% calculate prices of swapped bonds by discounting cf's using the Treasury term-structure


tmpTbl = Advanta_ABCMT_Tbl(:,{'Var','Number','BB_ID','Ticker','Series','Class',...
    'Px_Last','PxDatetime','CpnSwapped_ActAct','AccrInt_ActAct',...
    'Issued','Maturity','Mtg_Exp_Mty_Dt','Cpn_Freq','MonthsToExpMat'});
noRows = length(tmpTbl.Date);
tmpTbl.Px_TreasDisc = NaN(noRows,1);
tmpErr = NaN(noRows,1);
for rowSelect=1:noRows

    sprintf('== Row: %d | %d ==\n',rowSelect,noRows)
    
    currPxObsDate = tmpTbl.PxDatetime(rowSelect);
        
    if ismissing(currPxObsDate)
        continue;
    end
    
    try 
        tmpSettle = datenum(currPxObsDate);
        tmpMatDate = datenum(tmpTbl.Mtg_Exp_Mty_Dt(rowSelect));
        if tmpSettle==tmpMatDate
            tmpTbl.Px_TreasDisc(rowSelect) =  tmpbndPx;
            continue;
        end
        if tmpSettle>tmpMatDate
            continue;
        end
        
        tmpCpnRate = tmpTbl.CpnSwapped_ActAct(rowSelect);
        tmpDayCnt = 0; %act/act daycount
        tmpCpnFreq = tmpTbl.Cpn_Freq(rowSelect); %monthly coupons
        tmpCpnDates_act = cfdates(tmpSettle,tmpMatDate,tmpCpnFreq,tmpDayCnt);
        
        tmpDTDates = datenum(IRObj_Table.Date);
        idx = find(tmpDTDates==tmpSettle,1,'first');
        tmpIRObj = IRObj_Table{idx,'IRObj'}{:};
        
        tmpZeroRates = getZeroRates(tmpIRObj, tmpCpnDates_act);
        tmpBondSpec = [datenum(tmpMatDate) tmpCpnRate 100 tmpCpnFreq tmpDayCnt];
        tmpbndPx = prbyzero(tmpBondSpec, tmpSettle, tmpZeroRates, tmpCpnDates_act);    
        tmpTbl.Px_TreasDisc(rowSelect) =  tmpbndPx;
    catch
        tmpTbl.Px_TreasDisc(rowSelect) = NaN;
        tmpErr(rowSelect) = 1;
    end
    
end

tmpTbl.DeltaPxTreas = tmpTbl.Px_TreasDisc - tmpTbl.Px_Last;
tmpTbl = tmpTbl(:,{'Var','Number','BB_ID','Ticker','Series','Class',...
    'Px_Last','Px_TreasDisc','DeltaPxTreas',...
    'PxDatetime','CpnSwapped_ActAct','AccrInt_ActAct',...
    'Issued','Maturity','Mtg_Exp_Mty_Dt','Cpn_Freq','MonthsToExpMat'});


Advanta_ABCMT_Tbl.Px_TreasDisc = tmpTbl.Px_TreasDisc;
Advanta_ABCMT_Tbl.DeltaPxTreas = tmpTbl.DeltaPxTreas;


%% save

filePath = "E:\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
%filePath = "C:\Users\mflec\Dropbox\Work\Research\CreditCardABS\Data\ABCMT\";
fileName = "file01_CreatePanelDataset.mat";
save(strcat(filePath,fileName),'Advanta_ABCMT_Tbl')





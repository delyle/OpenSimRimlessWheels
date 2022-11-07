function simData2osimSTO(fileName,simData)
% expects simData as a struct with fields .data and .columnLabels.
% The fields within .data and .columnLabels are shortened forms of the
% coordinate names (e.g. jointset/pelvisToGround/Pelvis_rx/value becomes Pelvis_rx_value)
% .data has the additional field .time
% .columnLables preserves the original coordinate names exactly for
% printing to .sto or .mot

% create new osim table 
table = osimTableFromStruct(simData.data);

% cycle through table and change column headers
nLabels = table.getNumColumns();
for i = 0:nLabels-1
    curLabel = char(table.getColumnLabel(i));
    newLabel = simData.columnLabels.(curLabel);
    table.setColumnLabel(i,newLabel);
end

% save .sto
stofiles = STOFileAdapter();
fprintf('Writing table to %s\n',fileName)
stofiles.write(table, savename);
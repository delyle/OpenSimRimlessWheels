% run a forward simulation

fName = '3DRimlessWheel.osim';

options = struct('endTime',5,'stepSize',0.001,'reportInterval',0.01,'useVis',true);

RimlessWheelForwardSimulation(fName,options,'test');
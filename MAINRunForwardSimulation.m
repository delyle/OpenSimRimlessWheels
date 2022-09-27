% run a forward simulation

fName = '3DRimlessWheel.osim';

d2r = pi/180;

options = struct('endTime',5,'stepSize',0.001,'reportInterval',0.01,...
    'useVis',true);
initCoords = {'Pelvis_tx',0,0.2};

simData = RimlessWheelForwardSimulation(fName,'test',initCoords,options);
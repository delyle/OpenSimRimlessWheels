% run a forward simulation

fName = '3DRimlessWheel.osim';

d2r = pi/180;

options = struct('endTime',3,'stepSize',0.001,'reportInterval',0.01,...
    'useVis',true);
initCoords = {'Pelvis_tx',5,10};

simData = RimlessWheelForwardSimulation(fName,'test',initCoords,options);
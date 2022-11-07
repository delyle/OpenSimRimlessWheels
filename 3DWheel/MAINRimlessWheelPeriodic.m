% MAINRimlessWheelPeriodic
clear
fName = '3DRimlessWheel.osim';

% set default coordinate values to initial values of period in a planar
% forward simulation
finalAngle = pi/3;

RimlessWheelMakePlanarGuess(fName,finalAngle);

RimlessWheelPeriodicMoco(fName,-finalAngle)
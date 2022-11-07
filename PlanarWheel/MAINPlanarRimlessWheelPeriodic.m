% MAINRimlessWheelPeriodic
clear
fName = 'PlanarRimlessWheel.osim';

% set default coordinate values to initial values of period in a planar
% forward simulation
finalAngle = pi/6;

PlanarRimlessWheelMakeGuess(fName,finalAngle);

PlanarRimlessWheelPeriodicMoco(fName,-finalAngle)
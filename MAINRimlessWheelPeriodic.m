% MAINRimlessWheelPeriodic

fName = '3DRimlessWheel.osim';

% set default coordinate values to initial values of period in a planar
% forward simulation
finalAngle = pi/6;

RimlessWheelMakePlanarGuess(fName,finalAngle);


RimlessWheelPeriodicMoco(fName,-2*finalAngle)
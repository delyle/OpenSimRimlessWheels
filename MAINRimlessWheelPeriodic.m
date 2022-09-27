% MAINRimlessWheelPeriodic

fName = '3DRimlessWheel.osim';

% set default coordinate values to initial values of period in a planar
% forward simulation
RimlessWheelMakePlanarGuess(fName,pi/3);

RimlessWheelPeriodicMoco(fName,-360/6*pi/180)
function RimlessWheelMakePlanarGuess(fName,targetAngle,fNameNew)
if nargin < 3 
    fNameNew = fName;
end



OPC = strcat('Pelvis_',{'rx','ry','tz'}); % off-planar coordinates

% run a feedforward simulation

options = struct('endTime',5,'stepSize',0.001,'reportInterval',0.01,...
    'useVis',false,'lockedCoords',{OPC});
initCoords = {'Pelvis_tx',0,1};

simData = RimlessWheelForwardSimulation(fName,'test',initCoords,options);

% find last instance of vertical leg

t = simData.time;
X = simData.Pelvis_rz_value;

modX = mod(X,targetAngle);
dmodX = diff(modX)./diff(t);
iTarget = find(abs(dmodX) > 10,1,'last'); % finds a rapid change in modX
% this rapid change indicates that Pelvis_rz has crossed the targetAngle 


simData.Pelvis_rz_value(iTarget) = 0; % reset angle to zero at target time
simData.Pelvis_tx_value(iTarget) = 0; % reset position to zero at target time


% set model defaults to values at iTarget
import org.opensim.modeling.*

model = Model(fName);
coordSet = model.updCoordinateSet;
n = coordSet.getSize;
for i = 0:n-1
    coordName = char(coordSet.get(i));
    coordSet.get(i).setDefaultValue(simData.([coordName,'_value'])(iTarget))
    coordSet.get(i).setDefaultSpeedValue(simData.([coordName,'_speed'])(iTarget))
end

model.initSystem();

% save the model to a file
model.print(fName);
disp([fName,' printed with new defaults coordinate values and speeds']);





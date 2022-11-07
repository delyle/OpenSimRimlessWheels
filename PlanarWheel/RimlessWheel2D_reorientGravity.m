% Build a rimless wheel model with reoriented gravity

blankSlate

%% Import OSim Libraries
import org.opensim.modeling.*

%% Define key model variables
modelName = 'PlanarRimlessWheel';
pelvisWidth = 0.20;
legLength = 0.50;
legWidth = 0.05;
torsoMass = 10;
torsoLength = 1.5;
contactSphereRadius = 0.025;
rampInitialAngle = -5;


nRightLegs = 12;
nLeftLegs = 0;
angleOffsetRight = 0;
angleOffsetLeft = 0;

% Define Contact Force Parameters
stiffness           = 1000000;
dissipation         = 2.0;
staticFriction      = 0.8;
dynamicFriction     = 0.4;
viscousFriction     = 0.4;
transitionVelocity  = 0.2;


%% intantiate an empty OpenSim Model
osimModel = Model();
osimModel.setName(modelName)

% Get a reference to the ground object
ground = osimModel.getGround();

% define acceleration of gravity
    a = deg2rad(rampInitialAngle);
    gvec = -9.81*[sin(a),cos(a),0];
    osimModel.setGravity(osimVec3FromArray(gvec));
    
    
    % make contact half space
    
% Make a contact Half space for the ground
groundContactLocation = Vec3(0,0,0);
groundContactOrientation = Vec3(0,0,-pi/2);
groundContactSpace = ContactHalfSpace(groundContactLocation,groundContactOrientation,ground);
contactSpaceName = 'GroundContact';
groundContactSpace.setName(contactSpaceName);
osimModel.addContactGeometry(groundContactSpace);
%% Construct bodies and joints
% halve leg length, because of how cylinders are built in opensim
cylLength = legLength/2;

%%
% Make and add a Pelvis Body
pelvis = Body();
pelvis.setName('Pelvis');
pelvis.setMass(1);
pelvis.setInertia(Inertia(1,1,1,0,0,0));
% Add geometry for display
pelvis.attachGeometry(Sphere(pelvisWidth));
% Add Body to the Model
osimModel.addBody(pelvis);

% Make and add a Planar joint for the Pelvis Body
pelvisToGround = PlanarJoint('PelvisToGround', osimModel.getGround(), pelvis);
% Update the coordinates of the new joint
Pelvis_rz = pelvisToGround.upd_coordinates(0); % Rotation about z
Pelvis_rz.setRange([-pi, pi]);
Pelvis_rz.setName('Pelvis_rz');
Pelvis_rz.setDefaultValue(0);

Pelvis_tx = pelvisToGround.upd_coordinates(1); % T about x
Pelvis_tx.setRange([-10, 10]);
Pelvis_tx.setName('Pelvis_tx');
Pelvis_tx.setDefaultValue(-10);
Pelvis_tx.setDefaultSpeedValue(0)

Pelvis_ty = pelvisToGround.upd_coordinates(2); % Translation about y
Pelvis_ty.setRange([-5,5]);
Pelvis_ty.setName('Pelvis_ty');
Pelvis_ty.setDefaultValue(legLength);
Pelvis_ty.setDefaultSpeedValue(0)
% Add Joint to model
osimModel.addJoint(pelvisToGround)

%% Add Hind Legs

[LegS, ContactS, ForceS] = deal(struct);

% Make and add a Right Hind legs
nLegs = nRightLegs;
angleOffset = angleOffsetRight;
legAngle = 360/nLegs;
hipPos = pelvisWidth;
sidePrefix = 'rHind';
RimlessWheel_addLegs

% Make and add a Left Hind leg 1
nLegs = nLeftLegs;
legAngle = 360/nLegs;
angleOffset = angleOffsetLeft;
hipPos = -pelvisWidth;
sidePrefix = 'lHind';
RimlessWheel_addLegs

%% Initialize the System (checks model consistency).
osimModel.initSystem();

% Save the model to a file
fname = [modelName,'.osim'];
osimModel.print(fname);
disp([fname,' printed!']);

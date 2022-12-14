% Build a rimless wheel model

blankSlate

%% Import OSim Libraries
import org.opensim.modeling.*

%% Define key model variables
modelName = '3DRimlessWheel';
pelvisWidth = 0.20;
legLength = 0.50;
legWidth = 0.05;
torsoMass = 10;
torsoLength = 1.5;
contactSphereRadius = 0.025;
rampHeightOffset = 5;
rampInitialAngle = -2.5; % in degrees.

reorientGravity = true; % if true, there is no platform joint. Gravity is reoriented according to the platform angle.
lockOffPlanar = false; % if true, extra DOF that aren't in the sagittal plane are locked.
visualizeModel = true; % if true, model shown in visualizer window. This will block until the user exits the visualizer window

nRightLegs = 6;
nLeftLegs = 6;
angleOffsetRight = 30;
angleOffsetLeft = 0;

initialSpeed = 0.1;

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
if reorientGravity
    a = deg2rad(rampInitialAngle);
    gvec = -9.81*[sin(a),cos(a),0];
    osimModel.setGravity(osimVec3FromArray(gvec));
else
    osimModel.setGravity(Vec3(0, -9.81,0));
end
%% Construct bodies and joints
% halve leg length, because of how cylinders are built in opensim
cylLength = legLength/2;

if ~reorientGravity
    platform = Body();
    platform.setName('Platform');
    platform.setMass(torsoMass);
    platform.setInertia( Inertia(1,1,1,0,0,0) );
    
    % Add geometry to the body
    platformGeometry = Brick(Vec3(10,0.01,1));
    platform.attachGeometry(platformGeometry);
    
    % Add Body to the Model
    osimModel.addBody(platform);
    
    % Section: Create the Platform Joint
    % Make and add a Pin joint for the Platform Body
    locationInParent    = Vec3(0,0,0);
    orientationInParent = Vec3(0,0,0);
    locationInChild     = Vec3(0,0,0);
    orientationInChild  = Vec3(0,0,0);
    platformToGround    = PinJoint('PlatformToGround',...  % Joint Name
        ground,...             % Parent Frame
        locationInParent,...   % Translation in Parent Frame
        orientationInParent,...% Orientation in Parent Frame
        platform,...           % Child Frame
        locationInChild,...    % Translation in Child Frame
        orientationInChild);   % Orientation in Child Frame
    
    % Update the coordinates of the new joint
    platform_rz = platformToGround.upd_coordinates(0);
    platform_rz.setRange([deg2rad(-100), deg2rad(100)]);
    platform_rz.setName('platform_rz');
    platform_rz.setDefaultValue(deg2rad(rampInitialAngle));
    platform_rz.setDefaultSpeedValue(0);
    platform_rz.setDefaultLocked(true)
    
    % Add Joint to the Model
    osimModel.addJoint(platformToGround);
    
    % Make a Contact Half Space
    groundContactLocation = Vec3(0,0.025,0);
    groundContactOrientation = Vec3(0,0,-1.57);
    groundContactSpace = ContactHalfSpace(groundContactLocation,...
        groundContactOrientation,...
        platform);
    contactSpaceName  = 'PlatformContact'; % needed for the addLegs script
    groundContactSpace.setName(contactSpaceName);
    osimModel.addContactGeometry(groundContactSpace);
else
    % Make a contact Half space for the ground
    groundContactLocation = Vec3(0,0,0);
    groundContactOrientation = Vec3(0,0,-pi/2);
    groundContactSpace = ContactHalfSpace(groundContactLocation,groundContactOrientation,ground);
    contactSpaceName = 'GroundContact';
    groundContactSpace.setName(contactSpaceName);
    osimModel.addContactGeometry(groundContactSpace); 
end

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

% Make and add a free joint for the Pelvis Body
if reorientGravity
    coordNames = strcat('Pelvis_',{'rx','ry','rz','tx','ty','tz'});
    pelvisToPlatform = CustomFreeJoint('PelvisToGround', ground, pelvis, coordNames);
    osimModel.addJoint(pelvisToPlatform)
else
    pelvisToPlatform = FreeJoint('PelvisToPlatform', platform, pelvis);
end
% Update the coordinates of the new joint

% get editable version of the joint attached to the model
pelvisToPlatform = osimModel.updJointSet().get('PelvisToGround');

Pelvis_rx = pelvisToPlatform.upd_coordinates(0); % Rotation about x
Pelvis_rx.setRange([-pi, pi]);
Pelvis_rx.setDefaultValue(0);
Pelvis_rx.setDefaultLocked(lockOffPlanar);

Pelvis_ry = pelvisToPlatform.upd_coordinates(1); % Rotation about y
Pelvis_ry.setRange([-pi, pi]);
Pelvis_ry.setDefaultValue(0);
Pelvis_ry.setDefaultLocked(lockOffPlanar);

Pelvis_rz = pelvisToPlatform.upd_coordinates(2); % Rotation about z
Pelvis_rz.setRange([-pi, pi]);
Pelvis_rz.setDefaultValue(0);

Pelvis_tx = pelvisToPlatform.upd_coordinates(3); % Translation along x
Pelvis_tx.setRange([-10, 10]);
Pelvis_tx.setDefaultValue(-10);
Pelvis_tx.setDefaultSpeedValue(initialSpeed)

Pelvis_ty = pelvisToPlatform.upd_coordinates(4); % Translation along y
Pelvis_ty.setRange([-5,5]);
Pelvis_ty.setDefaultValue(legLength+0.1);
Pelvis_ty.setDefaultSpeedValue(0)

Pelvis_tz = pelvisToPlatform.upd_coordinates(5); % Translation along z
Pelvis_tz.setRange([-1,1]);
Pelvis_tz.setDefaultValue(0);
Pelvis_tz.setDefaultSpeedValue(0)


% Add Joint to model
osimModel.initSystem();

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

% visualize the model

if visualizeModel
   VisualizerUtilities().showModel(osimModel) 
end
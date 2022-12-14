import org.opensim.modeling.*
for i = 1:nLegs
    bodyname = [sidePrefix,num2str(i)];
    jointname = [bodyname,'ToPelvis'];
    LegS.(bodyname) = Body();
    LegS.(bodyname).setName(bodyname);
    LegS.(bodyname).setMass(0.1);
    LegS.(bodyname).setInertia(Inertia(0,0,0,0,0,0));
    % Add geometry for display
    LegS.(bodyname).attachGeometry(Cylinder(legWidth/2,cylLength));
    % Add Body to the Model
    osimModel.addBody(LegS.(bodyname));
    
    % Make and add a Weld joint for the leg
    locationInParent    = Vec3(0,0,hipPos);
    orientationInParent = Vec3(0,0,deg2rad(legAngle*(i-1) + angleOffset));
    locationInChild     = Vec3(0,-cylLength,0);
    orientationInChild  = Vec3(0,0,0);
    LegS.(jointname) = WeldJoint(jointname, pelvis, locationInParent, ...
        orientationInParent, LegS.(bodyname), locationInChild, orientationInChild);
    osimModel.addJoint(LegS.(jointname))
    
    contactname = [bodyname,'Contact'];
    forcename = [bodyname,'Force'];
    % Make a Right leg Contact Sphere
    ContactS.(contactname) = ContactSphere();
    ContactS.(contactname).setRadius(contactSphereRadius);
    ContactS.(contactname).setLocation( Vec3(0,cylLength,0) );
    ContactS.(contactname).setFrame(LegS.(bodyname))
    ContactS.(contactname).setName(contactname);
    osimModel.addContactGeometry(ContactS.(contactname));
    
    % Make a Smooth Hunt Crossley Force for Right Hind1 and update parameters
    ForceS.(forcename) = SmoothSphereHalfSpaceForce(forcename,ContactS.(contactname),groundContactSpace);
    ForceS.(forcename).set_stiffness(stiffness);
    ForceS.(forcename).set_dissipation(dissipation);
    ForceS.(forcename).set_static_friction(staticFriction);
    ForceS.(forcename).set_dynamic_friction(dynamicFriction);
    ForceS.(forcename).set_viscous_friction(viscousFriction);
    ForceS.(forcename).set_transition_velocity(transitionVelocity);
    osimModel.addForce(ForceS.(forcename));
end
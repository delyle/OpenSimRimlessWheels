function RimlessWheelPeriodicMoco(fName,finalAngle)
import org.opensim.modeling.*

osimModel = Model(fName);


% Create a MocoStudy
study = MocoStudy();
study.setName('PeriodicRimless');
problem = study.updProblem();% Define the OCP
problem.setModel(osimModel);

% Specify bounds
% time starts at 0, can go up to 3
problem.setTimeBounds(MocoInitialBounds(0.),MocoFinalBounds(0.001, 1));

p2g = '/jointset/PelvisToGround/Pelvis_';
problem.setStateInfo([p2g,'tx/value'],[0 5],[0],[0 5]);
problem.setStateInfo('/jointset/PelvisToGround/Pelvis_tx/speed',[0 5],[0 5],[0 5]);
problem.setStateInfo('/jointset/PelvisToGround/Pelvis_rz/value',pi/2*[-1 1],0,finalAngle);


% could put in bounds for other states...

% Cost, minimize periodicity residuals

periodicityGoal = MocoPeriodicityGoal('periodicityGoal');
problem.addGoal(periodicityGoal);

periodicCoordList = {'rx','ry','ty','tz'};
for iRange = 1:length(periodicCoordList)
    c = [p2g,periodicCoordList{iRange},'/value'];
    dc = [p2g,periodicCoordList{iRange},'/speed'];
    periodicityGoal.addStatePair(MocoPeriodicityGoalPair(c,c));
    periodicityGoal.addStatePair(MocoPeriodicityGoalPair(dc,dc));
end
% add periodicity for speed
periodicityGoal.addStatePair(MocoPeriodicityGoalPair([p2g,'tx','/speed']));


% Configure Solver
solver = study.initCasADiSolver();
solver.set_num_mesh_intervals(15);

solution = study.solve();

solution.unseal();
solution.write('RimlessWheelPeriodic.sto');
study.visualize(solution);
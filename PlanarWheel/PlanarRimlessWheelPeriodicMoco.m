function PlanarRimlessWheelPeriodicMoco(fName,finalAngle)
import org.opensim.modeling.*

osimModel = Model(fName);


% Create a MocoStudy
study = MocoStudy();
study.setName('PeriodicPlanarRimless');
problem = study.updProblem();% Define the OCP
problem.setModel(osimModel);

% Specify bounds
% time starts at 0, can go up to 3
problem.setTimeBounds(MocoInitialBounds(0.),MocoFinalBounds(0.1, 1));

p2g = '/jointset/PelvisToGround/Pelvis_';
problem.setStateInfo([p2g,'tx/value'],[0 5],[0],[0 5]);
problem.setStateInfo('/jointset/PelvisToGround/Pelvis_tx/speed',[0 5],[0 5],[0 5]);
problem.setStateInfo('/jointset/PelvisToGround/Pelvis_rz/value',sort([0 finalAngle]),0,finalAngle);


% could put in bounds for other states...
%problem.setStateInfo('/jointset/PelvisToGround/Pelvis_rx/value',pi/3*[-1 1],pi/3*[-1 1],pi/3*[-1 1]);


% Cost, minimize periodicity residuals
periodicityGoal = MocoPeriodicityGoal('periodicityGoal');
periodicityGoal.setMode('cost');
problem.addGoal(periodicityGoal);

periodicCoordList = {'ty'};
for iRange = 1:length(periodicCoordList)
    c = [p2g,periodicCoordList{iRange},'/value'];
    dc = [p2g,periodicCoordList{iRange},'/speed'];
    periodicityGoal.addStatePair(MocoPeriodicityGoalPair(c,c));
    periodicityGoal.addStatePair(MocoPeriodicityGoalPair(dc,dc));
end
% add periodicity for speed
periodicityGoal.addStatePair(MocoPeriodicityGoalPair([p2g,'tx','/speed']));
periodicityGoal.addStatePair(MocoPeriodicityGoalPair([p2g,'rz','/speed']));

% Configure Solver
solver = study.initCasADiSolver();
solver.set_num_mesh_intervals(15);
%solver.set_optim_convergence_tolerance(1e-3);
%solver.set_optim_constraint_tolerance(1e-3);
solver.setGuessFile('PlanarRimlessWheelPeriodic.sto');%([strrep(fName,'.osim',''),'_Cycle.sto']);
solution = study.solve();

solution.unseal();
solution.write('PlanarRimlessWheelPeriodic.sto');

% Extract ground reaction forces
% ==============================
contact_r = StdVectorString();
contact_l = StdVectorString();
contact_r.add('/forceset/rHind7Force');
contact_l.add('/forceset/rHind8Force');

externalForcesTableFlat = opensimMoco.createExternalLoadsTableForGait(osimModel, ...
                                 solution,contact_r,contact_l);
STOFileAdapter.write(externalForcesTableFlat, ...
                             'PlanarRimlessWheelPeriodicGRF.sto');

% Animate solution in the visualizer
study.visualize(solution);
clc
addpath('../')
addpath('../..')

% Df, Lr, Ls, ms, mp, tb
icansat = SingleStageRocket(0.1567, 2.391, 4, 14, 1.160534, 3.6325, 0);

RunTrajectorySim(icansat, 88);
RunTrajectorySim(icansat, 86);
RunTrajectorySim(icansat, 84);
RunTrajectorySim(icansat, 82);
RunTrajectorySim(icansat, 80);
RunTrajectorySim(icansat, 78);
RunTrajectorySim(icansat, 76);
RunTrajectorySim(icansat, 74);
RunTrajectorySim(icansat, 72);
RunTrajectorySim(icansat, 70);

function RunTrajectorySim(rocket, launch_angle)
    % Timestep, no. of timesteps, launch angle
    rocket.SetSimulationParams(0.0025, 30000, launch_angle);
    rocket.SetRocketID("ICANSAT");
    rocket.InitializeVars();

    % Uncomment to use non-constant mass flow rate
    rocket.SetVariableMassFlow();

    rocket.CalculateThrust('ICANSAT_V2_Thrust_v_Time.txt');
    rocket.CalculateTrajectory();
    rocket.WriteDataFile();
end
clc
addpath('../')

% dorado_1s = SingleStageRocket(0.31, 6.416, 10, 181.045, 201.58, 22.45625, 0.0289);
dorado_1s = SingleStageRocket(0.31, 6.416, 9.653, 171.155, 202.3, 22.45625, 0.0289);
dorado_1s.SetSimulationParams(0.01, 100000, 85);
dorado_1s.SetRocketID("Dorado1S");
dorado_1s.InitializeVars();
dorado_1s.SetThrustCorrection();

dorado_1s.CalculateThrust('H300_Grain_V2_Vacuum_Thrust_v_Time.txt');
dorado_1s.CalculateTrajectory();
% dorado_1s.WriteDataFile();

% dorado_1s_1 = SingleStageRocket(0.31, 6.416, 10, 181.045, 201.58, 23.021875, 0.0289);
% dorado_1s_1.SetSimulationParams(0.01, 100000, 85);
% dorado_1s_1.SetRocketID("Dorado1S");
% dorado_1s_1.InitializeVars();
% dorado_1s_1.SetThrustCorrection();
% 
% dorado_1s_1.CalculateThrust('H300_Grain_V2_AT18_Vacuum_Thrust_v_Time.txt');
% dorado_1s_1.CalculateTrajectory();

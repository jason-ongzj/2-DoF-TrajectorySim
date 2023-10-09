clc
addpath('../')

mad_H300 = SingleStageRocket(0.31, 5.712, 10, 148, 158, 15.77, 0.028353);
mad_H300.SetSimulationParams(0.05, 20000, 85);
mad_H300.SetRocketID("MAD_H300");
mad_H300.InitializeVars();
mad_H300.SetThrustCorrection();

mad_H300.CalculateThrust('MAD_H300_v1_VacT_v_Time.txt');
mad_H300.CalculateTrajectory();
mad_H300.WriteCompactDataFile(20);
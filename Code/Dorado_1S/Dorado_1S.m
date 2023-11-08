clc
addpath('../')

% dorado_1s = SingleStageRocket(0.31, 6.416, 10, 181.045, 201.58, 22.45625, 0.0289);
dorado_1s_85 = SingleStageRocket(0.31, 6.416, 9.653, 171.155, 202.3, 22.45625, 0.0289);
dorado_1s_85.SetSimulationParams(0.05, 100000, 85);
dorado_1s_85.SetRocketID("Dorado1S");
dorado_1s_85.InitializeVars();
dorado_1s_85.SetThrustCorrection();
dorado_1s_85.CalculateThrust('H300_Grain_V2_Vacuum_Thrust_v_Time.txt');
dorado_1s_85.CalculateTrajectory();

dorado_1s_88 = SingleStageRocket(0.31, 6.416, 9.653, 171.155, 202.3, 22.45625, 0.0289);
dorado_1s_88.SetSimulationParams(0.05, 100000, 88);
dorado_1s_88.SetRocketID("Dorado1S");
dorado_1s_88.InitializeVars();
dorado_1s_88.SetThrustCorrection();
dorado_1s_88.CalculateThrust('H300_Grain_V2_Vacuum_Thrust_v_Time.txt');
dorado_1s_88.CalculateTrajectory();

dorado_1s_75 = SingleStageRocket(0.31, 6.416, 9.653, 171.155, 202.3, 22.45625, 0.0289);
dorado_1s_75.SetSimulationParams(0.05, 100000, 75);
dorado_1s_75.SetRocketID("Dorado1S");
dorado_1s_75.InitializeVars();
dorado_1s_75.SetThrustCorrection();
dorado_1s_75.CalculateThrust('H300_Grain_V2_Vacuum_Thrust_v_Time.txt');
dorado_1s_75.CalculateTrajectory();

subplot(1,3,1)
plot(dorado_1s_88.t(1:dorado_1s_88.NStepEnd), dorado_1s_88.y(1:dorado_1s_88.NStepEnd)/1000)
hold on
plot(dorado_1s_85.t(1:dorado_1s_85.NStepEnd), dorado_1s_85.y(1:dorado_1s_85.NStepEnd)/1000)
plot(dorado_1s_75.t(1:dorado_1s_75.NStepEnd), dorado_1s_75.y(1:dorado_1s_75.NStepEnd)/1000)
xlim([0 300]);
ylim([0 100]);
xlabel('Time (s)')
ylabel('Altitude (km)')
legend('88°', '85°', '75°')
grid on

subplot(1,3,2)
plot(dorado_1s_88.x(1:dorado_1s_88.NStepEnd)/1000, dorado_1s_88.y(1:dorado_1s_88.NStepEnd)/1000)
hold on
plot(dorado_1s_85.x(1:dorado_1s_85.NStepEnd)/1000, dorado_1s_85.y(1:dorado_1s_85.NStepEnd)/1000)
plot(dorado_1s_75.x(1:dorado_1s_75.NStepEnd)/1000, dorado_1s_75.y(1:dorado_1s_75.NStepEnd)/1000)
xlim([0 200]);
ylim([0 100]);
xlabel('Range (km)')
ylabel('Altitude (km)')
legend('88°', '85°', '75°')
grid on

subplot(1,3,3)
plot(dorado_1s_88.t(1:dorado_1s_88.NStepEnd), dorado_1s_88.M(1:dorado_1s_88.NStepEnd))
hold on
plot(dorado_1s_85.t(1:dorado_1s_85.NStepEnd), dorado_1s_85.M(1:dorado_1s_85.NStepEnd))
plot(dorado_1s_75.t(1:dorado_1s_75.NStepEnd), dorado_1s_75.M(1:dorado_1s_75.NStepEnd))
xlim([0 300]);
ylim([0 5]);
xlabel('Time (s)')
ylabel('Mach No.')
legend('88°', '85°', '75°')
grid on

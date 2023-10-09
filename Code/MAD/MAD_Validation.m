clc
addpath('../')

mad = SingleStageRocket(0.205, 4.96, 10, 68, 78, 20.1, 0);
mad.SetSimulationParams(0.05, 10000, 85);
mad.SetRocketID("MAD");
mad.InitializeVars();
mad.SetThrustCorrection();
mad.CalculateThrust('MAD v 4.2B_Thrust_v_Time.txt');
mad.CalculateTrajectory();
mad.WriteDataFile();

% MAD Data
% -----------------------------------------------------------------------------
nominal_input = dlmread("MAD/MAD_Nominal_Inputs.txt", "\t",1,0);
nominal_time = nominal_input(:, 1);
astos_thrust = nominal_input(:, 2);

trajectory_output = dlmread("MAD/MAD_Trajectory_Output.txt", "\t",1,0);
trajectory_time = trajectory_output(:, 1);
altitude = trajectory_output(:, 2);
mach = trajectory_output(:, 6);

subplot(1,3,1);
plot(mad.t(1:mad.NStepEnd), mad.y(1:mad.NStepEnd)/1000);
hold on
plot(trajectory_time, altitude, '--o','MarkerIndices',1:100:length(trajectory_time));
xlabel('Time (s)');
ylabel('Altitude (km)');
legend('2-DoF', 'ASTOS 6-DoF');
ylim([0 60]);
grid on

subplot(1,3,2);
plot(mad.t(1:mad.NStepEnd), mad.M(1:mad.NStepEnd));
hold on
plot(trajectory_time, mach, '--o','MarkerIndices',1:100:length(trajectory_time));
xlabel('Time (s)');
ylabel('Mach No.');
legend('2-DoF', 'ASTOS 6-DoF');
grid on

subplot(1,3,3);
plot(mad.t(1:mad.NStepEnd), mad.thrust(1:mad.NStepEnd)/1000);
hold on
plot(nominal_time, astos_thrust, '--o','MarkerIndices',1:100:length(nominal_time));
xlabel('Time (s)');
ylabel('Corrected Thrust (kN)');
legend('2-DoF', 'ASTOS 6-DoF');
xlim([0 25]);
grid on
% -----------------------------------------------------------------------------
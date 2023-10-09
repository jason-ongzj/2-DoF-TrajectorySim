clc
addpath('../')
addpath('../..')

% Df, Lr, Ls, ms, mp, tb
icansat = SingleStageRocket(0.1567, 2.391, 4, 14, 1.92, 8.0, 0);

% Timestep, no. of timesteps, launch angle
icansat.SetSimulationParams(0.01, 10000, 88);
icansat.SetRocketID("ICANSAT");
icansat.InitializeVars();

% Uncomment to use non-constant mass flow rate
% icansat.SetVariableMassFlow();

icansat.CalculateThrust('ICANSAT_Thrust_v_Time.txt');
icansat.CalculateTrajectory();
icansat.WriteDataFile();

subplot(2,3,1);
plot(icansat.t(1:icansat.NStepEnd), icansat.y(1:icansat.NStepEnd)/1000);
hold on
xlabel('Time (s)');
ylabel('Altitude (km)');
ylim([0 2]);
grid on

subplot(2,3,2);
plot(icansat.t(1:icansat.NStepEnd), icansat.M(1:icansat.NStepEnd));
hold on
xlabel('Time (s)');
ylabel('Mach No.');
grid on

subplot(2,3,3);
plot(icansat.t(1:icansat.NStepEnd), icansat.thrust(1:icansat.NStepEnd));
hold on
xlabel('Time (s)');
ylabel('Thrust (N)');
grid on

subplot(2,3,4);
plot(icansat.x(1:icansat.NStepEnd)/1000, icansat.y(1:icansat.NStepEnd)/1000);
hold on
xlabel('Downrange(km)');
ylabel('Altitude (km)');
ylim([0 2]);
grid on

subplot(2,3,5);
plot(icansat.t(1:icansat.NStepEnd), icansat.DvDt(1:icansat.NStepEnd));
hold on
plot([0,50], [0, 0], 'k');
xlabel('Time (s)');
ylabel('Accleration (m/s^2)');
grid on

subplot(2,3,6);
plot(icansat.t(1:icansat.NStepEnd), icansat.m(1:icansat.NStepEnd));
hold on
xlabel('Time (s)');
ylabel('Mass (kg)');
grid on
% ---------
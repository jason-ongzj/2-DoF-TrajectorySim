validation_data = dlmread("Nominal_Export.txt", "\t",1,0);
two_dof_data = dlmread("Dorado1S_Result_85deg.txt", ",",1,0);

two_dof_t = two_dof_data(:,1);
two_dof_alt = two_dof_data(:,3);
two_dof_mach = two_dof_data(:,5);
two_dof_mass = two_dof_data(:,8);
two_dof_thrust = two_dof_data(:,6)/1000;

validation_t = validation_data(:, 1);
validation_alt = validation_data(:,2);
validation_mass = validation_data(:,3);
validation_mach = validation_data(:,4);
validation_vac_thrust = validation_data(:,5);
validation_thrust = validation_data(:, 6);

figure(1)
subplot(2,2,1)
plot(validation_t, validation_alt)
hold on
plot(two_dof_t(1001:1000:end), two_dof_alt(1001:1000:end), 'or')
grid on
ylim([0 100])
ylabel("Altitude (km)", 'fontWeight', 'bold')
xlabel("Time (s)", 'fontWeight', 'bold')
legend({"ASTOS Validation", "2-DoF Dataset"}, 'fontWeight', 'bold')

subplot(2,2,2)
plot(validation_t, validation_mass*1000)
hold on
plot(two_dof_t(201:200:5000), two_dof_mass(201:200:5000), 'or')
grid on
xlim([0 50])
ylabel("Mass (kg)", 'fontWeight', 'bold')
xlabel("Time (s)", 'fontWeight', 'bold')
legend({"ASTOS Validation", "2-DoF Dataset"}, 'fontWeight', 'bold')

subplot(2,2,3)
plot(validation_t, validation_vac_thrust)
hold on
plot(validation_t, validation_thrust)
plot(two_dof_t(101:100:2248), two_dof_thrust(101:100:2248), 'or')
grid on
xlim([0 50])
ylabel("Thrust (kN)", 'fontWeight', 'bold')
xlabel("Time (s)", 'fontWeight', 'bold')
legend({'Vacuum Thrust (ASTOS)', 'Thrust (ASTOS)', 'Thrust (2-DoF Dataset)'}, 'fontWeight', 'bold')

subplot(2,2,4)
plot(validation_t, validation_mach)
hold on
plot(two_dof_t(1001:500:end), two_dof_mach(1001:500:end), 'or')
grid on
ylabel("Mach No.", 'fontWeight', 'bold')
xlabel("Time (s)", 'fontWeight', 'bold')
legend({"ASTOS Validation", "2-DoF Dataset"}, 'fontWeight', 'bold')


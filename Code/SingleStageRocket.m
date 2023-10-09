classdef SingleStageRocket < handle
   properties
       % Rocket parameters
       Df % Diameter of fuselage (meters)
       Ls % Length of structure (meters)
       Lr % Length of launch rod (meters)
       ms % Mass of structure (kg)
       mp % Mass of propellant (kg)
       tb % burn time (sec)
       
       % Boolean - constant mass flow or variable mass flow
       mdot_constant
       
       % Boolean - thrust correction
       thrust_correction
       
       % Derived parameters
       mt % Total mass
       mdot % Mass flow
       
       % Simulation parameters
       Timestep
       NSteps  % No. of timesteps
       n_tb    % Burnout timestep
       
       % Thrust data file, thrust, isp
       thrust_dat_file
       thrust
       isp
       
       % Simulation variables
       t            % Time
       V, Vcr, M    % Velocity magnitude, critical velocity, mach number; 
       v, u, ux     % Velocity components in y and x, x-component velocity calc.4
       utheta       % X-component of velocity for launch rod
       m, Cd        % Mass, drag coefficient
       x, y, theta  % X and Y positions, angle w.r.t. horizontal
       DvDt, dvdt   % Absolute and relative accelerations
       kd, kt       % Coefficients of drag and thrust
       rho, g, c, T % Density, gravity, sound speed, temperature
       area         % Cross sectional area
       q            % Dynamic pressure
       launch_angle
       exit_area    % Nozzle exit_area
       
       % Rocket identifier (MAD, ICANSAT, Spark etc.)
       % For purposes of drag identification
       ID
       
       % End of simulation
       NStepEnd
   end
   
   methods
       % Initialization
       function self = SingleStageRocket(Df, Ls, Lr, ms, mp, tb, ae)
           % Set rocket parameters
           self.Df = Df;
           self.Ls = Ls;
           self.Lr = Lr;
           self.ms = ms;
           self.mp = mp;
           self.tb = tb;
           
           % Set booleans
           self.mdot_constant = true;
           self.thrust_correction = false;
           
           % Derived parameters
           self.mt = self.ms + self.mp;
           
           % Nozzle exit area
           % If ae == 0, then thrust correction using exit area is ignored.
           self.exit_area = ae;
       end
       
       % Set rocket ID
       function SetRocketID(obj, id)
          obj.ID = id; 
       end
       
       % Set booleans
       function SetThrustCorrection(obj)
           obj.thrust_correction = true;
       end
       
       function SetVariableMassFlow(obj)
           obj.mdot_constant = false;
       end
       
       % Set simulation parameters
       function SetSimulationParams(obj, dt, nsteps, launch_angle)
           obj.Timestep = dt;
           obj.NSteps = nsteps;
           obj.launch_angle = launch_angle;
           fprintf('Launch angle: %4.2f degrees.\n', launch_angle);
           fprintf('Timestep: %6.4f s. Maximum no. of timesteps: %d.\n', dt, nsteps);
       end
       
       % Initialize variables
       function InitializeVars(obj)
           obj.t = zeros(obj.NSteps, 1);
           obj.V = zeros(obj.NSteps, 1);
           obj.Vcr = zeros(obj.NSteps, 1);
           obj.M = zeros(obj.NSteps, 1);
           obj.v = zeros(obj.NSteps, 1);
           obj.u = zeros(obj.NSteps, 1);
           obj.ux = zeros(obj.NSteps, 1);
           obj.utheta = zeros(obj.NSteps, 1);
           
           obj.m = zeros(obj.NSteps, 1);
           obj.Cd = zeros(obj.NSteps, 1);
           
           obj.x = zeros(obj.NSteps, 1);
           obj.y = zeros(obj.NSteps, 1);
           obj.theta = zeros(obj.NSteps, 1);
           
           obj.DvDt = zeros(obj.NSteps, 1);
           obj.dvdt = zeros(obj.NSteps, 1);
           
           obj.mdot = zeros(obj.NSteps, 1);
           obj.thrust = zeros(obj.NSteps, 1);
           obj.isp = zeros(obj.NSteps, 1);
           
           obj.kd = zeros(obj.NSteps, 1);
           obj.kt = zeros(obj.NSteps, 1);
           
           obj.rho = zeros(obj.NSteps, 1);
           obj.g = zeros(obj.NSteps, 1);
           obj.c = zeros(obj.NSteps, 1);
           obj.T = zeros(obj.NSteps, 1);
           
           obj.q = zeros(obj.NSteps, 1);
           
           obj.area = (pi/4)*(obj.Df.^2);
           
           % Set initial values
           obj.V(1) = 0.447;                        % Velocity - m/s
           obj.theta(1) = deg2rad(obj.launch_angle);
           obj.u(1) = obj.V(1)*cos(obj.theta(1));   % x-component of velocity
           obj.v(1) = obj.V(1)*sin(obj.theta(1));   % y-component of velocity
           obj.y(1) = 0.0;                          % Altitude - m (XY)
           obj.t(1) = 0;                            % Flight Time - s
           obj.M(1) = 0;                            % Mach Number
           obj.c(1) = 340.3961;                     % Speed of Sound - m/s^2
           obj.rho(1) = 1.23;                       % Sea Level Density - kg/m^3
           obj.T(1) = 288.16;                       % Temperature (K)
           
           obj.g(1) = 9.8066;
           obj.m(1) = obj.mt;
       end
       
       % Load thrust data (include thrust correction)
       function CalculateThrust(obj, file)
           data = dlmread(file);
           force = data(:,2);
           time = data(:,1);
           dt = obj.Timestep;
           
           resampled_time = 0:dt:obj.tb;
           resampled_force = interp1(time,force,resampled_time,'linear');

           for i = 1:length(resampled_time)
               obj.thrust(i) = resampled_force(i);
           end
           
           obj.n_tb = length(resampled_time);
           
           % Find mass flow rate up till end of burnout
           obj.CalculateMassFlow(length(resampled_time));
       end
       
       % Thrust correction based on ASTOS manual
       function T = AstosThrustCorrection(obj, h, thrust)
           [t,p,rho] = CalcAtmosQuantities(h);
           T = thrust*1.095 - 0.014 * p;
       end
       
       function T = VacThrustCorrection(obj, h, thrust)
           [t,p,rho] = CalcAtmosQuantities(h);
           T = thrust - obj.exit_area * p;
       end
       
       % Calculate mass at each iteration
       function CalculateMassFlow(obj,n_tb)
           g0 = 9.8066;
           if obj.mdot_constant == true
               % Use constant mass flow rate
               obj.mdot(2:n_tb) = obj.mp/obj.tb;
               
               % Calculate instantaneous Isp
               for i = 2:n_tb
                  if obj.mdot(i) == 0
                       obj.isp(i) = 0;  
                  else
                       obj.isp(i) = obj.thrust(i)/(obj.mdot(i) * g0);
                  end
               end
           else
               % Assuming constant Isp, use thrust values as ratios over
               % the combined sum to obtain the mass flow rate 
               mdot_sum = obj.mp/obj.Timestep;
               force_sum = sum(obj.thrust(1:n_tb));
               for i = 2:n_tb
                  obj.mdot(i) = obj.thrust(i)/force_sum * mdot_sum;
                  
                  if obj.mdot(i) == 0
                       obj.isp(i) = 0;  
                  else
                       obj.isp(i) = obj.thrust(i)/(obj.mdot(i) * g0);
                  end
               end
           end
       end
       
       % Density calculation
       function [T, rho] = CalculateRhoTemp(obj, h)
          [T,p,rho] = CalcAtmosQuantities(h);
          return;
       end
       
       % Gravity calculation
       function g = CalculateGravity(obj, h)
           g0 = 9.80665;    % Sea Level Gravity - m/s^2
           RE = 6376000;    % Radius of the Earth - m
           
           g = g0*(RE/(RE+h))^2;
           return;
       end
       
       % Drag interpolation
       % Drag interpolation functions need to be specified separately in 
       % other files due to non-similarity in data.
       function [Cd] = DragInterpolation(obj, V, y, t)
           switch obj.ID
               case "ICANSAT"
                    Cd = DragInterpolations_ICANSAT(V, y, t, obj.tb);
           
               case "MAD"
                    Cd = DragInterpolations_MAD(V, y, t, obj.tb);
                    
               case "MAD_H300"
                   Cd = DragInterpolations_MAD_H300(V, y, t, obj.tb);
              
               % Spark data not validated
               case "Spark"
                    Cd = DragInterpolations_Spark(V, y);
                    
               case "Dorado1S"
%                    Cd = DragInterpolations_Dorado1S(V, y, t, obj.tb);
                   Cd = DragInterpolations_Dorado1S_Old(V, y, t, obj.tb); % For validation purposes
           end
           return;
       end
       
       % Trajectory calculation
       function CalculateTrajectory(obj)
           Rg = 286.9; 
           nSteps = obj.NSteps;
           dt = obj.Timestep;
           
           % Calculate trajectory
           for i = 2:nSteps
                obj.t(i) = obj.t(i-1) + dt;
                V_prev = obj.V(i-1);
                y_prev = obj.y(i-1);
                t_current = obj.t(i);
                obj.Cd(i) = obj.DragInterpolation(V_prev, y_prev, t_current);
                
                % Get thrust from resampled thrust data
                if obj.t(i) >= obj.tb
                    thrust_i = 0;
                else
                    % Thrust correction if boolean true
                    if obj.thrust_correction == true
                        if obj.ID == "MAD"
                            obj.thrust(i) = obj.AstosThrustCorrection(obj.y(i-1), obj.thrust(i));
                            if obj.thrust(i) < 0
                                obj.thrust(i) = 0;
                            end
                        else
                            obj.thrust(i) = obj.VacThrustCorrection(obj.y(i-1), obj.thrust(i));
                            if obj.thrust(i) < 0
                                obj.thrust(i) = 0;
                            end
                        end
                    end
                    thrust_i = obj.thrust(i);
                end
                
                % Update mass
                obj.m(i) = obj.m(i-1) - obj.mdot(i-1)*dt;

                % Find critical velocity for leaving launch structure
                obj.Vcr(i) = sqrt((thrust_i/obj.m(i))*obj.Ls*2);
                
                % X Y Velocity Component Equations
                obj.kd(i) = (obj.rho(i-1)*obj.Cd(i)*obj.area)/(2*obj.m(i));
                obj.kt(i) = thrust_i/obj.m(i);
                obj.V(i) = sqrt(obj.u(i-1)^2 + obj.v(i-1)^2);
                obj.DvDt(i) = obj.kt(i)*obj.v(i-1)/obj.V(i) - ...
                    obj.kd(i)*obj.v(i-1)*obj.V(i) - obj.g(i-1);
                
                % Use non-zero acceleration during burn phase
                if obj.DvDt(i) < 0 && obj.t(i-1) <= obj.tb
                    obj.dvdt(i) = 0;
                else
                    obj.dvdt(i) = obj.DvDt(i);
                end
                 
                obj.v(i) = obj.v(i-1) + obj.dvdt(i)*dt;
                
                obj.utheta(i) = obj.v(i) * obj.u(i-1)/obj.v(i-1);
                obj.ux(i) = obj.u(i-1)+((obj.kt(i)*obj.u(i-1)/obj.V(i-1)) - ...
                    obj.kd(i)*obj.u(i-1)*obj.V(i-1))*dt;
                 
                % Zero acceleration on the ground
                if obj.DvDt(i) < 0 && obj.t(i-1) <= obj.tb
                    obj.u(i) = obj.u(i-1);
                % Within the launch structure
                elseif obj.x(i-1) <= obj.Lr*cos(obj.theta(1))
                    obj.u(i) = obj.utheta(i);
                % Under critical velocity for leaving launch structure
                elseif obj.V(i) < obj.Vcr(i)
                    obj.u(i) = obj.utheta(i);
                % In the air
                else
                    obj.u(i) = obj.ux(i);
                end
                 
                obj.theta(i) = atan(obj.v(i)/obj.u(i));
                obj.x(i) = obj.x(i-1) + obj.u(i)*dt;
                obj.y(i) = obj.y(i-1) + obj.v(i)*dt;
                 
                % Calculate dynamic pressure
                obj.q(i) = 0.5*obj.rho(i-1)*(obj.V(i-1)^2);
                 
                % Update density
                [obj.T(i), obj.rho(i)] = obj.CalculateRhoTemp(obj.y(i));
                
                % Update sound speed
                obj.c(i) = sqrt(1.4*Rg*obj.T(i));
                
                % Update gravity
                obj.g(i) = obj.CalculateGravity(obj.y(i));
                
                % Update Mach no.
                obj.M(i) = abs(obj.V(i))/obj.c(i);
                 
                if obj.y(i) < 0
                   obj.NStepEnd = i;
                   break
                end
                 
           end
            
           % Flight path angle in °
           obj.theta = obj.theta*(180/pi);
           
           % Dynamic pressure in kPa
           obj.q = obj.q./1000; 
           %% PREDICTED PERFORMANCE
           Vx = max(obj.V);
           Mx = max(obj.M);
           Yx = max(obj.y);
           Xx = max(obj.x);
           tx = max(obj.t);
           Qx = max(obj.q);

           [valx,idxx] = max(obj.x);
           [valy,idxy] = max(obj.y);
           tX = obj.t(idxx);
           tY = obj.t(idxy);

           disp(' ');
           formatSpec = 'Apogee is %6.3f m occuring at %5.3f seconds.\n';
           fprintf(formatSpec,Yx,tY)
           formatSpec = 'Landing Distance is %6.3f m occuring at %5.3f seconds.\n\n';
           fprintf(formatSpec,Xx,tX)
        end
       
       % Write data file
       function WriteDataFile(obj)
           if obj.mdot_constant == true
               result_dat_file = 'Result/' + obj.ID + "_Result_" + obj.launch_angle + "deg.txt";
           else
               text = "VariableMassFlow";
               result_dat_file = 'Result/' + obj.ID + "_Result_" + obj.launch_angle + "_deg_" + text + ".txt";
           end
           result_matrix = [obj.t(1:obj.NStepEnd) obj.x(1:obj.NStepEnd)/1000 obj.y(1:obj.NStepEnd)/1000 obj.V(1:obj.NStepEnd) obj.M(1:obj.NStepEnd) obj.thrust(1:obj.NStepEnd) ...
               obj.DvDt(1:obj.NStepEnd) obj.m(1:obj.NStepEnd) obj.mdot(1:obj.NStepEnd) obj.isp(1:obj.NStepEnd) obj.Cd(1:obj.NStepEnd) obj.q(1:obj.NStepEnd)];
           result_data = reshape(result_matrix, [], 12);
           dlmwrite(result_dat_file, 'Time(s),x(km),y(km),Velocity(m/s),Mach,Thrust(N),Acceleration(m/s2),Mass(kg),mdot(kg/s),Isp(s),Cd,DynPres(kPa)','delimiter','')
           dlmwrite(result_dat_file, result_data, '-append', 'delimiter', ',');
           notify_text = 'Results written for ' + obj.ID + ' at ' + obj.launch_angle + " degrees.\n ";
           fprintf(notify_text);
           fprintf("-----------------------------------------------------------------------------------\n");
       end
       
       % Reduce data by n times
       function WriteCompactDataFile(obj, n)
           if obj.mdot_constant == true
               result_dat_file = 'Result/' + obj.ID + "_Result_" + obj.launch_angle + "deg (Compact).txt";
           else
               text = "VariableMassFlow";
               result_dat_file = 'Result/' + obj.ID + "_Result_" + obj.launch_angle + "_deg_" + text + ".txt";
           end
           result_matrix = [obj.t(1:n:obj.NStepEnd) obj.x(1:n:obj.NStepEnd)/1000 obj.y(1:n:obj.NStepEnd)/1000 obj.V(1:n:obj.NStepEnd) obj.M(1:n:obj.NStepEnd) ...
               obj.thrust(1:n:obj.NStepEnd) obj.DvDt(1:n:obj.NStepEnd) obj.m(1:n:obj.NStepEnd) obj.mdot(1:n:obj.NStepEnd) obj.isp(1:n:obj.NStepEnd) obj.Cd(1:n:obj.NStepEnd) ...
               obj.q(1:n:obj.NStepEnd)];
           result_data = reshape(result_matrix, [], 12);
           dlmwrite(result_dat_file, 'Time(s),x(km),y(km),Velocity(m/s),Mach,Thrust(N),Acceleration(m/s2),Mass(kg),mdot(kg/s),Isp(s),Cd,DynPres(kPa)','delimiter','')
           dlmwrite(result_dat_file, result_data, '-append', 'delimiter', ',');
           notify_text = 'Compact results written for ' + obj.ID + ' at ' + obj.launch_angle + " degrees.\n ";
           fprintf(notify_text);
           fprintf("-----------------------------------------------------------------------------------\n");
       end
   end
end
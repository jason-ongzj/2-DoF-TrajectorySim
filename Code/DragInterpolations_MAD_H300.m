function [coeffdrag] = DragInterpolations_MAD_H300(velocity, altitude, time, tb)

drag_data = dlmread("MAD_H300/MAD_H300_DragData.txt", "\t",1,0);

% Mach No
mach_no = drag_data(:,1);

% Altitude 0m, full base drag
cdfull_0 = drag_data(:,3);

% Altitude 30000m, full base drag
cdfull_30000 = drag_data(:,4);

% Altitude 0m, no base drag
cdzero_0 = drag_data(:,2);

% Interpolate for Cd values at two stated altitudes, then interpolate for
% Cd value at a specific altitude

R = 8.3145;
gamma = 1.4;
M_air = 0.0289645;

[T,p,rho] = CalcAtmosQuantities(altitude);
sound_speed = sqrt(gamma*R*T/M_air);
mach_speed = velocity/sound_speed;

% Check if propellant is still available
if (time > tb) % Propellant is not available
    if (altitude > 30000)
        coeffdrag = interp1(mach_no, cdfull_30000, mach_speed);
    else
        coeffdrag = interp1(mach_no, cdfull_0, mach_speed);
    end
else % Propellant still burning
    coeffdrag = interp1(mach_no, cdzero_0, mach_speed);
end

end


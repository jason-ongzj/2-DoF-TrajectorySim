function [coeffdrag] = DragInterpolations_Dorado1S(velocity, altitude, time, tb)

drag_data = dlmread("Dorado_1S/Dorado1S_DragData.txt", "\t",1,0);

% Mach No
mach_no = drag_data(:,1);

% Altitude 0m, full base drag
cdfull_0 = drag_data(:,5);

% Altitude 10000m, full base drag
cdfull_10k = drag_data(:,6);

% Altitude 20000m, full base drag
cdfull_20k = drag_data(:,7);

% Altitude 30000m, full base drag
cdfull_30k = drag_data(:,8);

% Altitude 40000m, full base drag
cdfull_40k = drag_data(:,9);

% Altitude 0m, no base drag
cdzero_0 = drag_data(:,2);

% Altitude 5000m, no base drag
cdzero_10k = drag_data(:,3);

% Altitude 10000m, no base drag
cdzero_20k = drag_data(:, 4);

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
    if (altitude > 10000 && altitude < 20000)
        coeffdrag = interp1(mach_no, cdfull_10k, mach_speed);
    elseif (altitude > 20000 && altitude < 30000)
        coeffdrag = interp1(mach_no, cdfull_20k, mach_speed);
    elseif (altitude > 30000 && altitude < 40000)
        coeffdrag = interp1(mach_no, cdfull_30k, mach_speed);
    elseif( altitude > 40000)
        coeffdrag = interp1(mach_no, cdfull_40k, mach_speed);
    else
        coeffdrag = interp1(mach_no, cdfull_0, mach_speed);
    end
else % Propellant still burning
    if (altitude > 10000 && altitude < 20000)
        coeffdrag = interp1(mach_no, cdzero_10k, mach_speed);
    elseif (altitude > 20000)
        coeffdrag = interp1(mach_no, cdzero_20k, mach_speed);
    else
        coeffdrag = interp1(mach_no, cdzero_0, mach_speed);
    end
end

end


function [coeffdrag] = DragInterpolations_MAD(velocity, altitude, time, tb)

drag_data = dlmread("MAD/MAD_DragData.txt", "\t",1,0);

% Mach No
mach_no = drag_data(:,1);
% Altitude 0m, full base drag
cdfull_0 = drag_data(:,4);

% Altitude 10000m, full base drag
cdfull_10000 = drag_data(:,5);

% Altitude 30000m, full base drag
cdfull_30000 = drag_data(:,6);

% Altitude 45000m, full base drag
cdfull_45000 = drag_data(:,7);

% Altitude 60000m, full base drag
cdfull_60000 = drag_data(:,8);

% Altitude 0m, no base drag
cdzero_0 = drag_data(:,2);

% Altitude 10000m, no base drag
cdzero_10000 = drag_data(:,3);

% Interpolate for Cd values at two stated altitudes, then interpolate for
% Cd value at a specific altitude

R = 8.3145;
gamma = 1.4;
M_air = 0.0289645;

[T,p,rho] = CalcAtmosQuantities(altitude);
sound_speed = sqrt(gamma*R*T/M_air);
mach_speed = velocity/sound_speed;

% If propellant is still available
if (time > tb)
    if (altitude <= 10000)
        coeffdrag = interpolateCd(0, 10000, mach_no, cdfull_0, ...
            cdfull_10000, mach_speed, altitude);
    end

    if (altitude <= 30000 && altitude > 10000)
        coeffdrag = interpolateCd(10000, 30000, mach_no, cdfull_10000, ...
            cdfull_30000, mach_speed, altitude);
    end

    if (altitude <= 45000 && altitude > 30000)
        coeffdrag = interpolateCd(30000, 45000, mach_no, cdfull_30000, ...
            cdfull_45000, mach_speed, altitude);
    end
    
    if (altitude <= 60000 && altitude > 45000)
        coeffdrag = interpolateCd(45000, 60000, mach_no, cdfull_45000, ...
            cdfull_60000, mach_speed, altitude);
    end

    if (altitude > 60000)
        coeffdrag = interp1(mach_no, cdfull_60000, mach_speed);
    end
else
    if (altitude <= 10000)
        coeffdrag = interpolateCd(0, 10000, mach_no, cdzero_0, ...
            cdzero_10000, mach_speed, altitude);
    end
    if (altitude > 10000)
        coeffdrag = interp1(mach_no, cdzero_10000, mach_speed);
    end
end

end

function Cd_specific_alt = interpolateCd(low_alt, high_alt, mach_num, low_alt_Cd, ...
    high_alt_Cd, mach_speed, specific_alt)
    low_alt_interpolation = interp1(mach_num, low_alt_Cd, mach_speed);
    high_alt_interpolation = interp1(mach_num, high_alt_Cd, mach_speed);
    Cd_specific_alt = interp1([low_alt high_alt], [low_alt_interpolation high_alt_interpolation], specific_alt);
end


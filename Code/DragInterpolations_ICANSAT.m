function [coeffdrag] = DragInterpolations_ICANSAT(velocity, altitude, time, tb)

drag_data = dlmread("ICANSAT/ICANSAT_DragData.txt", "\t",1,0);

% Mach No
mach_no = drag_data(:,1);

% Full base drag
cd_full = drag_data(:,3);

% No base drag
cd_zero = drag_data(:,2);

R = 8.3145;
gamma = 1.4;
M_air = 0.0289645;

[T,p,rho] = CalcAtmosQuantities(altitude);
sound_speed = sqrt(gamma*R*T/M_air);

mach_speed = velocity/sound_speed;

if (time > tb)
    coeffdrag = interp1(mach_no, cd_full, mach_speed);
else
    coeffdrag = interp1(mach_no, cd_zero, mach_speed);
end

end
function [coeffdrag] = DragInterpolations_Spark(velocity, altitude)

spark_drag_data = dlmread("Spark/Spark_DragData.txt", "\t",1,0); 

R = 8.3145;
gamma = 1.4;
M_air = 0.0289645;

[T,p,rho] = CalcAtmosQuantities(altitude);
sound_speed = sqrt(gamma*R*T/M_air);

mach_speed = velocity/sound_speed;

mach = spark_drag_data(:,1);
drag = spark_drag_data(:,2);

coeffdrag = interp1(mach, drag, mach_speed);
end
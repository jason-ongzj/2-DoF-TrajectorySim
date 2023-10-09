function [t,p,rho] = CalcAtmosQuantities(h)
    hg = h;               % geometric alt in meters
    R = 287;              % Gas Constant
    re = 6.356766e6;      % radius of earth
    g0 = 9.8066;          % gravity
    h = re/(re+hg)*hg;

    % Altitude in meters
    h0 = 0.0;
    h1 = 11000.0;
    h2 = 25000.0;
    h3 = 47000;
    h4 = 53000;
    h5 = 79000;
    h6 = 90000;
    h7 = 105000;

    % Temperature in Kelvin.
    t0 = 288.16;
    t1 = 216.66;
    t2 = 216.66;
    t3 = 282.66;
    t4 = 282.66;
    t5 = 165.66;
    t6 = 165.66;
    t7 = 225.66;

    %%equations
    a01 = (t1-t0)/(h1-h0);  % slope of T/h in K/m for 0 to 11 km
    a23 = (t3-t2)/(h3-h2);  % slope of T/h in K/m for 25 to 47 km
    a45 = (t5-t4)/(h5-h4);  % slope of T/h in K/m for 53 to 79 km
    a67 = (t7-t6)/(h7-h6);  % slope of T/h in K/m for 90 to 105 km

    % Pressure in N/m^2
    p0 = 101325.0;
    p1 = p0*(t1/t0)^(-g0/(a01*R));
    p2 = p1*exp(-(g0/(R*t1))*(h2-h1));
    p3 = p2*(t3/t2)^(-g0/(a23*R));
    p4 = p3*exp(-(g0/(R*t3))*(h4-h3));
    p5 = p4*(t5/t4)^(-g0/(a45*R));
    p6 = p5*exp(-(g0/(R*t5))*(h6-h5));
    p7 = p6*(t7/t6)^(-g0/(a67*R));

    if h < h1
        t = t0+a01*h;
        p = p0*(t/t0)^(-g0/(a01*R));
    elseif h < h2
        t = t1;
        p= p1*exp(-(g0/(R*t))*(h-h1));
    elseif h < h3
        t = t2+a23*(h-h2);
        p = p2*(t/t2)^(-g0/(a23*R));
    elseif h < h4
        t = t3;
        p = p3*exp(-(g0/(R*t))*(h-h3));
    elseif h < h5
        t = t4+a45*(h-h4);
        p = p4*(t/t4)^(-g0/(a45*R));
    elseif h < h6
        t = t5;
        p = p5*exp(-(g0/(R*t))*(h-h5));
    elseif h < h7
        t = t6+a67*(h-h6);
        p = p6*(t/t6)^(-g0/(a67*R));
    else
        t= t7;
        p = p7*exp(-(g0/(R*t))*(h-h7));
    end
    rho=p/(R*t); % Density in kg/m^3
end
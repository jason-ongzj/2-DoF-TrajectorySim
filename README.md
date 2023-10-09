## 2-DoF Rocket Trajectory Simulation Program
This 2-DoF rocket trajectory simulation is reproduced from the Master's thesis by Zachary Doucet. The original code has been rewritten in a OOP form so that it can be reused in a simple manner for future trajectories of single-stage rockets. Drag interpolations are included as standalone files for each rocket since data format is non-similar in nature.

A validation test has been made and compared against the 6-DoF software ASTOS, from which the results of the MAD rocket have been obtained. Figures shown below are the comparisons of the altitude, Mach number and the corrected thrust curve for both 2-DoF and 6-DoF simulations.

![](https://git.equatorial.space/jason.ong/2-DoF-TrajectorySim/raw/branch/master/2-DoF%20vs%20Astos%206-Dof.png)

Input settings used for the 2-DoF simulation for validation are found in the MAD_Validation.m file. A similar workflow has now been created for the ICANSAT data to demonstrate code-reuseability.

Comments:
1. Numerical calculations are adapted based on the Angle_Tests_XY.m program used in the original code by Zachery Doucet.
2. Launch tower deflection is not included.
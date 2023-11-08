## 2-DoF Rocket Trajectory Simulation Program
This 2-DoF rocket trajectory simulation is reproduced from the Master's thesis by Zachary Doucet. The original code has been rewritten in a object oriented manner so that it can be reused in a simple manner for future trajectories of single-stage rockets. Drag interpolations are included as standalone files for each rocket since data format is non-similar in nature.

A validation test has been made and compared against the 6-DoF software ASTOS, from which the results of the Dorado-1S rocket have been obtained. Figures shown below are the comparisons of the altitude, Mach number and the corrected thrust curve for both 2-DoF and 6-DoF simulations.

<p align="middle">
  <img src="Code/Dorado_1S/Validation Data/ValidationData.png" width="900">
</p>

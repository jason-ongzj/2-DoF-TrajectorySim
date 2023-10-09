mfile_name          = mfilename('fullpath');
[pathstr,name,ext]  = fileparts(mfile_name);
cd(pathstr);

cd ICANSAT/V0
ICANSAT

cd ../V1
ICANSAT_V1

cd ../V2
ICANSAT_V2

cd ../../MAD
MAD_Validation

cd(pathstr);
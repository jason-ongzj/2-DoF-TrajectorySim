mfile_name          = mfilename('fullpath');
[pathstr,name,ext]  = fileparts(mfile_name);
cd(pathstr);

cd ICANSAT/V0/Result
delete *.txt
fprintf("ICANSAT V0 result files deleted.\n");

cd ../../V1/Result
delete *.txt
fprintf("ICANSAT V1 result files deleted.\n");

cd ../../V2/Result
delete *.txt
fprintf("ICANSAT V2 result files deleted.\n");

cd ../../../MAD/Result
delete *.txt
fprintf("MAD result files deleted.\n");

cd(pathstr);
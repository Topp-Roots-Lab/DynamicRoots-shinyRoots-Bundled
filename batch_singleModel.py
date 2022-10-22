import os
import re
import shutil

dynamicRoots = "dynamicRoots\\dynamic_roots_64.exe"
folder_out = "outfiles\\"
folder_res = "res\\"
xf_name = "temp.xf"
txt_name = "temp.txt"

if not os.path.exists(folder_res):
    os.makedirs(folder_res)
	
for fname in [out for out in os.listdir(folder_out) if out.endswith(".out")]:
	item_name = os.path.splitext(fname)[0];
	command = "out2obj.exe " + folder_out + fname;
	print(command, "/n");
	os.system(command);
	fname_obj = fname.replace('.out', '.obj');
	folder_resx = folder_res + item_name;
	if not os.path.exists(folder_resx):
		os.makedirs(folder_resx)
	command = dynamicRoots + " " + folder_resx + " " + folder_out + fname_obj + " " + folder_out + fname_obj;
	
	xf_newname = folder_out + item_name + "_a4pcs.xf";
	txt_newname = folder_out + item_name + "_a4pcs_ma.txt";
	shutil.copy(xf_name, xf_newname);
	shutil.copy(txt_name, txt_newname);
	print(command, "/n");
	os.system(command);

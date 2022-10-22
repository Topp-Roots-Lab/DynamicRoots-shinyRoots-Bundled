import os
import time
import re

folder = "./"
#folder = os.path.abspath('./')
folder_res = "./res\\"
#folder_res = folder + "\\res\\"
#dynamicRoots="dynamicRoots\\64\\dynamic_roots_64.exe";
dynamicRoots="dynamicRoots\\dynamic_roots_64.exe";
	
all_names=" ";
fid_prev=" ";

print "folder_res", folder_res


if not os.path.exists(folder_res):
    os.makedirs(folder_res)

start = time.clock()

plantname_re=re.compile("p\d+");
for fname in [out for out in os.listdir(folder) if out.endswith(".out")]:
	namesearch_res = re.search(plantname_re,fname);
	plantname=namesearch_res.group();
	fid=fname[:fname.find(plantname)]+plantname;
	fid
	#fid = fname[:fname.find("d")];
	print(fid, " ", fid_prev, "\n");
	if fid!=fid_prev:
		fname1=folder+fname; #this is the first file
		command = "out2obj.exe " + fname1;
		print(command,"\n");
		os.system(command);						
		if all_names!= " ":		
			command = "dynamicRoots\\dynamic_roots_64.exe " + folder_res + " " + all_names;
			print(command,"\n");
			os.system(command)
			fname1=folder+fname; #this is the first file
			command = "out2obj.exe " + fname1;
			print(command,"\n");
			os.system(command);				
		all_names=" ";
		all_names=all_names+folder+fname.replace ( '.out', '.obj')+" ";
	else:
		fnamex=folder+fname;
		command = "out2obj.exe " + fnamex;
		print(command,"\n");
		os.system(command);	
		fnamex_a_obj=fnamex.replace ( '.out', '_a4pcs.obj');		
		command = "4cps\\4PCS.exe " + fname1 + " " + fnamex + " " + fnamex_a_obj; #+ " > " + fnamex.replace ( '.out', '_a4pcs_ma.txt');
		print(command,"\n");
		os.system(command);
		command = "icp\\mesh_align.exe " + fname1.replace ( '.out', '.obj') + " " + fnamex_a_obj;
		print(command,"\n");
		os.system(command);
		fname_m=fnamex_a_obj.replace ( '.obj', '.xf');
		fname_tr=fnamex_a_obj.replace ( '.obj', '_icp.obj');
		command = "transform.exe " + fname_m + " " + fnamex_a_obj + " " + fname_tr;
		print(command,"\n");
		os.system(command);
		all_names=all_names+folder+fname.replace ( '.out', '.obj')+" ";
	fid_prev=fid;
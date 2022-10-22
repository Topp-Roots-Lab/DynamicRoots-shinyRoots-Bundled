setwd("E:/dynamic_roots")

args <- commandArgs(TRUE)
dynamicRoots <- "dynamicRoots\\dynamic_roots_64.exe"
inputfiles_path <- "to_process\\"

xf_name <- "temp.xf"
txt_name <- "temp.txt"

timestamp <- strftime(as.character(Sys.time()), format = "%Y-%m-%d_%H-%M-%S")

if ( length(args)==0 ) {
  foldername <- timestamp
} else {
  foldername <- paste(args[1], "_", timestamp, sep = "")
}

message("\nOutput Folder Name: ", foldername, "\n")

outfiles_path <- paste("processedFiles\\", foldername, "\\", sep = "")
resfiles_path <- paste("dynamicRootsOutputs\\", foldername, "\\", sep = "") 
traitfiles_path <- paste("dynamicRootsTraitsFiles\\", foldername, "\\", sep = "")
if (!dir.exists(outfiles_path))
  dir.create(outfiles_path, showWarnings = TRUE)
if (!dir.exists(resfiles_path))
  dir.create(resfiles_path, showWarnings = TRUE)
if (!dir.exists(traitfiles_path))
  dir.create(traitfiles_path, showWarnings = TRUE)
configfiles_path <- paste(traitfiles_path, "config\\", sep = "")
if (!dir.exists(configfiles_path))
  dir.create(configfiles_path, showWarnings = TRUE)


originalfilenames <- list.files(path = inputfiles_path, pattern = ".out", full.names = TRUE)
nfiles <- length(originalfilenames)

if ( nfiles != 0 )
{
  for ( i in 1:length(originalfilenames) ) 
  {
    # filename <- sub("to_process", "processedFiles", originalfilenames[i])
    filename <- paste(outfiles_path, basename(originalfilenames[i]), sep = "")
	
    file.rename(originalfilenames[i], filename)
    fnamex <- strsplit(filename, "\\.")[[1]][1];
    command <- paste("out2obj.exe ", filename, sep = "");
    system(command);
    
    resfiles_pathx <- paste(resfiles_path, basename(fnamex), sep = "");
    if (!dir.exists(resfiles_pathx))
      dir.create(resfiles_pathx, showWarnings = TRUE);
    fnamex_obj <-  gsub(".out", ".obj", filename);
    
    xf_newname <- gsub(".out", "_a4pcs.xf", filename);
    txt_newname <- gsub(".out", "_a4pcs_ma.txt", filename);
    file.copy(xf_name, xf_newname);
    file.copy(txt_name, txt_newname);
    command <- paste(dynamicRoots, resfiles_pathx, fnamex_obj, fnamex_obj, sep = " ");
    system(command);
    
    file.remove(xf_newname)
    file.remove(txt_newname)
    file.remove(fnamex_obj)
	
	xmlname <- gsub(".out", ".xml", originalfilenames[i])
	xml_newname <- paste(configfiles_path, basename(xmlname), sep = "")
	file.rename(xmlname, xml_newname)
    
    trait_filename <- paste(resfiles_pathx, "\\", basename(fnamex), "_per_branch_dynamics.txt", sep = "");
    file.copy(trait_filename, traitfiles_path, recursive = FALSE)
  }
}



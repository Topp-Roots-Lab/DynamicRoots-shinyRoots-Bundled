# FirstOrderRootLength <- c()
# FirstOrderRootVolume <- c()
setwd("C:/dynamic_roots")
library(matrixStats, lib.loc = "C:/Program Files/R-3.2.3/library")
library(XML, lib.loc = "C:/Program Files/R-3.2.3/library")
args <- commandArgs(TRUE)
path <- "C:\\dynamic_roots\\dynamicRootsTraitsFiles"

TraitFilesPath <- choose.dir(getwd(), "Choose traits folder")   #"dynamicRootsTraitsFiles\\"
ConfigFilesPath <- paste(TraitFilesPath, "\\config\\", sep = "")

cat("Input the threshold value: ")
input_con <- file("stdin")
open(input_con)
input_thre <- as.numeric(readLines(con = input_con, n = 1))
close(input_con)
#threshold <- as.numeric(readline(prompt = "Input the threshold value: "))
if (is.na(input_thre))
  input_thre <- 0

TraitFileNames <- list.files(path = TraitFilesPath, pattern = ".txt", full.names = TRUE)
NumofFiles <- length(TraitFileNames)

FileNames <- c()
TotalRootLength <- c()
TotalRootVolume <- c()
TotalRootNumber <- c()
TotalRootDepth <- c()
Scale <- c()
Resolution <- c()
Threshold <- c()
MeanRootTraits <- matrix(data = NA, nrow = NumofFiles, ncol = 7)
MedianRootTraits <- matrix(data = NA, nrow = NumofFiles, ncol = 7)
LateralRootTraits <- matrix(data = NA, nrow = NumofFiles, ncol = 18)
FirstOrderRootTraits <- matrix(data = NA, nrow = NumofFiles, ncol = 22)
PrimaryRootTraits <- matrix(data = NA, nrow = NumofFiles, ncol = 6)

for ( i in 1:NumofFiles )
{
  data <- read.csv(TraitFileNames[i], header = FALSE, sep = "\t")
  data <- data[-ncol(data)]
  
  fnamex <- strsplit(TraitFileNames[i], "\\.")[[1]][1];
  FileNames[i] <- sub("_per_branch_dynamics", "", basename(fnamex))
  
  configFName <- paste(ConfigFilesPath, FileNames[i], ".xml", sep = "")
  
  if (file.exists(configFName))
  {
    config <- xmlToList(xmlParse(configFName))
    Scale[i] <- as.numeric(config[["scale"]])
    Resolution[i] <- as.numeric(config[["resolution"]])
  } else
  {
    Scale[i] <- 1
    Resolution[i] <- 1
  }
  
  voxelSize <- Scale[i] * Resolution[i] 
  
  traits <- data[, seq(2, ncol(data), 2)]
  TraitNames <- data[1, seq(1, ncol(data), 2)]
  colnames(traits) <- as.matrix(TraitNames)
  
  ##remove noises
  Threshold[i] <- input_thre/Resolution[i]
  traits <- traits[traits[, 7] > Threshold[i], ]
  
  ### Av_radius 1.#J
  if(is.factor(traits[, 12]))
    traits[, 12] <- as.numeric(levels(traits[, 12])[traits[, 12]])
  
  traits[, 4] <- traits[, 4] * voxelSize
  traits[, 6] <- traits[, 6] * voxelSize * voxelSize * voxelSize
  traits[, 7] <- traits[, 7] * voxelSize
  traits[, 8] <- traits[, 8] * voxelSize
  traits[, 9] <- traits[, 9] * voxelSize
  traits[, 12] <- traits[, 12] * voxelSize
  traits[, 13] <- traits[, 13] - 90
  TotalRootVolume[i] <- sum(traits[, 6])
  TotalRootLength[i] <- sum(traits[, 7])
  TotalRootNumber[i] <- nrow(traits)
  TotalRootDepth[i] <- sum(traits[, 9])
  
  MeanRootTraits[i, ] <- colMeans(traits[, c(6, 7, 9, 11, 12, 13, 16)], na.rm = TRUE)
  MedianRootTraits[i, ] <- colMedians(as.matrix(traits[, c(6, 7, 9, 11, 12, 13, 16)]), na.rm = TRUE)
  
  #number of lateral roots
  LateralRootTraits[i, 1] <- nrow(traits[traits$Class %in% " Lateral", ])
  #total lateral root volume, length
  if (LateralRootTraits[i, 1] > 0)
  {
    LateralRootTraits[i, 2:4] <- colSums(traits[traits$Class %in% " Lateral", c(6, 7, 9)], na.rm = TRUE)
    LateralRootTraits[i, 5:11] <- colMeans(traits[traits$Class %in% " Lateral", 
                                                  c(6, 7, 9, 11, 12, 13, 16)], na.rm = TRUE)
    LateralRootTraits[i, 12:18] <- colMedians(as.matrix(traits[traits$Class %in% " Lateral",
                                                               c(6, 7, 9, 11, 12, 13, 16)]), na.rm = TRUE)
  } else 
  {
    LateralRootTraits[i, ] <- 0
  }
  
  #number of first Order lateral roots
  FirstOrderRoot <- traits[traits$H == 1 & traits$Class %in% " Lateral", ]
  FirstOrderRootTraits[i, 1] <- nrow(FirstOrderRoot)
  PrimaryRoot <- traits[traits$Class %in% " Primary", ]
  #first order lateral root traits
  if (FirstOrderRootTraits[i, 1] > 0)
  {
    FirstOrderRootTraits[i, 2:4] <- colSums(FirstOrderRoot[, c(6, 7, 9)], na.rm = TRUE)
    FirstOrderRootTraits[i, 5:11] <- colMeans(FirstOrderRoot[, c(6, 7, 9, 11, 12, 13, 16)], na.rm = TRUE)
    FirstOrderRootTraits[i, 12:18] <- colMedians(as.matrix(FirstOrderRoot[, c(6, 7, 9, 11, 12, 13, 16)]), na.rm = TRUE)
    primaryRootLength <- traits[traits$Class %in% " Primary", 7]
    FirstOrderRootTraits[i, 19] <- FirstOrderRootTraits[i, 1] / primaryRootLength
    fork_g_depth <- sort(FirstOrderRoot[, 4])
    FirstOrderRootTraits[i, 20] <- FirstOrderRootTraits[i, 1] / (max(fork_g_depth) - min(fork_g_depth))
    #inter-branch distance
    FirstOrderRootTraits[i, 21] <- mean(fork_g_depth[-1] - fork_g_depth[-length(fork_g_depth)])
    FirstOrderRootTraits[i, 22] <- median(fork_g_depth[-1] - fork_g_depth[-length(fork_g_depth)])
  } else
  {
    FirstOrderRootTraits[i, ] <- 0
  }
  
  PrimaryRootTraits[i, ] <- colSums(PrimaryRoot[1, c(6, 7, 9, 11, 12, 13)])
  
}



OutputResults <- data.frame(FileNames, Scale, Resolution, Threshold, TotalRootNumber, TotalRootVolume, TotalRootLength, 
                            TotalRootDepth, MeanRootTraits, MedianRootTraits, LateralRootTraits,
                            FirstOrderRootTraits, PrimaryRootTraits)

colnames(OutputResults) <- c("FileNames", "Scale(mm)", "Resolution", "Threshold", "TotalRootNumber", "TotalRootVolume(mm^3)", "TotalRootLength(mm)", 
                             "TotalRootDepth(mm)", "MeanRootVolume(mm^3)", "MeanRootLength(mm)", "MeanRootDepth(mm)", "MeanRootTortuosity",
                             "MeanRootRadius(mm)", "MeanRootSoilAngle", "MeanRootBranchingAngle",
                             "MedianRootVolume(mm^3)", "MedianRootLength(mm)", "MedianRootDepth(mm)", "MedianRootTortuosity",
                             "MedianRootRadius(mm)", "MedianRootSoilAngle", "MedianRootBranchingAngle",
                             "TotalLateralRootNumber", "TotalLateralRootVolume(mm^3)", "TotalLateralRootLength(mm)", "TotalLateralRootDepth(mm)",
                             "MeanLateralRootVolume(mm^3)", "MeanLateralRootLength(mm)", "MeanLateralRootDepth(mm)", "MeanLateralRootTortuosity",
                             "MeanLateralRootRadius(mm)", "MeanLateralRootSoilAngle", "MeanLateralRootBranchingAngle",
                             "MedianLateralRootVolume(mm^3)", "MedianLateralRootLength(mm)", "MedianLateralRootDepth(mm)", "MedianLateralRootTortuosity",
                             "MedianLateralRootRadius(mm)", "MedianLateralRootSoilAngle", "MedianLateralRootBranchingAngle",
                             "TotalFirstOrderLateralRootNumber", "TotalFirstOrderLateralRootVolume(mm^3)", "TotalFirstOrderLateralRootLength(mm)",
                             "TotalFirstOrderLateralRootDepth(mm)", "MeanFirstOrderLateralRootVolume(mm^3)", "MeanFirstOrderLateralRootLength(mm)", 
                             "MeanFirstOrderLateralRootDepth(mm)", "MeanFirstOrderLateralRootTortuosity", "MeanFirstOrderLateralRootRadius(mm)", 
                             "MeanFirstOrderLateralRootSoilAngle", "MeanFirstOrderLateralRootBranchingAngle", "MedianFirstOrderLateralRootVolume(mm^3)", 
                             "MedianFirstOrderLateralRootLength(mm)", "MedianFirstOrderLateralRootDepth(mm)", "MedianFirstOrderLateralRootTortuosity",
                             "MedianFirstOrderLateralRootRadius(mm)", "MedianFirstOrderLateralRootSoilAngle", "MedianFirstOrderLateralRootBranchingAngle",
                             "DensityFirstOrderLateralRoot_TL", "DensityFirstOrderLateralRoot_BRTL",
                             "MeanInterbranchDistance(mm)", "MedianInterbranchDistance(mm)",
                             "PrimaryRootVolume(mm^3)", "PrimaryRootLength(mm)", "PrimaryRootDepth(mm)",
                             "PrimaryRootTortuosity", "PrimaryRootRadius(mm)", "PrimaryRootSoilAngle")


if ( length(args) == 0 ) {
  resultFileName <- paste(TraitFilesPath, "\\", basename(TraitFilesPath), ".csv", sep = "")  
  write.csv(OutputResults, file = resultFileName, row.names = FALSE)
  #   write.csv(OutputResults, file = choose.files(caption = "Choose file name for saving traits",
  #                                                  filters = c("Comma Delimited Files (.csv)","*.csv")), 
  #               row.names = FALSE)
} else {
  write.csv(OutputResults, file = args, row.names = FALSE)
}


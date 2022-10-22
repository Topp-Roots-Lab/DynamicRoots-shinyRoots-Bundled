# FirstOrderRootLength <- c()
# FirstOrderRootVolume <- c()
library(matrixStats)
args <- commandArgs(TRUE)
path <- "C:\\dynamic_roots\\dynamicRootsTraitsFiles"

TraitFilesPath <- choose.dir(getwd(), "Choose traits folder")   #"dynamicRootsTraitsFiles\\"
TraitFileNames <- list.files(path = TraitFilesPath, pattern = ".txt", full.names = TRUE)
NumofFiles <- length(TraitFileNames)

FileNames <- c()
TotalRootLength <- c()
TotalRootVolume <- c()
TotalRootNumber <- c()
TotalRootDepth <- c()
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
  
  traits <- data[, seq(2, ncol(data), 2)]
  TraitNames <- data[1, seq(1, ncol(data), 2)]
  colnames(traits) <- as.matrix(TraitNames)
  
  ##remove noises
  # traits <- traits[traits[, 6] > 50 & traits[, 6] > 5, ]
  
  ### Av_radius 1.#J
  if(is.factor(traits[, 12]))
    traits[, 12] <- as.numeric(levels(traits[, 12])[traits[, 12]])

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



OutputResults <- data.frame(FileNames, TotalRootNumber, TotalRootVolume, TotalRootLength, 
                            TotalRootDepth, MeanRootTraits, MedianRootTraits, LateralRootTraits,
                            FirstOrderRootTraits, PrimaryRootTraits)

colnames(OutputResults) <- c("FileNames", "TotalRootNumber", "TotalRootVolume", "TotalRootLength", 
                             "TotalRootDepth", "MeanRootVolume", "MeanRootLength", "MeanRootDepth", "MeanRootTortuosity",
                             "MeanRootRadius", "MeanRootSoilAngle", "MeanRootBranchingAngle",
                             "MedianRootVolume", "MedianRootLength", "MedianRootDepth", "MedianRootTortuosity",
                             "MedianRootRadius", "MedianRootSoilAngle", "MedianRootBranchingAngle",
                             "TotalLateralRootNumber", "TotalLateralRootVolume", "TotalLateralRootLength", "TotalLateralRootDepth",
                             "MeanLateralRootVolume", "MeanLateralRootLength", "MeanLateralRootDepth", "MeanLateralRootTortuosity",
                             "MeanLateralRootRadius", "MeanLateralRootSoilAngle", "MeanLateralRootBranchingAngle",
                             "MedianLateralRootVolume", "MedianLateralRootLength", "MedianLateralRootDepth", "MedianLateralRootTortuosity",
                             "MedianLateralRootRadius", "MedianLateralRootSoilAngle", "MedianLateralRootBranchingAngle",
                             "TotalFirstOrderLateralRootNumber", "TotalFirstOrderLateralRootVolume", "TotalFirstOrderLateralRootLength",
                             "TotalFirstOrderLateralRootDepth", "MeanFirstOrderLateralRootVolume", "MeanFirstOrderLateralRootLength", 
                             "MeanFirstOrderLateralRootDepth", "MeanFirstOrderLateralRootTortuosity", "MeanFirstOrderLateralRootRadius", 
                             "MeanFirstOrderLateralRootSoilAngle", "MeanFirstOrderLateralRootBranchingAngle", "MedianFirstOrderLateralRootVolume", 
                             "MedianFirstOrderLateralRootLength", "MedianFirstOrderLateralRootDepth", "MedianFirstOrderLateralRootTortuosity",
                             "MedianFirstOrderLateralRootRadius", "MedianFirstOrderLateralRootSoilAngle", "MedianFirstOrderLateralRootBranchingAngle",
                             "DensityFirstOrderLateralRoot_TL", "DensityFirstOrderLateralRoot_BRTL",
                             "MeanInterbranchDistance", "MedianInterbranchDistance",
                             "PrimaryRootVolume", "PrimaryRootLength", "PrimaryRootDepth",
                             "PrimaryRootTortuosity", "PrimaryRootRadius", "PrimaryRootSoilAngle")


if ( length(args) == 0 ) {
  resultFileName <- paste(TraitFilesPath, "\\", basename(TraitFilesPath), ".csv", sep = "")  
  write.csv(OutputResults, file = resultFileName, row.names = FALSE)
#   write.csv(OutputResults, file = choose.files(caption = "Choose file name for saving traits",
#                                                  filters = c("Comma Delimited Files (.csv)","*.csv")), 
#               row.names = FALSE)
} else {
    write.csv(OutputResults, file = args, row.names = FALSE)
}

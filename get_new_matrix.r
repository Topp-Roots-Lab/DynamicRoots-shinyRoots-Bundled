ref_dir <- "C:/Users/topplab/Downloads/dynamic_roots/TaGNSp0014_d13upsidedown/corrected/TaGNSp0014d13_mgriffiths_2021-04-20_19-37-14_rootwork"

input_dir <- "C:/Users/topplab/Downloads/dynamic_roots/TaGNSp0014_d13upsidedown/d13ori-d17/"
input_file <- "TaGNSp0014d17_mgriffiths_2021-04-21_09-48-58_rootwork"

output_dir <- "C:/Users/topplab/Downloads/dynamic_roots/TaGNSp0014_d13upsidedown/corrected/"
m_icp_ref <- read.table(paste0(ref_dir, "_a4pcs_ma.txt"),
                    header = FALSE)

m_4cps_ref <- read.table(paste0(ref_dir, "_a4pcs.xf"),
                     header = FALSE)

m_4cps_output <- data.matrix(m_4cps_ref)%*%data.matrix(m_icp_ref)
write.table(m_4cps_output, paste0(output_dir, input_file, "_a4pcs.xf"), row.names = FALSE,
            col.names = FALSE, quote = FALSE)



m_icp_input <- read.table(paste0(input_dir, input_file, "_a4pcs_ma.txt"),
                        header = FALSE)
m_4cps_input <- read.table(paste0(input_dir, input_file, "_a4pcs.xf"),
                         header = FALSE)

m_icp_output <- data.matrix(m_4cps_input)%*%data.matrix(m_icp_input)
write.table(m_icp_output, paste0(output_dir, input_file, "_a4pcs_ma.txt"), row.names = FALSE,
            col.names = FALSE, quote = FALSE)


########check alignment###############

m_icp <- read.table(paste0(output_dir, input_file, "_a4pcs_ma.txt"),
                    header = FALSE)
m_icp <- data.matrix(m_icp)

m_4cps <- read.table(paste0(output_dir, input_file, "_a4pcs.xf"),
                     header = FALSE)
m_4cps <- data.matrix(m_4cps)

data <- read.csv(paste0(output_dir, input_file, ".out"), header = FALSE, sep = " ")

coordinates <- data.matrix(data[-c(1,2), ])
coordinates <- cbind(coordinates, 1)
a4pcs <- m_icp%*%t(coordinates)
a4pcs_icp <- m_4cps%*%(a4pcs)

results <- t(a4pcs_icp)
write.table(cbind(rep("v", nrow(results)), results[, -4]), paste0(output_dir, input_file, "_a4pcs_icp.obj"), row.names = FALSE,
            col.names = FALSE, quote = FALSE)
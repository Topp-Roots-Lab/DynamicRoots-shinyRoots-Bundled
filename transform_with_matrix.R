
a4pcs_ma.txt <- "C:/Users/topplab/Downloads/dynamic_roots/d05-d09/TaGNSp0006d09_mgriffiths_2021-03-17_15-06-26_rootwork_a4pcs_ma.txt"
a4pcs.xf <- "C:/Users/topplab/Downloads/dynamic_roots/d05-d09/TaGNSp0006d09_mgriffiths_2021-03-17_15-06-26_rootwork_a4pcs.xf"
ori_out <- "C:/Users/topplab/Downloads/dynamic_roots/d05-d09/TaGNSp0006d09_mgriffiths_2021-03-17_15-06-26_rootwork_ori.out"
aligned_out <- "C:/Users/topplab/Downloads/dynamic_roots/d05-d09/TaGNSp0006d09_mgriffiths_2021-03-17_15-06-26_rootwork_aligned.out"

m_icp <- read.table(a4pcs_ma.txt,
                    header = FALSE)
m_icp <- data.matrix(m_icp)

m_4cps <- read.table(a4pcs.xf,
                     header = FALSE)
m_4cps <- data.matrix(m_4cps)

data <- read.csv(ori_out, header = FALSE, sep = " ")

coordinates <- data.matrix(data[-c(1,2), ])
coordinates <- cbind(coordinates, 1)
a4pcs <- m_icp%*%t(coordinates)
a4pcs_icp <- m_4cps%*%(a4pcs)

results <- t(a4pcs_icp)

write.table(0.15, aligned_out, row.names = FALSE,
            col.names = FALSE, quote = FALSE)
write.table(nrow(results), aligned_out, append = TRUE, row.names = FALSE,
            col.names = FALSE, quote = FALSE)
write.table(results[, -4], aligned_out, append = TRUE, row.names = FALSE,
            col.names = FALSE, quote = FALSE)
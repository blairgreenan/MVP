# plot_MVP.R
# Blair Greenan
# Fisheries and Oceans Canada
# 18 June 2023
#
# Description: this script generates a plot of the RV NB Palmer MVP data
#
# load libraries
library(tidyverse)
library(cmocean)
library(viridis)
library(patchwork)
library(plot3D)
# library(viridisLite)
library(plotly)


######## Load the Rdata file
load("MVP.RData")

# Adjust the longitudes as they or 0 to 360
neg_lon <- which(MVP_tidy_tibble$lon<0)
MVP_tidy_tibble$lon[neg_lon] <- 360 + MVP_tidy_tibble$lon[neg_lon]

# Select Start and End time for plot
Start_time <- as.POSIXct("2012-01-22", tz="UTC")
End_time <- as.POSIXct("2012-01-25", tz="UTC")
# Get the index values for the range of times
MVP_survey_time <- which(MVP_tidy_tibble$daten>=Start_time & MVP_tidy_tibble$daten<=End_time)

# Plot the lat & lon of the MVP casts
dev.new()
plot(MVP_tidy_tibble$lon[MVP_survey_time],MVP_tidy_tibble$lat[MVP_survey_time])

# Create a 3D scatter plot using the plotly library
fig <- plot_ly(MVP_tidy_tibble, x = ~lon[MVP_survey_time], y = ~lat[MVP_survey_time], z = ~pres[MVP_survey_time]*-1, color = ~temp[MVP_survey_time])
fig <- fig %>% add_markers(size=1, opacity=1)
fig
# I am having issues with changing the opacity of the markers
# I am having issues with figuring out how to save a high-resolution bitmap of the figure

# Create a 3D scatter plot using the Plot3D library
pdf("MVP_Temperature_Ross_Ice_Shelf.pdf")
scatter3D(MVP_tidy_tibble$lon[MVP_survey_time], MVP_tidy_tibble$lat[MVP_survey_time], -1*MVP_tidy_tibble$pres[MVP_survey_time], colvar = MVP_tidy_tibble$temp[MVP_survey_time], 
          phi = 45, theta = 45, col = viridis(256), pch = 19, cex = 0.5, cex.main = 2, 
          cex.axis = 0.75, cex.lab = 0.75, xlab = "Longitude", ylab = "Latitude", zlab = "Depth (m)", 
          main = "Temperature", ticktype = "detailed")
dev.off()

# Create a 3D scatter plot using the Plot3D library
png(filename = "MVP_Temperature_Ross_Ice_Shelf.png", width = 2000, height = 2000, units = "px")
scatter3D(MVP_tidy_tibble$lon[MVP_survey_time], MVP_tidy_tibble$lat[MVP_survey_time], -1*MVP_tidy_tibble$pres[MVP_survey_time], colvar = MVP_tidy_tibble$temp[MVP_survey_time], 
          phi = 45, theta = 45, col = viridis(256), pch = 19, cex = 2, cex.main = 5, 
          cex.axis = 4, cex.lab = 4, cex.colorbar = 4, xlab = "Longitude", ylab = "Latitude", zlab = "Depth (m)", 
          main = "Temperature", ticktype = "detailed")
dev.off()


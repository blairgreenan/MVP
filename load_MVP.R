# load_MVP.R
# Blair Greenan
# Fisheries and Oceans Canada
# 16 June 2023
#
# Description: this script load the Matlab .mat file for the RV NB Palmer MVP data
# and reformats it to a tidy data set and then saves the result to an Rdata file
# for use in other analysis scripts
#
# load libraries
library(R.matlab)
library(R.oo)
library(tidyverse)

MVP_data <- readMat("MVP_RossSea2011_2012_despiked.mat")

kk <- TRUE # logical for first time through the loop


# 605 MVP casts from Ross Sea mission
for (ii in 1:605) {
  # find the length of the pressure vector for each cast
  for (jj in 1:lengths(MVP_data$MVP[5,ii,1])) {
    if (kk) {
      # set the logical to FALSE
      kk <- FALSE
      MVP_tidy <- c(MVP_data$MVP[1,ii,1],MVP_data$MVP[2,ii,1],MVP_data$MVP[3,ii,1],
                    MVP_data$MVP[4,ii,1],MVP_data$MVP[5,ii,1]$pres[jj],MVP_data$MVP[6,ii,1]$temp[jj],
                    MVP_data$MVP[7,ii,1]$cond[jj],MVP_data$MVP[8,ii,1]$sal[jj], MVP_data$MVP[9,ii,1]$sigmat[jj],
                    MVP_data$MVP[10,ii,1]$potDens[jj],MVP_data$MVP[11,ii,1]$chl[jj],MVP_data$MVP[12,ii,1]$lopc[jj])
      # Add names to the data columns - the metadata column names seem to carry over, so no need to name
      names(MVP_tidy)[5] <- "pres"
      names(MVP_tidy)[6] <- "temp"
      names(MVP_tidy)[7] <- "cond"
      names(MVP_tidy)[8] <- "sal"
      names(MVP_tidy)[9] <- "sigmat"
      names(MVP_tidy)[10] <- "potDens"
      names(MVP_tidy)[11] <- "chl"
      names(MVP_tidy)[12] <- "lopc"      
    } else {
      # Merge the observation to the tidy data set
      MVP_tidy$bottomDepth <- c(MVP_tidy$bottomDepth,as.numeric(MVP_data$MVP[1,ii,1]))      
      MVP_tidy$lat <- c(MVP_tidy$lat,as.numeric(MVP_data$MVP[2,ii,1]))      
      MVP_tidy$lon <- c(MVP_tidy$lon,as.numeric(MVP_data$MVP[3,ii,1]))      
      MVP_tidy$daten <- c(MVP_tidy$daten,as.numeric(MVP_data$MVP[4,ii,1]))      
      MVP_tidy$pres <- c(MVP_tidy$pres,as.numeric(MVP_data$MVP[5,ii,1]$pres[jj]))      
      MVP_tidy$temp <- c(MVP_tidy$temp,as.numeric(MVP_data$MVP[6,ii,1]$temp[jj]))      
      MVP_tidy$cond <- c(MVP_tidy$cond,as.numeric(MVP_data$MVP[7,ii,1]$cond[jj]))      
      MVP_tidy$sal <- c(MVP_tidy$sal,as.numeric(MVP_data$MVP[8,ii,1]$sal[jj]))      
      MVP_tidy$sigmat <- c(MVP_tidy$sigmat,as.numeric(MVP_data$MVP[9,ii,1]$sigmat[jj]))      
      MVP_tidy$potDens <- c(MVP_tidy$potDens,as.numeric(MVP_data$MVP[10,ii,1]$potDens[jj]))      
      MVP_tidy$chl <- c(MVP_tidy$chl,as.numeric(MVP_data$MVP[11,ii,1]$chl[jj]))      
      MVP_tidy$lopc <- c(MVP_tidy$lopc,as.numeric(MVP_data$MVP[12,ii,1]$lopc[jj]))      
    }
      
  }
  cat(ii)
}

# Convert to a tibble
MVP_tidy_tibble <- as_tibble(MVP_tidy)

# Convert Matlab datenum to POSIXct compliant date
# https://lukemiller.org/index.php/2011/02/converting-matlab-and-r-date-and-time-values/
dys <- MVP_tidy_tibble$daten - 719529    # 719529 = days from 1-1-0000 to 1-1-1970
scs <- dys * 86400    # 86400 seconds in a day
MVP_tidy_tibble$daten  <- as.POSIXct(scs,tz="UTC")

######## Save to an Rdata file
save(MVP_tidy_tibble, file = "MVP.RData")

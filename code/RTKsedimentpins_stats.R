#Sediment Pin Plots
library(readxl)
library(tidyverse)
library(dplyr)
library(ggrepel)
library(ggpubr)



#1. Run these:
setwd("~/GitHub/BeccaTransects/data")

RTKpindata_norefs <- read_xlsx("RTKSedimentPinData.xlsx", sheet = "RTKData_thesispins_norefs_pivot")



#2. Prepping the data frame:

## *Remember, this RTK data  only shows initial and final measurements.  No in-between like the physical measurements have. 
## **Also remember that this df is still in ft NADV88 and isn't converted until the next step
RTKpins_norefs <- RTKpindata_norefs %>% 
  select(-c("midg","midt","upt","upg", "lowt", "lowg", "Date")) %>% #can remove these columns bc the top-ground calculations are already calculated in excel in their own columns
  mutate_at(c('upper', 'middle'), as.numeric) %>% #removed the POSITX (lubridate) version of date
  mutate(Date = paste0(Year, "-", Month)) %>% #created my own date to match the sediment pin code
  rename(Transect_ID = Name) %>%  #change column header "Name" to "Transect_ID"
  
  

RTKpinschange_norefs <- RTKpins_norefs %>%
  mutate(UpperDiff = ((last(upper) - first(upper))*-1)*30.48) %>%  # *30.48 converts NADV88 ft to cm
  mutate(MiddleDiff = ((last(middle) - first(middle))*-1)*30.48) %>% 
  mutate(LowerDiff = ((last(lower) - first(lower))*-1)*30.48) %>% 
  select(-c("Date", "Year", "Month", "upper", "middle", "lower")) %>% 
  distinct() %>%  #this removes repeated values for each month's calculation
  mutate(Shoreline_End = factor(Shoreline_End, levels = c("west", "east"))) %>%
  pivot_longer(UpperDiff:LowerDiff, names_to = "Pin_Location", values_to = "Sediment_Change")




# 3. Running a GLM taking interactions into account:
hist(RTKpinschange_norefs$Sediment_Change)

glm3 <- glm(Sediment_Change ~ Shoreline_End * Pin_Location * Log_Presence, data = RTKpinschange_norefs, family = 'gaussian')

plot(glm3)

summary(glm3)

anova(glm3, test = "F")




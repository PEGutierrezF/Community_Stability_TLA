

# https://mran.microsoft.com/snapshot/2016-01-12/web/packages/codyn/vignettes/Temporal_Diversity_Indices.html
# https://scholar.google.com.pr/scholar?cites=17191641760846515355&as_sdt=2005&sciodt=0,5&hl=en&authuser=1

# section lable -----------------------------
# 28 Mar 2020
#PEGF
#--------------------------------------------
#



library(ggplot2)
library(grid)
library(gridExtra)
library(codyn)
library(dplyr)
library(tidyr)
library(patchwork)

collins08
Saltito<-read.csv("codySaltito.csv") # read the accompanying csv file
head(Saltito)


# Turnover code -----------------------------------------------------------


turnoverSaltito <- turnover(df = Saltito,  
                         time.var = "time",  
                         species.var = "taxa", 
                         abundance.var = "abundance",
                     replicate.var = NA)

turnoverSaltito
min(turnoverSaltito[,1])
max(turnoverSaltito[,1])
mean(turnoverSaltito[,1])


appearanceSaltito <- turnover(df = Saltito,  
                           time.var = "time",  
                           species.var = "taxa", 
                           abundance.var = "abundance", 
                           metric = "appearance")
appearanceSaltito

disappearanceSaltito <- turnover(df = Saltito, 
                              time.var = "time",  
                              species.var = "taxa", 
                              abundance.var = "abundance", 
                              metric = "disappearance")

disappearanceSaltito


#Format a compiled data frame
turnoverSaltito$metric<-"total"
names(turnoverSaltito)[1]="turnover"

appearanceSaltito$metric<-"appearance"
names(appearanceSaltito)[1]="turnover"

disappearanceSaltito$metric<-"disappearance"
names(disappearanceSaltito)[1]="turnover"

allturnoverSaltito<-rbind(turnoverSaltito, appearanceSaltito, disappearanceSaltito)

allturnoverSaltito


#Create the graph
turn.graphSaltito <- ggplot(allturnoverSaltito, aes(x=time, y=turnover, color=metric)) + 
  labs(y="Turnover", x = "Time", colour = "metric") +
  geom_line(size = 2) +  
  guides(color=guide_legend("Metrics"), size=guide_legend("Density")) +
  theme_bw() + 
  theme(axis.text = element_text(colour = "black", size = rel(1))) + #axis size 
  theme(axis.title.y = element_text(size = rel(1.25), angle = 90)) +  # axis title
  theme(axis.title.x = element_text(size = rel(1.25), angle = 0))+ # axis title
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(legend.position="bottom", legend.box = "horizontal")+
  theme(legend.key = element_rect(fill = "white", colour = "white")) +
  theme(legend.title = element_text(size=12, color = "black"),legend.text = element_text(size=12))+
  scale_color_manual(name="Metrics",labels = c("Appearance","Disappearance","Total"),
                     values = c("appearance"="#999999", "disappearance"="#E69F00", "total" ="#56B4E9"))

turn.graphSaltito 

T1 <- turn.graphCarapa / turn.graphSaltito
T1 + ggsave("Figure 1.JPEG",width=6, height=4,dpi=600)

# Run the rank shift code -------------------------------------------------

rankshift <- rank_shift(df=Saltito, 
                        time.var = "time", 
                        species.var = "taxa",
                        abundance.var = "abundance")

rankshift

#Select the final time point from the returned time.var_pair
rankshift$samp_event <- seq(1, 122)
rankshift

# Create the graph
rankshift.graph <- ggplot(rankshift, aes(samp_event, MRS)) + 
  geom_line(size = 1) + 
  theme_bw() 


rankshift.graph



# Rate change code --------------------------------------------------------


rateChanges <- rate_change(Saltito,   
                                   time.var= "time",    
                                   species.var= "taxa",  
                                   abundance.var= "abundance")
rateChanges


rateChange <- rate_change_interval(Saltito,   
                                 time.var= "time",    
                                 species.var= "taxa",  
                                 abundance.var= "abundance")
rateChange  

# Create the graph
rate.graph<-ggplot(rateChange, aes(interval, distance)) + 
  geom_point()+ 
  stat_smooth(method = "lm", se = F, size = 1) +
  theme_bw() 

rate.graph 


# Calculate community stability -------------------------------------------



stab <- community_stability(Carapa, 
                            time.var = "time",
                            abundance.var = "abundance")
stab


####### Calculate variance ratio, merge with stab ##########


# VARIANCE RATIO The

# If species vary independently, then the variance ratio will be
# close to 1. Avariance ratio <1 indicates predominately 
# negative species covariance, whereas a variance ratio 
# >1 indicates that species generally positively covary.

vRatio <- merge(variance_ratio(Carapa, time.var = "time",
                           species.var = "taxa",
                           abundance.var = "abundance",
                           bootnumber=1, 
                           average.replicates = F), stab)
vRatio


vr.graph <-ggplot(vRatio, aes(x=VR, y=stability)) + 
  geom_point(size=3) +
  theme_bw() +   
  theme(text= element_text(size = 14))

vr.graph
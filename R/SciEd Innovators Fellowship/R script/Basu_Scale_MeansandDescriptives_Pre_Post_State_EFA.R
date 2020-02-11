################
#Scale item means, Scale means, by wave (Pre/Post) and by state.
#Race Distributions, by wave and by state
#Exploratory Factor Analysis (2018-2019); 2017 survey results yielded single factor solution and did not meet KMO model assumption!!!
################
#Data prepping
#Set directory. Install/load packages as necessary

getwd()
setwd("/Users/pablo/Desktop/iUse/basuProject/Datasets")


library(tidyverse)
library(plotrix)
library(gridExtra)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(purrr)
library(data.table)
library(plyr)
library(GPArotation)
library(psych)

#Read-in fa18sp19 Basu dataset, ensure dataframe is structured
Basufa18sp19<-read.csv(file="SciEd_Student_Survey_grades_612.csv", stringsAsFactors=FALSE, header=T)
Basufa18sp19 <- Basufa18sp19[-1, ]


str(Basufa18sp19)  # check the structure of the data; 974 cases, 69 vars, all scale items as strings

#convert scale items to numeric (double precision point math may be needed subsequently, avoid converting to only int)
Basufa18sp19[c("CritVoi_1", "CritVoi_2", "CritVoi_3", "CritVoi_4")]<- lapply(Basufa18sp19[c("CritVoi_1", "CritVoi_2", "CritVoi_3", "CritVoi_4")], function(x) as.numeric(x))
Basufa18sp19[c("ShrAuth_1", "ShrAuth_2", "ShrAuth_3", "ShrAuth_4", "ShrAuth_5")] <- lapply(Basufa18sp19[c("ShrAuth_1", "ShrAuth_2", "ShrAuth_3", "ShrAuth_4", "ShrAuth_5")], function(x) as.numeric(x))
Basufa18sp19[c("StdntVoi_1", "StdntVoi_2", "StdntVoi_3", "StdntVoi_4")] <- lapply(Basufa18sp19[c("StdntVoi_1", "StdntVoi_2", "StdntVoi_3", "StdntVoi_4")], function(x) as.numeric(x))
Basufa18sp19[c("CritSTMLit_1", "CritSTMLit_2","CritSTMLit_4", "CritSTMLit_5")] <- lapply(Basufa18sp19[c("CritSTMLit_1", "CritSTMLit_2", "CritSTMLit_4", "CritSTMLit_5")], function(x) as.numeric(x))
Basufa18sp19[c("Comm_1", "Comm_2r", "Comm_3", "Comm_4", "Comm_5")] <- lapply(Basufa18sp19[c("Comm_1", "Comm_2r", "Comm_3", "Comm_4", "Comm_5")], function(x) as.numeric(x))
Basufa18sp19[c("Eng_1", "Eng_2", "Eng_3", "Eng_4")] <- lapply(Basufa18sp19[c("Eng_1", "Eng_2", "Eng_3", "Eng_4")], function(x) as.numeric(x))
Basufa18sp19[c("SelfConc_1r", "SelfConc_2", "SelfConc_3", "SelfConc_4r", "SelfConc_5r")] <- lapply(Basufa18sp19[c("SelfConc_1r", "SelfConc_2", "SelfConc_3", "SelfConc_4r", "SelfConc_5r")], function(x) as.numeric(x))
# Re-check dataset by variables to ensure "string' vars converted to numerics; empty string values now missing value datatype
lapply(Basufa18sp19, class)
str(Basufa18sp19) 

#Ensure response values range from 1-5 (as well as NA) only for all our scale items
apply(Basufa18sp19[c("CritVoi_1", "CritVoi_2", "CritVoi_3", "CritVoi_4", "ShrAuth_1", "ShrAuth_2", "ShrAuth_3", "ShrAuth_4", "ShrAuth_5", "StdntVoi_1", "StdntVoi_2", "StdntVoi_3", "StdntVoi_4", "CritSTMLit_1", "CritSTMLit_2","CritSTMLit_4", "CritSTMLit_5", "Comm_1", "Comm_2r", "Comm_3", "Comm_4", "Comm_5", "Eng_1", "Eng_2", "Eng_3", "Eng_4", "SelfConc_1r", "SelfConc_2", "SelfConc_3", "SelfConc_4r", "SelfConc_5r")], 2, unique)

#Check missing data percentage by variable (should ideally be below 5% to avoid imputation but under 10% ok given demographics)
map(Basufa18sp19, ~mean(is.na(.))) 

View(Basufa18sp19)
Basufa18sp19$State[Basufa18sp19$Q25=="1"]<-"Massachusetts"
Basufa18sp19$State[Basufa18sp19$Q25=="2"]<-"New York"

Basufa18sp19$PrePost[Basufa18sp19$Q24=="1"]<-"Pre"
Basufa18sp19$PrePost[Basufa18sp19$Q24=="2"]<-"Post"



####My Func for generating items means per scale and between waves####
item_means <- function(df, item_list){  
  item_means <- colMeans(df[, c(item_list)], na.rm=T)
  
  return(item_means)
} 

####My Func for plotting (and prepping for future func) generated (scale) item means between waves; automatically saves plots###
grid_barplot_item_means_fun = function(state_wave_item_means, scale_items_list, fig_title){
  state_wave_item_means <- melt(state_wave_item_means)  #the function melt reshapes it from wide to long
  setnames(state_wave_item_means, "value", "Mean")
  state_wave_item_means$Wave_State <- mapvalues(state_wave_item_means$variable, from = c("Pre.Massachusetts", "Post.Massachusetts", "Pre.New York", "Post.New York"), to = c("Pre-Mass.", "Post-Mass.", "Pre-NY", "Post-NY"))
  state_wave_item_means$Wave_State <- factor(state_wave_item_means$Wave_State, levels = c("Pre-Mass.", "Post-Mass.", "Pre-NY", "Post-NY"))
  count <- 0
  for (value in scale_items_list){
    count = count + 1
  }
  state_wave_item_means$rowid <- 1:count #add a rowid identifying variable
  temp_plot<-ggplot(state_wave_item_means, aes(x = Wave_State, y = Mean,  fill = variable, label = round(Mean, digits =2))) + 
    facet_wrap(~ rowid) +
    geom_bar(stat="identity", show.legend=FALSE) +
      theme(text = element_text(size=10), 
        axis.text.x = element_text(angle=90, hjust=1)) +
          geom_text(size = 3, position = position_stack(vjust = 0.5))
  ggsave(paste0(fig_title, "_item_means",".png"), temp_plot)
  
  return (state_wave_item_means)
}

####My func for generating and plotting Scale means by wave (returned value of prev. func. is an argument here)####
grid_barplot_scale_mean_fun = function(state_wave_item_means, column_name){
  #Get Scale Mean
  scale_mean<-sapply(split(state_wave_item_means$Mean, state_wave_item_means$Wave_State), mean)
  #Restructure to Long Format
  scale_mean <- melt(scale_mean)
  #add a rowid identifying variable
  scale_mean$Wave_State <- c("Pre-Mass.", "Post-Mass.","Pre-NY.", "Post-NY.")
  scale_mean$Wave_State = factor(scale_mean$Wave_State,levels= scale_mean$Wave_State, ordered = T)
  #Rename 1st Column (Scale Mean Value)
  colnames(scale_mean)[1] <- column_name
  #Now Make a Plot of Scale Mean by Wave and State
  mean_plot <- ggplot(data=scale_mean, aes(x=Wave_State, y= .data[[column_name]], fill= .data[[column_name]], label = round(.data[[column_name]], digits = 2))) +
    geom_bar(stat="identity") + guides(colour = guide_colourbar(order = 1)) +
      theme(text = element_text(size=10), legend.title = element_blank(), axis.title.y=element_blank(), 
        axis.text.x = element_text(angle=90, hjust=1)) +
          geom_text(size = 2.5, position = position_stack(vjust = 0.5)) +
            ggtitle(paste(column_name, "_Mean", sep = " "))
  
  return (mean_plot)
}


#Set grouping-by criteria for future aggregate stats (mean)
splt.by <- c('PrePost','State')
################
#Critical Voice item means, by wave and by state
################

CritVoiList <- c("CritVoi_1", "CritVoi_2", "CritVoi_3", "CritVoi_4")  
  
#function call 1
crit_voi_means_state_wave  <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = CritVoiList)

#function call 2
crit_voi_means_state_wave <- grid_barplot_item_means_fun(crit_voi_means_state_wave , CritVoiList, "Crit_Voice")

#function call 3
crit_voi_mean_state_wave_plot <- grid_barplot_scale_mean_fun(crit_voi_means_state_wave, "Critical Voice" )


################
#Shared Authority item means, by wave and by state
################



ShrAuthList <- c("ShrAuth_1", "ShrAuth_2", "ShrAuth_3", "ShrAuth_4", "ShrAuth_5") 

#function call 1
shr_auth_means_state_wave  <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = ShrAuthList)

#function call 2
shr_auth_means_state_wave <- grid_barplot_item_means_fun(shr_auth_means_state_wave , ShrAuthList, "Shared_Authority")

#function call 3
shr_auth_mean_state_wave_plot <- grid_barplot_scale_mean_fun(shr_auth_means_state_wave, "Shared Authority" )

################
#Student Voice item means, by wave and by state
################


StdntVoiList <- c("StdntVoi_1", "StdntVoi_2", "StdntVoi_3", "StdntVoi_4")

#function call 1
stdntvoi_means_state_wave  <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = StdntVoiList)

#function call 2
stdntvoi_means_state_wave <- grid_barplot_item_means_fun(stdntvoi_means_state_wave , StdntVoiList, "Student_Voice")

#function call 3
stdntvoi_mean_state_wave_plot <- grid_barplot_scale_mean_fun(stdntvoi_means_state_wave, "Student Voice" )

################
#Critical STEM Literacy item means, by wave and by state
################

CritSTMLitList <- c("CritSTMLit_1", "CritSTMLit_2","CritSTMLit_4", "CritSTMLit_5")

#function call 1
critstm_means_state_wave  <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = CritSTMLitList)

#function call 2
critstm_means_state_wave <- grid_barplot_item_means_fun(critstm_means_state_wave , CritSTMLitList, "Crit_STEM_Lit")

#function call 3
critstm_mean_state_wave_plot <- grid_barplot_scale_mean_fun(critstm_means_state_wave, "Critical STEM Literacy" )

################
#Community Connectedness item means, by wave and by state
################

CommList <- c("Comm_1", "Comm_2r", "Comm_3", "Comm_4", "Comm_5")

#function call 1
comm_means_state_wave   <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = CommList)

#function call 2
comm_means_state_wave  <- grid_barplot_item_means_fun(comm_means_state_wave, CommList, "Community_Connectedness")

#function call 3
comm_mean_state_wave_plot <- grid_barplot_scale_mean_fun(comm_means_state_wave, "Community Connectedness" )

################
#Emotional Engagement item means, by wave and by state
################
EngList <- c("Eng_1", "Eng_2", "Eng_3", "Eng_4")

#function call 1
eng_means_state_wave <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = EngList)

#function call 2
eng_means_state_wave <- grid_barplot_item_means_fun(eng_means_state_wave, EngList, "Emotional_Engagement")

#function call 3
eng_mean_state_wave_plot <- grid_barplot_scale_mean_fun(eng_means_state_wave, "Emotional Engagement" )

################
#Self Concept in STEM item means, by wave and by state
################
SelfConcList <- c("SelfConc_1r", "SelfConc_2", "SelfConc_3", "SelfConc_4r", "SelfConc_5r")

#function call 1
selfconc_means_state_wave  <- Basufa18sp19 %>%
  split(.[, splt.by]) %>%
  map_df(item_means, item_list = SelfConcList)

#function call 2
selfconc_means_state_wave <- grid_barplot_item_means_fun(selfconc_means_state_wave , SelfConcList, "Self_Concept_STEM")

#function call 3
selfconc_state_wave_plot <- grid_barplot_scale_mean_fun(selfconc_means_state_wave, "Self Concept STEM" )

################
#Save Scale Mean Plots
################
                
#arrange first six scale mean barplots as grid and save
png("Scale_Means.png")
grid.arrange(crit_voi_mean_state_wave_plot, shr_auth_mean_state_wave_plot, stdntvoi_mean_state_wave_plot, critstm_mean_state_wave_plot, comm_mean_state_wave_plot, eng_mean_state_wave_plot)
dev.off()

#save remaining seventh scale mean barplot
ggsave(paste0("Self Concept in STEM", "_mean",".png"), selfconc_state_wave_plot)

######Race Plots####

Basufa18sp19$race[Basufa18sp19$Race_1=="1"]<-"Asian"
Basufa18sp19$race[Basufa18sp19$Race_2=="1"]<-"Black"
Basufa18sp19$race[Basufa18sp19$Race_3=="1"]<-"Cape Verdean"
Basufa18sp19$race[Basufa18sp19$Race_4=="1"]<-"Caribbean"
Basufa18sp19$race[Basufa18sp19$Race_5=="1"]<-"Hispanic"
Basufa18sp19$race[Basufa18sp19$Race_6=="1"]<-"Native American"
Basufa18sp19$race[Basufa18sp19$Race_7=="1"]<-"Pacific Islander"
Basufa18sp19$race[Basufa18sp19$Race_8=="1"]<-"White"
Basufa18sp19$race[Basufa18sp19$Race_9=="1"]<-"Other"
Basufa18sp19$races <- as.factor(Basufa18sp19$race)

df_Wave_State  <- Basufa18sp19 %>%
  split(.[, splt.by])

pre_MA_race <- ggplot(data=df_Wave_State[2][["Pre.Massachusetts"]]) + geom_bar(aes(x = races, fill = races)) + theme(text = element_text(size=10), legend.title = element_blank(), axis.title.x=element_blank(), axis.text.x = element_text(angle=90, hjust=1)) + ggtitle("Pre MA: Race")

post_MA_race <- ggplot(data=df_Wave_State[1][["Post.Massachusetts"]]) + geom_bar(aes(x = races, fill = races)) + theme(text = element_text(size=10), legend.title = element_blank(), axis.title.x=element_blank(), axis.text.x = element_text(angle=90, hjust=1))+ ggtitle("Post MA: Race")

pre_NY_race  <- ggplot(data=df_Wave_State[4][["Pre.New York"]]) + geom_bar(aes(x = races, fill = races)) + theme(text = element_text(size=10), legend.title = element_blank(), axis.title.x=element_blank(), axis.text.x = element_text(angle=90, hjust=1)) + ggtitle("Pre NY: Race")

post_NY_race <- ggplot(data=df_Wave_State[3][["Post.New York"]]) + geom_bar(aes(x = races, fill = races)) + theme(text = element_text(size=10), legend.title = element_blank(), axis.title.x=element_blank(), axis.text.x = element_text(angle=90, hjust=1)) + ggtitle("Post NY: Race")

png("Wave_State_Race.png")
grid.arrange(pre_MA_race, post_MA_race, pre_NY_race, post_NY_race)
dev.off()

################
#Exploratory Factor Analysis (Pre)
################

scales <- c("PrePost", "CritVoi_1", "CritVoi_2", "CritVoi_3", "CritVoi_4", "ShrAuth_1", "ShrAuth_2", "ShrAuth_3", "ShrAuth_4", "ShrAuth_5", "StdntVoi_1", "StdntVoi_2", "StdntVoi_3", "StdntVoi_4", "CritSTMLit_1", "CritSTMLit_2","CritSTMLit_4", "CritSTMLit_5", "Comm_1", "Comm_2r", "Comm_3", "Comm_4", "Comm_5", "Eng_1", "Eng_2", "Eng_3", "Eng_4", "SelfConc_1r", "SelfConc_2", "SelfConc_3", "SelfConc_4r", "SelfConc_5r")
df_scales <- Basufa18sp19[scales]

Basufa18sp19_Pre_Post = split(df_scales, df_scales$PrePost)
Basufa18sp19_Post = Basufa18sp19_Pre_Post[[1]]
Basufa18sp19_Pre = Basufa18sp19_Pre_Post[[2]]


Basufa18sp19_Pre = subset(Basufa18sp19_Pre, select = -c(PrePost) )

#Change window view parameters and check very simple structure plot
par(mar = c(1, 1, 1, 1))
VSS(Basufa18sp19_Pre, n=8, rotate = "varimax", fm = "pa", SMC = FALSE)

#Correlations generally below .5 (and only around .5 for items within same scale)
correlations= cor(Basufa18sp19_Pre, use = "pairwise.complete.obs")


#Significant Bartlett's Test
cortest.bartlett(correlations, n=nrow(df_scales))
#Overall MSA = 0.92. Model assumptions have been met
KMO(correlations)

par(mar = c(5.1, 4.1, 4.1, 2.1))
#Parallel analysis suggests that the number of factors =  8
nofactors= fa.parallel(Basufa18sp19_Pre, fm = "ml", fa= "fa")
# Based on Eigen Values of components >1 scree plot suggests number of factors = 7 or 8
scree = scree(Basufa18sp19_Pre)

#efa.model.1 <- fa(Basufa18sp19_Pre, nfactors = 8, rotate="varimax", SMC=FALSE, fm = "pa")

#Similar results with orthogonal rotation
efa.model.1 <- fa(Basufa18sp19_Pre, nfactors = 8, rotate="oblimin", SMC=FALSE, fm = "pa")
# under orthogonal rotation, inter-factor correlations < .48, no high degree of collinearity, we conclude we have 8 factors
#Suppress printing factor loadings =< 0.3
print(efa.model.1, cut = 0.3, digits = 3)


#efa.model.2 <- fa(df_scales, nfactors = 7, rotate="varimax", SMC=FALSE, fm = "pa")
#print(efa.model.2, cut = 0.3, digits = 3)

# It seems nfactors = 8 fits the data well and is most sensible in interpretting: all scales load moderately to strongly
# on one factor (allowing for their construct interpretation) save for 1 self-concept in STEM item (SelfConc_2) and Comm_2.
# Self Conc 1 and Comm 2 load on separate factor
# SelfConc 1, SelfConc2 and Comm 2 currently do not correlate well with their respective scale items!

################
#Exploratory Factor Analysis (Post)
################
Basufa18sp19_Post = subset(Basufa18sp19_Post, select = -c(PrePost) )

#Change window view parameters and check very simple structure plot
par(mar = c(1, 1, 1, 1))
VSS(Basufa18sp19_Post, n=8, rotate = "varimax", fm = "pa", SMC = FALSE)

#Correlations generally below .5 (and only around .5 for items within same scale)
correlations2= cor(Basufa18sp19_Post, use = "pairwise.complete.obs")


#Significant Bartlett's Test
cortest.bartlett(correlations2, n=nrow(df_scales))
#Overall MSA also = 0.92. Model assumptions have been met
KMO(correlations2)

par(mar = c(5.1, 4.1, 4.1, 2.1))
#Parallel analysis also suggests that the number of factors =  8
nofactors= fa.parallel(Basufa18sp19_Post, fm = "ml", fa= "fa")
# Based on Eigen Values of components >1 scree plot suggests number of factors = 7 or 8
scree = scree(Basufa18sp19_Post)

efa.model.1.post <- fa(Basufa18sp19_Post, nfactors = 8, rotate="varimax", SMC=FALSE, fm = "pa")

#Orthogonal rotation yields most interpretable factor analytic solution at 8 factors.
# Factor correlations all below .560, usually a lot lower, suggesting no degree of collinearity (factors are independent)
efa.model.1.post <- fa(Basufa18sp19_Post, nfactors = 8, rotate="oblimin", SMC=FALSE, fm = "pa")

#efa.model.1.post <- fa(Basufa18sp19_Post, nfactors = 7, rotate="varimax", SMC=FALSE, fm = "pa")
#Suppress printing factor loadings =< 0.3
print(efa.model.1.post, cut = 0.3, digits = 3)
# We settle for an 8 factor solution again due to the fact that each factor has at least two maximum item loadings, 
# and that this solution is easier to interpret than the 7 factor solution (two scales load on one factor);
#SelfConc 2, and 3 load on separate factor (as opposed to Self Conc 1 and Comm 2)
#While Self Conc 2 and 3, Comm 2, and now Shared Authority 4 do not hang well with their respective scale items.

#Self Concept 1 re-aligned with its scale, but Self Concept 3 now loading separately...
# Self Concept 2, Self Concept 3, Shared Authority 4, and Community Connectedness 2 will require further revision (though sample size for Post is a few hundred cases smaller than Pre).

# We consider this a significant improvement in aligning the latent structures of all but two of our seven scales to a single latent trait per scale (compared to 2017 single factor solution)



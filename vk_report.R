library("httr")
library("jsonlite")
library(tidyjson)   # this package
library(dplyr)      # for %>% and other dplyr functions


source("./R-VK-Ads-master/R/vk_token.R")
source("./R-VK-Ads-master/R/vk_objects.R")
source("./R-VK-Ads-master/R/vk_stats.R")

st_date<-"2017-12-15"
end_date<-"2017-12-25"

campain.df<-data.frame(
  name = c("Kaskad-n_a-town_vk-desktop_46-55_ug", "Kaskad-n_a-town_vk-desktop_36-45_ug", "Kaskad-n_a-town_vk-desktop_25-35_ug"),
  id = c("1008481371", "1008481020", "1008472749"),
  campaign = c("a-town_vk-desktop_46-55_ug", "a-town_vk-desktop_36-45_ug", "a-town_vk-desktop_25-35_ug"), stringsAsFactors = F)
#my_token <- tokenVK(save = TRUE)#
load("VK_token")
my_account_id = "1603620456"

result.csv<-data.frame(ga.date=c("ga:date"), ga.medium=c("ga:medium"),ga.source=c("ga:source"),ga.adCost=c("ga:adCost"),ga.adClicks=c("ga:adClicks"),ga.impressions=c("ga:impressions"),ga.campaign=c("ga:campaign"), stringsAsFactors = F)



my_ads_stats <- statsVK(my_token, my_account_id, startdate = st_date, enddate = end_date, campaign_ids = paste(campain.df$id, collapse=", "), stat_period = "day")

stats.df<-fromJSON(my_ads_stats)
stats.df$id<-as.character(stats.df$id)
stats.df<-inner_join(campain.df, stats.df, by=c("id"="id"))   


#form csv
ga.medium<-"cpc"
ga.source<-"vk"


for (i in 1:nrow(stats.df)){
  ga.campaign<-stats.df[i,"campaign"]
  stats.vk<-stats.df[i,"stats"][[1]]
  for (j in 1:nrow(stats.vk)){
    ga.date<-gsub("-","", stats.vk[j, "day"][[1]])
    ga.adCost<-stats.vk[j, "spent"][[1]]
    if (is.null(ga.adCost)){
      ga.adCost<-"0.0"
    }
    ga.impressions<-stats.vk[j, "impressions"][[1]]
    if(is.null(ga.impressions)){
      ga.impressions<-"0"
    }
    ga.adClicks<-stats.vk[j, "clicks"][[1]]
    if(is.null(ga.adClicks)){
      ga.adClicks<-"0"
    }
    result.csv<-rbind(result.csv, data.frame(ga.date, ga.medium,ga.source,ga.adCost,ga.adClicks,ga.impressions,ga.campaign))
    
    
  }
  
}
write.table(result.csv, file=paste(st_date, end_date,"vk.report.csv", sep="."), sep=",", row.names = F, col.names = F, quote = F)


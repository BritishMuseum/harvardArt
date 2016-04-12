#' ----
#' title: " A script for manipulation of the Harvard Art Museum API for Roman Republican coins"
#' author: "Daniel Pett"
#' date: "10/16/2015"
#' output: csv_document | RDF
#' ----
#' 
setwd("~/Documents/research/harvardArt/") #MacOSX
# Create JSON folder 
if (!file.exists('json')){
  dir.create('json')
}
if (!file.exists('csv')){
  dir.create('csv')
}
library(jsonlite)
library(stringr)
library(plyr)
library(mefa)
library(XML)
library(data.table)
library(dplyr)
archives <- paste('json/',sep='')
baseUrl <- 'http://api.harvardartmuseums.org/object?'
apiKey <- '&apikey=39904600-8227-11e5-97a8-b32546ca7ce0'
size <- '&size=100'
query <- 'q=republican'
worktype <- '&worktype=coin'
call <- paste(baseUrl,query,size,worktype,apiKey, sep = '' )
filename <- paste(archives,'page1.json', sep ='')
raw <- download.file(call, filename )
json <- fromJSON(filename)
pages <-json$info$pages
data <- as.data.frame(json$records)
keeps <- c("accessionyear", "objectnumber", "lastupdate", "technique", "primaryimageurl",
           "description", "dated","copyright", "period", "url", "provenance", "images", 
           "objectid", "culture", "standardreferencenumber", "worktypes", "department",
           "state", "datebegin", "dateend", "dimensions", "century", "people", "details",
           "style","medium"
           ) 
data <- data[,(names(data) %in% keeps)]
data$obversedescription <- str_split_fixed(data$description, "\n", 1)
data$reversedescription <- str_split_fixed(data$description, "\n", 2)
data$metal <- data$details$coins$metal
data$reverseInscription <- data$details$coins$reverseinscription
data$obverseInscription <- data$details$coins$obverseinscription
data$dieAxis <- data$details$coins$dieaxis
data$denomination <- data$details$coins$denomination
data$dateObject <- data$details$coins$dateonobject
drop <- c("details", "obversedescription", "description")
data <- data[,!(names(data) %in% drop)]
for (i in seq(from=2, to=7, by=1)){
  page = paste(call,'&page=', i, sep='')
  filename <- paste(archives,'page', i ,'.json', sep ='')
  jsonpage <- download.file(page, filename )
}
data <- as.data.frame(data)

for (i in seq(from=2, to=7, by=1)){
  filenameDownload <- paste(archives,'page', i ,'.json', sep ='')
  pagedJson <- fromJSON(filenameDownload)
  records <- as.data.frame(pagedJson$records)
  records <- records[,(names(records) %in% keeps)]
  records$obversedescription <- str_split_fixed(records$description, "\n", 1)
  records$reversedescription <- str_split_fixed(records$description, "\n", 2)
  records$metal <- records$details$coins$metal
  records$reverseInscription <- records$details$coins$reverseinscription
  records$obverseInscription <- records$details$coins$obverseinscription
  records$dieAxis <- records$details$coins$dieaxis
  records$denomination <- records$details$coins$denomination
  records$dateObject <- records$details$coins$dateonobject
  drop <- c("details", "obversedescription", "description")
  records <- records[,!(names(records) %in% drop)]
  data <-rbind(data,records)
}
data <- sapply(data, function(x) ifelse(x == "NULL", NA, x))
data <- data.frame(lapply(data, as.character), stringsAsFactors=FALSE)
# Rearrange data table by year of accession.
data <- arrange(data,accessionyear)

write.csv(data, file="csv/rawHarvard.csv",row.names=FALSE)
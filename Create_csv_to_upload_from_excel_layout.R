library(readxl)
library(dplyr)
library(tidyverse)
library(purrr)
library(kableExtra)
library(stringi)


# open the different sheets

# event<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                   sheet = "Event", 
#                   col_types = "text")
# 
# 
# obs<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                 sheet = "Observation", 
#                 col_types = "text")
# 
# spec<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                  sheet = "Specimen", 
#                  col_types = "text")
# 
# 
# necropsy<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                      sheet = "Necropsy", 
#                      col_types = "text")
# 
# diag<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                  sheet = "Diagnostics", 
#                  col_types = "text")
# 
# # tme<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
# #                 sheet = "TME", 
# #                 col_types = "text")
# 
# 
# samples<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                     sheet = "Samples", 
#                     col_types = "text")
# 
# tests<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                   sheet = "Tests", 
#                   col_types = "text")
# 
# diagnosis<-read_excel("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/Bulk_upload_layout_excel_DTRA_Cambodia_Laos_Vietnam.xlsx", 
#                       sheet = "Diagnosis", 
#                       col_types = "text")


# fix colnames. Create function

fix.colnames=function(data.set){
  colnames(data.set)=sapply(names(data.set), function(x) gsub(" ", "_", x, fixed = TRUE), USE.NAMES = F)
  colnames(data.set)=sapply(names(data.set), function(x) gsub("/", "_", x, fixed = TRUE), USE.NAMES = F)
  colnames(data.set)=sapply(names(data.set), function(x) gsub("_-", "", x, fixed = TRUE), USE.NAMES = F)
  colnames(data.set)=sapply(names(data.set), function(x) gsub(" ", "", x, fixed = TRUE), USE.NAMES = F)
  colnames(data.set)=stri_trans_general(str = colnames(data.set),  id = "Latin-ASCII")
  return(data.set)
}



# Create a list with dataaset with fixed col names

data.sets=
  lapply(
    list(event, spec, obs, necropsy, diag, tme, samples, tests, diagnosis), 
    fix.colnames)

names(data.sets)=c("event", "spec", "obs", "necropsy", "diag", "tme", "samples", "tests", "diagnosis")


# Concatenate the sample source for the tests based on the 
# sample id and sample type in the samples "sheet"

temp=
  data.frame(sample_id=data.sets$samples$sample_id,
             sample_type=data.sets$samples$sample_type,
             african_swine_fever_test_sample_source=
                paste0(data.sets$samples$sample_type, " (", data.sets$samples$sample_id, ")"))


temp=temp%>%select(sample_id, african_swine_fever_test_sample_source)

data.sets$tests=left_join(data.sets$tests, 
                          temp, 
                          by = c("sample_id"))


# move the new column right after sample id
data.sets$tests=data.sets$tests%>%relocate(african_swine_fever_test_sample_source, .after = sample_id)



# First join. Between "event" and "observation" sheet

out=full_join(data.sets$obs, 
              data.sets$spec, 
              by = c("event_code", "observation_code", "specimen_code"))


out%>%select(event_code, observation_code, specimen_code)


# secondly, join to the "specimen" sheet

out2=left_join(data.sets$event, 
               out, 
               by = c("event_code"))


out2=out2%>%arrange(event_code, observation_code, specimen_code)

# out2%>%select(event_code, observation_code, specimen_code, longitude, latitude)



# thirdly, join to the "necropsy" sheet

out3=left_join(out2, 
               data.sets$necropsy, 
               by = c("specimen_code"))


out3=out3%>%arrange(event_code, observation_code, specimen_code)

# out3%>%select(event_code, longitude, latitude, observation_code, specimen_code, necropsy_carcass_condition_score)
# 
# names(out3)


# fourthly, join the diagnostics sheet

out4=left_join(out3, 
               data.sets$diag, 
               by = c("specimen_code"))



out4=out4%>%arrange(event_code, observation_code, specimen_code)

# out4%>%select(event_code, observation_code, specimen_code, necropsy_location, histology)
# 
# names(out4)


# fifthly, join to the "samples" sheet

out5=left_join(out4, 
               data.sets$samples, 
               by = c("specimen_code"))


out5=out5%>%arrange(event_code, observation_code, specimen_code, sample_id)

out5%>%select(event_code, observation_code, specimen_code, necropsy_location, histology, sample_id)

# names(out5)


# Sixth, join to the "tests" sheet

out6=left_join(out5, 
               data.sets$tests, 
               by = c("sample_id"))


out6=out6%>%arrange(event_code, observation_code, specimen_code, sample_id)

# out6%>%select(event_code, observation_code, specimen_code, necropsy_location, histology, sample_id, african_swine_fever_test_sample_source)
# 
# names(out6)

# reorder the specimen code column
out6=out6%>%relocate(specimen_code, .after = tentative_diagnosis_text)


# finally return a csv




# checks: necropsy fields cannot have information when the observation id has information
# specimen code should be concordant with sample id

# data.set=data.set[!(grepl("test", data.set$Projects, ignore.case = T)),]
# data.set=data.set[!(grepl("delete", data.set$Projects, ignore.case = T)),]
# data.set=data.set[!(grepl("test", data.set$Tags, ignore.case = T)),]
# data.set=data.set[!(grepl("delete", data.set$Tags, ignore.case = T)),]



ddos_grouped<-readRDS("data/internal/rds/ddos_grouped.RDS")

externalOSI<- vroom::vroom("data/external/service-names-port-numbers.csv",num_threads=(parallel::detectCores()-1),col_select=c("Service Name","Port Number","Transport Protocol"),col_types=c("c","c","c"),skip_empty_rows=T)
#externalOSI <- na.omit(externalOSI)
colnames(externalOSI) <- c("Service","Port","Protocol")
rm(numthreads)

na_indices <- which(is.na(ddos_grouped$Services))
ddos_grouped$Services[na_indices] <- NA

Ports<-c("1433","99999","445","3389","80","56338","8080","22","3306","2193","135","53","23","5060","6666","443","3128","5900","19","1469","21","25","110","143","7","389","123","68","5432","1434","1900","5353","161","179","139","137","111","0","13","9","3","2","1","37","33","26","38","42")
portstomatch<-setdiff(externalOSI$Port,Ports)

externalOSI<-externalOSI[portstomatch,]

close_to_clean<-merge(ddos_grouped,externalOSI,by="Port",no.dups=T)

rm(ddos_grouped,externalOSI,portstomatch,Ports,na_indices)
gc()

save(close_to_clean,file ="data/internal/rda/cleaned.RDA",compress=T)
saveRDS(close_to_clean,file = "data/internal/rds/cleaned.RDS",compress="gzip",refhook=NULL)

rm(list=ls())
gc(F,F,T)
######################################################################################################

#This version only replaces the missing services using the Service Data DF

ddos_grouped<-readRDS("data/internal/rds/ddos_grouped.RDS")

externalOSI<- vroom::vroom("data/external/service-names-port-numbers.csv",num_threads=(parallel::detectCores()-1),col_select=c("Service Name","Port Number","Transport Protocol"),col_types=c("c","c","c"),skip_empty_rows=T)
externalOSI <- na.omit(externalOSI)
colnames(externalOSI) <- c("Service","Port","Protocol")

na_indices <- which(is.na(ddos_grouped$Services))
ports_of_na_ddos_grouped_indices <- ddos_grouped$Port[na_indices]

ddos_grouped$Services[na_indices]<-replace_na(ddos_grouped$Services[na_indices],"Unknown_Unassigned")

ddos_grouped_nonNA <- ddos_grouped[-na_indices,]

externalOSI1 <-externalOSI$Service[ports_of_na_ddos_grouped_indices]
externalOSI_proto <-externalOSI$Protocol[ports_of_na_ddos_grouped_indices]

Solved<-data.frame("Services"=externalOSI1,"Port"=ports_of_na_ddos_grouped_indices,"Protocol"=externalOSI_proto)
Solved[2,1] <- "MinecraftServer"
Solved[2,3] <- "TCP"
Solved$Port<-as.numeric(Solved$Port)

ddos_grouped$Services<-replace(ddos_grouped$Services,na_indices,Solved$Services)

save(ddos_grouped,file ="data/internal/rda/cleaned_WITHOUT_OSI.RDA",compress=T)
saveRDS(ddos_grouped,file ="data/internal/rds/cleaned_WITHOUT_OSI.RDS",compress="gzip",refhook=NULL)

rm(list=ls())
gc(F,F,T)
######################################################################################################






require(dplyr)
require(tidyr)
require(tibble)
require(tidyselect)
#library(lubricate)
#library(stringi)
#library(vroom)


numthreads<- parallel::detectCores(logical=T)-1
raw_data <- vroom::vroom("data/internal/AWS_Honeypot_marx-geo.csv",delim=',',quote = "\"",col_names=T,num_threads=numthreads,col_types =c("c","c","c","i","i","i","c","n","n","c","c","c","c"),col_select=c("datetime","host","proto","spt","dpt","src","srcstr","longitude","latitude","country","locale","localeabbr","postalcode"))
dt_backup <- raw_data$datetime
rm(numthreads)
gc()

raw_data <- raw_data |>
  select(datetime,host,src,proto,spt,dpt,srcstr,longitude,latitude,country,locale,localeabbr,postalcode) |>
  separate(datetime, into = c("date", "time"), sep = " ")

dates<-strptime(as.character(dt_backup), format = "%m/%d/%y")
raw_data$dates <- dates
raw_data$datetime <- dt_backup
gc()

rm(dt_backup,dates)
gc()

raw_data$host <- gsub("-", "_", raw_data$host)
raw_data$spt<-replace_na(raw_data$dpt,99999)
raw_data$dpt<-replace_na(raw_data$spt,99999)

gc()
working_data <- raw_data |>
  select(datetime,date,time,host,srcstr,src,proto,spt,dpt,longitude,latitude,country,locale,localeabbr,postalcode,dates) |>
  group_by() |>
  arrange(datetime,date,time,host,srcstr,src,proto,spt,dpt,longitude,latitude,country,locale,localeabbr,postalcode,dates) |>
  rename("region"="country","long"="longitude","lat"="latitude") 


rm(raw_data)
gc()
working_data<-working_data[,-c(13,14,15)]

na_indices<-which(is.na(working_data$region))

gc()
ips_to_check<-data.frame(cbind(working_data$datetime[na_indices],working_data$region[na_indices],working_data$srcstr[na_indices],working_data$date[na_indices],working_data$time[na_indices],working_data$spt[na_indices],working_data$proto[na_indices],working_data$host[na_indices]))


reticulate::use_python(python = "C:/Python312/python.exe")
reticulate::py_run_string("
import geoip2
import geoip2.database
import pandas as pd

reader = geoip2.database.Reader('data/external/GeoLite2-Country.mmdb')

def get_country(ip):
    try:
        response = reader.country(ip)
        return pd.DataFrame({'country':[response.country.name]})
    except:
        return pd.DataFrame({'country':[pd.NA]})")

ips_to_check1<- sapply(ips_to_check[,3], reticulate::py$get_country)

ips_to_check2<- stringi::stri_list2matrix(ips_to_check1)
ips_to_check2<-t(ips_to_check2)

ips<-unlist(c(attributes(ips_to_check1)))
ips<- stringi::stri_replace_last(ips,replacement = c(""),fixed = ".country")

country_ips<-data.frame("ips"=ips,"cnames"=ips_to_check2)

rm(ips_to_check,ips_to_check1)
gc()
rm(na_indices,ips_to_check2)
gc()

library(reticulate)
py_run_string("reset = globals().clear()")  # Resets the global namespace
py_run_string("del reset")                 # Clean up the `reset` object
unloadNamespace("package:reticulate")
.rs.unloadPackage("reticulate")
gc()

#virtualenv_remove("r-reticulate",T,F)
#unloadNamespace("reticulate")
#

matched_index <- match(country_ips[,1],working_data$srcstr)
working_data$region <- replace(working_data$region,matched_index,country_ips[,2])

rm(ips,matched_index,country_ips)
gc()

working_data <- working_data |>
  rename("port"="spt","protocol"="proto") |>
  mutate("dpt" = NULL,"src" = NULL)

working_data$month <- months.Date(working_data$dates,abbreviate = T)
working_data$year <- c(rep(length(working_data$datetime),x = "2013"))
working_data$day<- reorder( stringi::stri_sub(as.character(working_data$dates),from = 9L,length = 2,ignore_negative_length = F),working_data$datetime)

saveRDS(working_data,"data/internal/rds/working_data.RDS",compress="gzip",refhook=NULL)
save(working_data,file = "data/internal/rda/working_data.RDA",compress=T)

Ports<-c("1433","99999","445","3389","80","56338","8080","22","3306","2193","135","53","23","5060","6666","443","3128","5900","19","1469","21","25","110","143","7","389","123","68","5432","1434","1900","5353","161","179","139","137","111","0","13","9","3","2","1","37","33","26","38","42")
Services <- c("MSSQL_Server","ICMP","SMB","RDP","HTTP","UDP_Flood1","HTTPAlt","SSH","MySQL","UDP_Flood2","RPC","DNS","Telnet","SIP","IRC","HTTPS","Squid_Proxy","VNC","CHARGEN","AAL_LM","FTP","SMTP","POP3","IMAP","Echo","LDAP","NTP","DHCPClient","PostgreSQL","MSSQL_Monitor","SSDP","MDNS","SNMP","BGP","NETBIOS_ssh","NETBIOS_ns","RCPBind","Reserved","Daytime","Discard","compressnet","compressnet","tcpnux","time","dsp","unassigned","rap","nameserver_WIN")

servdict<-data.frame(cbind(c(1:48),Ports,Services))
servdict$portsnum<-as.numeric(Ports)


#load("data/internal/rda/working_data.RDA")
#ddos_grouped<-working_data

matchindex<- match(ddos_grouped$port,servdict$portsnum,nomatch = NA)
ddos_grouped$servindex <- matchindex
ddos_grouped<-merge(ddos_grouped,servdict,no.dups = F,incomparables = "NA",by.x = "servindex",by.y = "V1",all = F)
ddos_grouped <- ddos_grouped |> mutate("ports"=NULL,"portsnum"=NULL,"servindex"=NULL) 
rm(Ports,Services,servdict)
gc()


'
ddos_grouped <- ddos_grouped |> 
  mutate("servindex"=NULL,"Ports"=NULL,"Protocol"=NULL) |>
  rename("SRCIP"="srcstr","Region"="region","Host"="host","Month"="month","Port"="port",
         "Day"="day","Time"="time","Datetime"="datetime","Connections"="connections","Protocol"="protocol")
'
rm(matchindex,servdict)
gc()

#na_indices<-which(is.na(ddos_grouped[,12]))
#ddos_grouped$Protocol[-na_indices]
#ddos_grouped$Services[na_indices]<-replace_na(ddos_grouped$Services[na_indices],"Unknown_Unassigned")
rm(na_indices)
gc()

#save(ddos_grouped,file ="data/internal/rda/ddos_grouped.RDA",compress=T)
#saveRDS(ddos_grouped,"data/internal/rds/ddos_grouped.RDS",refhook=NULL,compress="gzip")
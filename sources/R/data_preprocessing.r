gc(F,T,T)

load_lb<-function(LibList){
  Lib <- as.list(LibList)
  for(i in 1:length(Lib)){
    require(Lib[[i]],character.only=T)}
}

load_lb(c("dplyr","tidyr"))

rm(load_lb)
gc()

raw_data <- vroom::vroom("../../data/internal/AWS_Honeypot_marx-geo.csv",delim=',',quote = "\"",col_names=T,num_threads=as.numeric(parallel::detectCores(logical=T)-1),col_types =c("c","c","c","i","i","c","n","n","c","c","c","c"),col_select=c("datetime","host","proto","spt","dpt","srcstr","longitude","latitude","country","locale","localeabbr","postalcode"))

raw_data <- raw_data |> 
  mutate("datetimes"= c(raw_data$datetime),"dates"= c(strptime(as.character(raw_data$datetime), format = "%m/%d/%y"))) |>
  separate(datetimes, into = c("date", "time"), sep = " ") |>
  mutate("host"=gsub("-", "_", raw_data$host),"dpt"=c(replace_na(raw_data$spt,99999)),"spt"=c(replace_na(raw_data$dpt,99999)))


working_data <- raw_data |>
  select(datetime,date,time,host,srcstr,proto,spt,dpt,longitude,latitude,country,dates) |>
  group_by() |>
  arrange(.by_group=T) |>
  rename("region"="country","long"="longitude","lat"="latitude") 

rm(raw_data)
gc()

na_indices<-which(is.na(working_data$region))
ips_to_check<-data.frame(cbind(working_data$datetime[na_indices],working_data$region[na_indices],working_data$srcstr[na_indices],working_data$date[na_indices],working_data$time[na_indices],working_data$spt[na_indices],working_data$proto[na_indices],working_data$host[na_indices]))

library(reticulate)
reticulate::use_python(python = "C:/Python312/python.exe")
reticulate::py_run_file("../Python/ipgeolocation.py")

ips_to_check1<- sapply(ips_to_check[,3], py$get_country)
rm(ips_to_check)
gc()

ips_to_check2<- stringi::stri_list2matrix(ips_to_check1)
ips<-unlist(c(attributes(ips_to_check1)))
ips<- stringi::stri_replace_last(ips,replacement = c(""),fixed = ".country")

rm(ips_to_check1)
gc()

ips_to_check2<-t(ips_to_check2)
country_ips<-data.frame("ips"=ips,"cnames"=ips_to_check2)

rm(ips_to_check2,na_indices)
gc()

py_run_string("reset = globals().clear()")  # Resets the global namespace
py_run_string("del reset")                 # Clean up the `reset` object

.rs.unloadPackage("reticulate")
unloadNamespace("reticulate")

matched_index <- match(country_ips[,1],working_data$srcstr)
working_data$region <- replace(working_data$region,matched_index,country_ips[,2])
rm(ips,matched_index,country_ips)
gc(F,F,T)

day<-reorder( stringi::stri_sub(as.character(working_data$dates),from = 9L,length = 2,ignore_negative_length = F),working_data$datetime)

working_data <- working_data |>
  rename("port"="spt","protocol"="proto") |>
  mutate("dpt" = NULL,"src" = NULL, "month"= c(months.Date(working_data$dates,abbreviate = T)),"day"=day) |>
  arrange(datetime) |>
  mutate("dates"=NULL)

rm(day)
gc()

Ports<-c("1433","99999","445","3389","80","56338","8080","22","3306","2193","135","53","23","5060","6666","443","3128","5900","19","1469","21","25","110","143","7","389","123","68","5432","1434","1900","5353","161","179","139","137","111","0","13","9","3","2","1","37","33","26","38","42")
Services <- c("MSSQL_Server","ICMP","SMB","RDP","HTTP","UDP_Flood1","HTTPAlt","SSH","MySQL","UDP_Flood2","RPC","DNS","Telnet","SIP","IRC","HTTPS","Squid_Proxy","VNC","CHARGEN","AAL_LM","FTP","SMTP","POP3","IMAP","Echo","LDAP","NTP","DHCPClient","PostgreSQL","MSSQL_Monitor","SSDP","MDNS","SNMP","BGP","NETBIOS_ssh","NETBIOS_ns","RCPBind","Reserved","Daytime","Discard","compressnet","compressnet","tcpnux","time","dsp","unassigned","rap","nameserver_WIN")

servdict<-data.frame(cbind(c(1:48),Ports,Services),portsnum=as.numeric(Ports))

working_data$servindex <- c(match(working_data$port,servdict$portsnum,nomatch = NA))
working_data<-merge(working_data,servdict,no.dups = F,incomparables = "NA",by.x = "servindex",by.y = "V1",all = F)
working_data <- working_data |> mutate("ports"=NULL,"portsnum"=NULL,"servindex"=NULL) 

rm(Ports,Services,servdict)
gc()

portmatchdata<- vroom::vroom("../../data/external/service-names-port-numbers.csv",num_threads=as.numeric(parallel::detectCores(logical=T)-1),quote=c("\""),skip=1,delim=c(","),col_select=c(1:3),col_names=c("service","port","protocol"),col_types=c("c","c","c"),skip_empty_rows=T,na=c("",",,,","NA"),escape_double=T,progress=F)
portmatchdata<-na.omit(portmatchdata)
gc()

working_data<-left_join(working_data,portmatchdata,by = c("port","protocol"))

rm(portmatchdata)
gc()

working_data<-working_data |> mutate("service"=NULL,"Ports"=NULL,"year"=NULL) |> rename("service"="Services") |> group_by(datetime) |> arrange(.by_group=T)

save("working_data",file="../../data/internal/working_data.RDA",compress="gzip")
gc(F,T,T)

require(reticulate)
reticulate::py_run_file("../Python/databases.py")
unloadNamespace("reticulate")
rm(working_data)
gc(F,T,T)


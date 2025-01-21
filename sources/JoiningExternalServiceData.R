gc(F,T,T)
rs()

ddos1<-readRDS("data/internal/rds/ddos_grouped.RDS")
sys.source("sources/functions.r",envir=.GlobalEnv,keep.source=T,keep.parse.data=T)


require(vroom)
require(dplyr)
require(tidyr)
require(tibble)
require(tidyselect)
require(readr)
gc()

portmatchdata<- vroom::vroom("data/external/service-names-port-numbers.csv",num_threads=10,quote=c("\""),skip=1,delim=c(","),col_select=c(1:3),col_names=c("service","port","SRCProtocol"),col_types=c("c","c","c"),skip_empty_rows=T,na=c("",",,,","NA"),escape_double=T,progress=F)

portmatchdata<-na.omit(portmatchdata)
colnames(portmatchdata) <- c("service","port","protocol")  
portmatchdata1<-left_join(ddos1,portmatchdata,by = c("port","protocol"))

port<-c("1433","99999","445","3389","80","56338","8080","22","3306","2193","135","53","23","5060","6666","443","3128","5900","19","1469","21","25","110","143","7","389","123","68","5432","1434","1900","5353","161","179","139","137","111","0","13","9","3","2","1","37","33","26","38","42")
services<-c("MSSQL_Server","ICMP","SMB","RDP","HTTP","UDP_Flood1","HTTPAlt","SSH","MySQL","UDP_Flood2","RPC","DNS","Telnet","SIP","IRC","HTTPS","Squid_Proxy","VNC","CHARGEN","AAL_LM","FTP","SMTP","POP3","IMAP","Echo","LDAP","NTP","DHCPClient","PostgreSQL","MSSQL_Monitor","SSDP","MDNS","SNMP","BGP","NETBIOS_ssh","NETBIOS_ns","RCPBind","Reserved","Daytime","Discard","compressnet","compressnet","tcpnux","time","dsp","unassigned","rap","nameserver_WIN")

portmatchdata1$port <- as.numeric(portmatchdata1$port)
port<-as.numeric(port)

rplceindex<- which(as.character(portmatchdata1$protocol) == "ICMP")
#portmatchdata1$service[rplceindex] <- "ICMP"
portmatchdata1$protocol[rplceindex] <- "ICMP"

rplceindex<- which(portmatchdata1$Ports == "0")
#portmatchdata1$service[rplceindex]<-"Reserved"
portmatchdata1$protocol[rplceindex]<-"Reserved"

#portmatchdata1 <- portmatchdata1 |> group_by(port) |> arrange(.by_group = T)

save(portmatchdata1,"data/internal/rda/FullPortRankings.RDA",compress="gzip")
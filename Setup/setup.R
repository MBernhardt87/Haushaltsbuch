if(.Platform$OS.type=="windows"){
  URL<-"https://sqlite.org/2018/sqlite-tools-win32-x86-3250200.zip"
} else if(.Platform$OS.type=="linux"){
  URL<-"https://sqlite.org/2018/sqlite-tools-linux-x86-3250200.zip"
}else{
  stop("OS not supported")
}


filename<-basename(URL)
download.file(URL,file.path("Setup",filename))
unzip(file.path("Setup",filename),exdir = getwd())
# CreateDBURI<-paste(getwd(),"/",unlist(str_split(filename,"\\."))[1],"/sqlite3.exe ",getwd(),"/vault.db",sep = "")
# system(CreateDBURI)
for (tbl in c("tbl_konto","tbl_einnahmenAusgaben","tbl_parseZuordnung","tbl_katZuordnung","tbl_kontostand")){
PopulateDB<-paste(getwd(),"/",unlist(str_split(filename,"\\."))[1],"/sqlite3.exe ",getwd(),"/vault.db ","\"",".read ",getwd(),"/Setup/",tbl,".sql","\"",sep = "")
system(PopulateDB)
}

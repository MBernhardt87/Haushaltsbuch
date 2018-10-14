GetSQLData<-function(SQLQuery,TBLQuery=T,SQLDB="vault.db"){
  require(RSQLite)
  con<-dbConnect(drv=RSQLite::SQLite(),dbname=SQLDB)
  if(TBLQuery){
    if (sum(c(stringr::str_detect(SQLQuery,"select"),stringr::str_detect(SQLQuery,"SELECT")))==0){
      return(dbReadTable(con,SQLQuery))
    } else {
      stop("SQLQuery seems to be a SQL Command String but TBLQuery is TRUE!")
    }
  } else {
    if (sum(c(stringr::str_detect(SQLQuery,"select"),stringr::str_detect(SQLQuery,"SELECT")))>0){
      return(dbGetQuery(con,SQLQuery))
    } else {
      stop("SQLQuery seems to be a SQL Table but TBLQuery is FALSE!")
    }
  }
  dbDisconnect(con)
}

WriteSQLData<-function(Source_DF,Target_DF,SQLDB="vault.db",mode=c("append","overwrite","temporary")){
  require(RSQLite)
  con<-dbConnect(drv=RSQLite::SQLite(),dbname=SQLDB)
  mode<-match.arg(mode)
  if(!is.data.frame(Source_DF)){stop(paste(Source_DF,"is not a data.frame object!",sep=" "))}
  if(!dbExistsTable(con,Target_DF)){stop(paste(Target_DF,"is not a table of",SQLDB,sep=" "))}
  if(mode=="append"){
    dbWriteTable(con,Target_DF,Source_DF,append=T)
    dbDisconnect(con)
    return(T)
  } else {
    if (mode=="overwrite"){
      dbWriteTable(con,Target_DF,Source_DF,overwrite=T)
      dbDisconnect(con)
      return(T)
    } else {
      if(mode=="temporary"){
        dbWriteTable(con,Target_DF,Source_DF,temporary=T)
        dbDisconnect(con)
        return(T)
      } else {
        warning("Nothing done!")
        dbDisconnect(con)
        return(F)
      }
    }
  }
}

ReadSQLFromFile<-function(filename,path=getwd()){
  return(paste0(readLines(paste(path,filename,sep="/"))))
}

CheckDBConsistency<-function(TblName,DateColumn="Date",Lag=30){
  process.start<-Sys.time()
  error.found<-F
  #require(data.table)
  require(dplyr)
  require(lubridate)
  message(paste("Checking ",TblName,sep=""))
  top.date<-max(GetSQLData(paste("select max(",DateColumn,") from ",TblName,sep=""),F))
  min.date<-min(GetSQLData(paste("select min(",DateColumn,") from ",TblName,sep=""),F))
  message("Getting SQL Table Snippet...")
  if (Lag==0){
    dt.check<-GetSQLData(TblName,T)
  } else {
    dt.check<-GetSQLData(paste("select * from",TblName,"where Date >",as_date(top.date)-Lag,sep=" "),F)
  }
  message("Getting SQL Table Snippet...done")
  message("Check SQL Table Consistency...")
  if(nrow(dt.check)!=nrow(unique(dt.check))){
    error.found<-T
    message("INCONSISTENCIES FOUND...")
    check.date<-top.date
    db.trigger<-T
    while(db.trigger){
      cond<-paste(DateColumn,"<",check.date,sep="")
      tmp.dt<-dt.check %>% filter_(cond)
      db.trigger<-nrow(tmp.dt)!=nrow(unique(tmp.dt))
      if(db.trigger){
        check.date<-check.date-1
      }
    }
    message("Checking for biggest Subset of consistent Data...done")
    message(paste("Reseting SQL Table to ",as_date(check.date)-1,"...",sep=""))
    dt.whole<-GetSQLData(TblName)
    cond<-paste(DateColumn,"<",check.date,sep="")
    dt.cut<-dt.whole %>%filter_(cond)
    WriteSQLData(dt.cut,TblName,mode="overwrite")
    message(paste("Reseting SQL Table to ",as_date(check.date)-1,"...done",sep=""))
  } else{
    message("No Inconsistencies found!")
  }
  message("Check SQL Table Consistency...done")
  print(Sys.time()-process.start)
  return(error.found)
}


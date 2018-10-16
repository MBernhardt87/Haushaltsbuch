function(input, output) {
    values <- reactiveValues()

## Verwaltung
  ##Kontoverwaltung
    ## New Konto Tabelle generieren
    output$NewKontoData<-renderRHandsontable({
      rhandsontable(tibble(Kontonummer="",Inhaber="",Bank="",Waehrung="",Typ=""))
    })
    ## Datenbestand an Konto holen
    output$Kontos<-renderTable({
      GetSQLData("tbl_konto")
    })
    ## Neues Konto hinzufügen
    observe({
      if(input$SubmitKonto>0){
        if(T){
          values[["DF"]]<-hot_to_r(input$NewKontoData)
          NewKonto.tbl<-isolate(values[["DF"]])
          if(WriteSQLData(NewKonto.tbl,"tbl_konto",mode = "append")){
            showModal(modalDialog(title = "Konto",paste("Konto",input$NewKontoName,"wurde hinzugefügt!"),easyClose = T))
            output$Kontos<-renderTable({
              GetSQLData("tbl_konto")
            })
            #updateSelectInput(session,inputId = "KontenListe",choices=GetSQLData("select Kontonummer from tbl_konto",F)[,1])
            output$NewKontoData<-renderRHandsontable({
              rhandsontable(tibble(Kontonummer="",Inhaber="",Bank="",Waehrung="",Typ=""))
            })
          } else {
            stop("Error adding Konto")
          }
        }
      }
    })
    ## Konto löschen
    observe({
      if(input$DeleteKonto>0){
        if(ModifySQLDB(paste("delete from tbl_konto where Kontonummer=",input$KontenListe,sep = ""))){
          showModal(modalDialog(title = "Kontolöschung",paste("Konto",input$KontenListe,"wurde gelöscht!"),easyClose = T))
          output$Kontos<-renderTable({
            GetSQLData("tbl_konto")
          })
            #updateSelectInput(session,inputId = "KontenListe",choices=GetSQLData("select Kontonummer from tbl_konto",F)[,1])
        } else {
          stop("Error deleting Konto")
        }
      }
    })
  
  ## Kontoauszug importieren
    output$Datenbestand<-renderText({
      minDate<-GetSQLData("select min(Buchungsdatum) from tbl_kontostand",F)
      maxDate<-GetSQLData("select max(Buchungsdatum) from tbl_kontostand",F)
      paste("Es sind Daten vom",minDate,"bis",maxDate,"in der Datenbank")
    })
    observe({
      if(!is.null(input$NeuerKontoauszug)){
        output$KontoauszugData<-renderDataTable({
          input.tbl<-read_delim(input$NeuerKontoauszug$datapath,";", escape_double = FALSE, locale = locale(date_names = "de",decimal_mark = ",", grouping_mark = "."),trim_ws = TRUE)
          Column.mapping<-GetSQLData(paste("select QuellSpalte,ZielSpalte from tbl_parseZuordnung where Bank=(Select Bank from tbl_konto where Kontonummer=",input$Kontoauszug_Konto,")",sep=""),F)
          input.tbl<-input.tbl[,c(1,which(names(input.tbl) %in% Column.mapping$QuellSpalte))]
          colnames(input.tbl)<-c("Buchungsdatum",inner_join(tibble(QuellSpalte=names(input.tbl)),Column.mapping,by="QuellSpalte")$ZielSpalte)
          values[["Kontoauszug"]]<-input.tbl
          datatable(input.tbl)
        })
      }
    })
    observe({
      if(input$ShowNA_Kontoauszug=="Zeilen ohne Kategorie"){
        if(is.null(values[["Kontoauszug"]]) | is.na(values[["Kontoauszug"]])){
          showModal(modalDialog(title = "Kontoauszug","Es ist kein Kontoauszug geladen!",easyClose = T))
        } else {
          output$KontoauszugData<-renderDataTable({
            input.tbl<-values[["Kontoauszug"]]
            input.tbl %>% filter(is.na(Schluessel))
          })
        }
      } else {
        output$KontoauszugData<-renderDataTable({
          values[["Kontoauszug"]]
        })
      }
    })
    observe({
      if(input$UploadKontoauszug>0){
        input.tbl<-values[["Kontoauszug"]]
        input.tbl<-input.tbl %>% mutate(Monat=month(dmy(Buchungsdatum)),Jahr=year(dmy(Buchungsdatum)), Kontonummer=input$Kontoauszug_Konto)
        LastDate<-GetSQLData(paste("select max(Buchungsdatum) from tbl_kontostand where Kontonummer=",input$Kontoauszug_Konto,sep=""),F)[,1]
        if(!is.na(LastDate)){
          
        }
        if(WriteSQLData(input.tbl,"tbl_kontostand")){
          showModal(modalDialog(title = "Upload","Kontoauszug in Datenbank gespeichert!",easyClose = T))
        } else {
          stop("Error uploading File to DB")
        }
          
    }
    })
   
}
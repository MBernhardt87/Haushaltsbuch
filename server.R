function(input, output) {
    values <- reactiveValues()
    observe({
      if(input$ActiveTab=="App beenden"){
        showModal(modalDialog(title = "Exit",paste("Haushaltsbuch wurde beendet! \n Das Fenster kann geschlossen werden"),easyClose = T))
        shiny::stopApp()
      }
    })
## Verwaltung
  ##Kontoverwaltung
    ## New Konto Tabelle generieren
    output$NewKontoData<-renderRHandsontable({
      rhandsontable(tibble(Kontonummer="",Inhaber="",Bank="",Waehrung="",Typ="",Anfangsbestand=0))
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
              rhandsontable(tibble(Kontonummer="",Inhaber="",Bank="",Waehrung="",Typ="",Anfangsbestand=0))
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
    observe({
      if(is.null(values[["Kontoauszug"]])){
        output$Datenbestand<-renderText({
          minDate<-GetSQLData("select min(Buchungsdatum) from tbl_kontostand",F)
          maxDate<-GetSQLData("select max(Buchungsdatum) from tbl_kontostand",F)
          paste("Es sind Daten vom",as_date(minDate[1,]),"bis",as_date(maxDate[1,]),"in der Datenbank")
        })
      }
    })
    ## Lade ausgewaelten Kontoauszug
    observe({
      if(!is.null(input$NeuerKontoauszug)){
        output$KontoauszugData<-renderRHandsontable({
          input.tbl<-read_delim(input$NeuerKontoauszug$datapath,";", escape_double = FALSE, locale = locale(date_names = "de",decimal_mark = ",", grouping_mark = "."),trim_ws = TRUE)
          Column.mapping<-GetSQLData(paste("select QuellSpalte,ZielSpalte from tbl_parseZuordnung where Bank=(Select Bank from tbl_konto where Kontonummer=",input$Kontoauszug_Konto,")",sep=""),F)
          input.tbl<-input.tbl[,c(1,which(names(input.tbl) %in% Column.mapping$QuellSpalte))]
          colnames(input.tbl)<-c("Buchungsdatum",inner_join(tibble(QuellSpalte=names(input.tbl)),Column.mapping,by="QuellSpalte")$ZielSpalte)
          input.tbl<-filter(input.tbl,!is.na(Buchungsdatum))
          values[["Kontoauszug"]]<-input.tbl
          rhandsontable(input.tbl,width=1800,rowHeaderWidth = 20) %>% hot_rows(fixedRowsTop = 1) %>% hot_cols(colWidths = 200)
        })
      }
    })
    ## Zeigt alle Reihen ohne Kategorie an
    observeEvent(input$ShowNA_Kontoauszug,{
      if(input$ShowNA_Kontoauszug=="Zeilen ohne Kategorie"){
        if(is.null(values[["Kontoauszug"]])){
          showModal(modalDialog(title = "Kontoauszug","Es ist kein Kontoauszug geladen!",easyClose = T))
        } else {
          output$KontoauszugData<-renderRHandsontable({
            input.tbl<-values[["Kontoauszug"]]
            rhandsontable(input.tbl %>% filter(is.na(Schluessel)),width=1800,rowHeaderWidth = 20) %>% hot_rows(fixedRowsTop = 1) %>% hot_cols(colWidths = 200)
          })
        }
      } else {
        if(is.null(values[["Kontoauszug"]])){
        } else {
        values[["Kontoauszug"]][is.na(values[["Kontoauszug"]]$Schluessel),'Schluessel']<-hot_to_r(input$KontoauszugData)$Schluessel
        output$KontoauszugData<-renderRHandsontable({
          rhandsontable(values[["Kontoauszug"]],width=1800,rowHeaderWidth = 20) %>% hot_rows(fixedRowsTop = 1) %>% hot_cols(colWidths = 200)
        })
        }
      }
    })
    ## Laedt den angezeigten Kontoauszug in die Datenbank
    observe({
      if(input$UploadKontoauszug>0){
        input.tbl<-hot_to_r(input$KontoauszugData)
        input.tbl<-input.tbl %>% mutate(Monat=month(dmy(Buchungsdatum)),Jahr=year(dmy(Buchungsdatum)), Kontonummer=input$Kontoauszug_Konto)
        LastDate<-dmy(GetSQLData(paste("select max(Buchungsdatum) from tbl_kontostand where Kontonummer=",input$Kontoauszug_Konto,sep=""),F)[,1])
        input.tbl$Buchungsdatum<-dmy(input.tbl$Buchungsdatum)
        input.tbl$Schluessel<-str_trim(input.tbl$Schluessel)
        input.tbl<-input.tbl %>% filter(!is.na(Buchungsdatum))
        if(!is.na(LastDate)){
          input.tbl<- input.tbl %>% filter(Buchungsdatum>LastDate)
        }
        if(WriteSQLData(input.tbl,"tbl_kontostand")){
          showModal(modalDialog(title = "Upload","Kontoauszug in Datenbank gespeichert!",easyClose = T))
          values[["Kontoauszug"]]<-NULL
        } else {
          stop("Error uploading File to DB")
        }
          
    }
    })
  ##Kontoübersicht
    ## Laedt eine Pivottabelle für das genannte Konto
    observeEvent(input$Konto_Kontouebersicht,{
      output$Kontouebersicht<-renderRpivotTable({
        data<-GetSQLData(paste(ReadSQLFromFile("/Utils/GetPivotRaw.sql"),input$Konto_Kontouebersicht),F)
        data<-data %>% mutate(Monat=month(as_date(Buchungsdatum)),Jahr=year(as_date(Buchungsdatum)))
        data$Buchungsdatum<-as_date(data$Buchungsdatum)
        
        rpivotTable(data=data,
                    rows=c("Hauptkategorie","Nebenkategorie","Unterkategorie"),
                    cols = c("Jahr","Monat"),
                    aggregatorName = "Summe",
                    vals="Betrag",
                    locale = "de"
        )
      })
    })
}
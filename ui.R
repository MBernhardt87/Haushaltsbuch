navbarPage("Haushaltsbuch",
  tabPanel("Verwaltung",
           tabsetPanel(
              tabPanel("Kontenverwaltung",
                       fluidPage(
                         fluidRow(
                           column(width=6,
                                  rHandsontableOutput("NewKontoData")
                                  #textInput("NewKontoName",label=NULL,value="Neue Kontonummer")
                           ),
                           column(width=1,
                                  actionButton("SubmitKonto",label="Neues Konto anlegen")
                                  ),
                           column(width=2,offset=2,
                                  selectInput("KontenListe",label=NULL,choices = GetSQLData("select Kontonummer from tbl_konto",F)[,1])
                                  ),
                           column(width=1,
                                  actionButton("DeleteKonto",label="Konto löschen")
                                  ),
                           column(width=4)
                         ),
                         fluidRow(
                           column(width=12,
                              tableOutput("Kontos")    
                           )
                         )
                       )
                       ),
              tabPanel(id="Kontoauszug_Tab",title="Kontoauszüge importieren",
                       fluidPage(
                         fluidRow(
                           column(width=2,
                                  selectInput("Kontoauszug_Konto",label=NULL,choices=GetSQLData("select Kontonummer from tbl_konto",F)[,1]),
                                  fileInput("NeuerKontoauszug",label=NULL)
                                  ),
                           column(width=2,
                                  strong(textOutput("Datenbestand"))
                                  ),
                           column(width=2,
                                  radioButtons("ShowNA_Kontoauszug",label="Filter",choices = list("Alle Zeilen","Zeilen ohne Kategorie")),
                                  actionButton("UploadKontoauszug",label="Kontoauszug hochladen")
                                  )
                         ),
                         fluidRow(
                           column(width=12,
                                  rHandsontableOutput("KontoauszugData")
                                  )
                         )
                       )
                       ),
              tabPanel("Datenstand anzeigen",
                       p("2")
                       ),
              tabPanel("Kategorienverwaltung",
                       p("3")
                       )
           )
  ),
  tabPanel("Ausgabenverwaltung",
          p("Ausgabenverwaltung")
  ),
  tabPanel("Einnahmenverwaltung",
          p("Einnahmenverwaltung")
  ),
  tabPanel("Kontoübersicht",
          verticalLayout(
           selectInput("Konto_Kontouebersicht",label=NULL,choices=GetSQLData("select kontonummer from tbl_konto",F)[1,]),
           rpivotTableOutput("Kontouebersicht")
          )
          
  ),
  tabPanel("Kontoverlauf",
          p("Kontoverlauf")
  ),
  tabPanel("Kontoanalyse",
          p("Kontoanalyse")
  )
)

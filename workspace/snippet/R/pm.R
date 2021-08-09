
#' Initialisierung
#'
#' @return
#' @export
#'
#' @examples
init <- function() {
  aktivitaeten <<- c(
    "Fachmodell Entwurf SQM",
    "Fachmodell Entwurf SBM",
    "Entwurf Schnittstellen von SBM zu SQM",
    "Spezifikation Fachmodell SQM",
    "Spezifikation Fachmodell SBM",
    "Entscheidung Laufzeitumgebung SQM",
    "Schnittstelle SQM Service (SBM Service ist Konsument)",
    "Schnittstelle SBM Service (Prozessanwendung ist Konsument)",
    "Implementierung SQM",
    "Implementierung SBM Service mit SQM Service Mocks",
    "Finalisierung SBM Service (Integration SQM Service)",
    "Implementierung GUI der Prosessanwendung",
    "Spezifikation der GUI in Features",
    "Oberflächen Tests",
    "Implementierung Prozessanwendung mit SBM Service Mocks",
    "Finalisierung Prozessanwendung mit SBM Service",
    "Schnittstelle zu DMS (insbesondere zu nutzende Metadaten)",
    "Entscheidung DMS Verantwortlichkeit",
    "Implementierung DMS Anbindung in SBM oder Prozessanwendung",
    "POC SQM in Laufzeitumgebung R, openCpu in Docker Container",
    "POC SQM in Laufzeitumgebung Java auf Applikationsserver Weblogic",
    "POC SQM in Laufzeitumgebung auf BI Plattform"
  )

  aktivitaetenTabelle <<-
    tibble::tibble(Akivitaetsnummer =  c(1:length(aktivitaeten)),
           Beschreibung = aktivitaeten)

  # Type 1 Finish to start (FS): activity cannot start until precedor has finished
  # Type 2 Start to start (SS): activity cannot start until precedor has started
  # Type 3 Finish to finish (FF): activity cannot finish until precedor has finished
  # Type 4 Finish to start (FS): activity cannot finish until precedor has started

  prec1and2 <<-
    matrix(0,
           nrow = length(aktivitaeten),
           ncol = length(aktivitaeten),
           dimnames = list(1:length(aktivitaeten),
                           1:length(aktivitaeten)))

  prec3and4 <<-
    matrix(0,
           nrow = length(aktivitaeten),
           ncol = length(aktivitaeten),
           dimnames = list(1:length(aktivitaeten),
                           1:length(aktivitaeten)))

  # Schnittstellen können erst betrachtet werden, wenn man die Fachmodelle inspiziert hat
  prec1and2[1, 3] <<- 1
  prec1and2[2, 3] <<- 1

  # Finalisierung Fachmodell kann erst begonnen werden wenn man auch die Schnittstellen betrachtet
  prec1and2[3, 4] <<- 2
  prec1and2[3, 5] <<- 2

  # Implementierung SQM kann erst begonnen werden, wenn Laufzeitumgebung bekannt
  prec1and2[6, 9] <<- 1

  # Fachmodell kann nur abgeschlossen werden, wenn Schnittstellen klar sind
  prec3and4[7, 4] <<- 3
  prec3and4[8, 5] <<- 3

  # SBM Implementierung kann erst begonnen werden, wenn Schnittstelle zu SQM klar ist und Fachmodell steht

  prec1and2[7, 10] <<- 1
  prec1and2[5, 10] <<- 1

  # SQM muss fertig sein, um in SBM integriert werden können
  prec1and2[9, 11] <<- 1

  # GUI soll in Feature Dateien beschrieben werden
  prec1and2[12, 13] <<- 2

  # Oberflächentests brauchen Feature Dateien
  prec1and2[13, 14] <<- 2

  # Prozessapplikation wird zusammen mit der GUI implementiert
  prec1and2[11, 15] <<- 2

  # Prozessapplikation kann SBM Service (der SQM Mocks benutzt) verwenden
  prec1and2[10, 16] <<- 1

  # Entscheidung über DMS Verantwortlichkeit nach Klärung Scnittstellen SBM
  prec3and4[8, 17] <<- 3

  # Implementierung DMS Anbindung nach Klärung, wer verantwortlich ist
  prec1and2[18, 19] <<- 1

  # Entscheidung Laufzeitumgebung SQM sollte wohl begründet sein
  prec1and2[20, 6] <<- 1
  prec1and2[21, 6] <<- 1
  prec1and2[22, 6] <<- 1

  dauer <<- c(5, 5, 1, 10, 10, 1, 5, 5, 20, 20, 5, 10, 5, 20, 20, 5, 5, 1, 10, 5, 5, 5)

  durationTable <<-
    tibble::tibble(
      Aktivitaetsnummer =  c(1:length(aktivitaeten)),
      Aktivitaet = aktivitaeten,
      Dauer = dauer
    )
}

#' Berechnung der Summe der Aktivitätendauern
#'
#' @return
#' @export
#'
#' @examples
sumOfDurations <- function() {
  init()
  sum(dauer)
}

#' Dauer der Aktivität i
#'
#' @param i
#'
#' @return
#' @export
#'
#' @examples
getDurationOfAktivitaet <-function(i) {
  init()
  dauer[i]
}


#' AON Graph
#'
#' @return
#' @export
#'
#' @examples
plotAONGraph <- function() {
  init()
  ProjectManagement::dag.plot(prec1and2, prec3and4)
}


#' Boxplot der Aktivitätendauern
#'TODO: Formatierung wie in SCR
#' @return
#' @export
#'
#' @examples
durationBoxplot <- function() {
  init()
  ggplot2::ggplot(durationTable, aes(x=dauer)) + geom_boxplot()
}


#' Kompletter Schedule Output
#'
#' @return
#' @export
#'
#' @examples
schedule <- function() {
  init()
  theSchedule <- ProjectManagement::schedule.pert(dauer, prec1and2, prec3and4)
  theSchedule
}

#' Plot des Critical Path aus Schedule Output
#'
#' @return
#' @export
#'
#' @examples
criticalPath <- function() {
  schedule()[[1]]
}

#' Schedule Html Widget als Output
#'
#' @return
#' @export
#'
#' @examples
schedulePlot <- function() {
  widget <- schedule()[[3]]
  widget
}

#' Schedule Widget as Html
#'
#' @return
#' @export
#'
#' @examples
scheduleWidget <- function() {
  outputfile <- tempfile(fileext=".html");
  htmlwidgets::saveWidget(schedulePlot(), outputfile)
  return(readr::read_file(outputfile))
}


costPerActivity <- function(costFaktor, durationTeiler) {
  init()
  minDauer <- round(dauer / durationTeiler)
  costs <- c(1:length(aktivitaeten) * costFaktor)
  ProjectManagement::mce(dauer,
      minDauer,
      prec1and2,
      prec3and4,
      costs,
      duration.project = NULL)
}

#' Knit to html converter
#'
#' Use knitr and markdown to convert knitr to html
#'

#' @param snippetName .
#' @param ... arguments passed on to markdownToHTML
#' @return HTML string

knithtml <- function(snippetName, ...){
  inputfile <- system.file("modul/project", paste0(snippetName, ".Rmd"), package="snippet")
  outputfile <- tempfile(fileext=".Rmd");
  htmlfile <- tempfile(fileext=".out");


  knitr::knit(inputfile, outputfile);
  markdown::markdownToHTML(outputfile, output=htmlfile, fragment.only=FALSE, ...);
  # htmldoc <- readLines(htmlfile);

  # for(figfile in list.files("figure", full.names=TRUE)){
  #   #upload figures to imgur
  #   figurl <- imguR::imguRupload(figfile)[["links.original"]]
  #   htmldoc <- sub(figfile, figurl, htmldoc)
  # }

  # newhtmlfile <-  tempfile(fileext=".html");
  # writeLines(htmldoc, newhtmlfile);
  # return(newhtmlfile);
  return(readr::read_file(htmlfile))
}

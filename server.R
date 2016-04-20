library(shiny)
library(randomForest)
library("caret")
library("mlbench")
library("pROC")
library(data.table)
library("rpart")
library("caretEnsemble")


shinyServer(function(input, output, session) { 
  values <- reactiveValues()
  
  
  output$ROC <- renderUI({
    if (is.null(values$ge)){
      return(HTML(""))
    }
    HTML(paste(
      "ROC AUCs:",
      "Greedy Ensemble", values$ge$ens_model$results$ROC[1],
      "GLM", values$ge$models$glm$results$ROC[1],
      "RF", values$ge$models$rf$results$ROC[1],sep="<br>")
      )
    
  })
  

  
  
  output$contents <- renderDataTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    box<-inFile$name
    #print(paste('[',box,']'))
    
    if (is.null(inFile))
      return(NULL)
    
    input$loadFile
    if (input$loadFile == 0) {
      return(NULL)
    }
    
    isolate (
      f<-fread(inFile$datapath, header=F, data.table=F)#, skip=4000)  
      #f<-fread( "/import/transfer/project/ChemTech/ChemSORT/DROPBOX/Results report example 1.csv")
      #basename(inFile$datapath)
      #dirname(inFile$datapath)
      #read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
    )  
    # check names of f if appropriate write to database
    #resultTableHeader <- c('SAMPLE_NAME',	'BOX',	'SAMPLE', 'VALUE',	'UNIT','PROJECT','ERRPAGE','ANALYTE','SAMPLE2ANALYTE_ID','RAW_DATA_FILE');

    
    
    #write.table(f,file="loadedFile.txt",quote=FALSE,sep="\t",row.name=FALSE,col.names=TRUE)
    
    set.seed(107)
    inTrain <- createDataPartition(y = f$V1, p = .75, list = FALSE)
    training <- f[ inTrain,]
    testing <- f[-inTrain,]
    my_control <- trainControl(
      method="boot",
      number=5,
      savePredictions="final",
      classProbs=TRUE,
      index=createResample(training$V1, 5),
      summaryFunction=twoClassSummary
    )
    
    
    model_list <- caretList(
      V1~., data=training,
      trControl=my_control,
      methodList=c("glm", "rf")
    )
    
    greedy_ensemble <- caretEnsemble(
      model_list, 
      metric="ROC",
      trControl=trainControl(
        number=2,
        summaryFunction=twoClassSummary,
        classProbs=TRUE
      ))
    values$ge <<- greedy_ensemble
    
    
    
    f
  })
  
  
  
  
})
shinyUI(
  pageWithSidebar (
    headerPanel ("Can it Be Predicted?"),
    
    sidebarPanel (
      h2("ROC-AUC Calculator"),
      HTML("Upload a CSV to see if the first column can be predicted<br>"),
      HTML("Your data will be sliced for cross validation, Classifier hyper-parameters will be tuned via random bagging, and an ensemble classifier will also be trained<br><br>"),
      HTML("This tool currently only works for classification, Use this tool as a quick check on the quality of your data before spending time developing a complicated solution for prediction. If the first column of your CSV can be predicted your ROC-AUC will be signiciantly above 0.5<br><br>"),
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      actionButton("loadFile","Load & Show")
      
    ),
    mainPanel(
      htmlOutput("ROC"),
      dataTableOutput('contents')
    )
  )
)
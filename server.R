
server <- function (input, output, session) {
  #--Importing Files--####  
  source('global.R', local = TRUE)
  
  if(Sys.info()["sysname"][[1]]=="Linux" | Sys.info()["sysname"][[1]]=="Darwin") {
    source("functions.R", local = TRUE)
  } else {
    source("functions_wsl.R", local = TRUE)
  }
  
  
  #--Initializing reactive values--####
  current_selection <- reactiveVal()
  req_tables <- reactiveValues()
  all_sel_ids <- reactiveValues (dt = data.frame())
  all_sel_ids_FE <- reactiveValues (dt = data.frame())
  all_sel_ids_PMID <- reactiveValues (dt = data.frame())
  all_sel_ids_network_STRING <- reactiveValues (dt = data.frame())
  all_sel_ids_network_STITCH <- reactiveValues (dt = data.frame())
  
  org_map <- reactiveValues(
    `Homo sapiens (Human)` = 'hsapiens',
    `Mus musculus (Mouse)` = 'mmusculus',
    `Rattus rattus (Rat)` = "rnorvegicus",
    `Bos taurus (Cow)` = "btaurus",
    `Drosophila melanogaster` = "dmelanogaster",
    `Ceanorhabditis elegans` = "celegans",
    `Saccharomyces cerevisiae` = "scerevisiae",
    `Zea mays` = "zmays",
    `Arabidopsis thaliana` = "athaliana")
  
  db_map <- reactiveValues(
    `GO molecular function` = 'GO:MF',
    `GO cellular component` = 'GO:CC',
    `GO biological process` = 'GO:BP',
    `KEGG` = 'KEGG',
    `Reactome` = 'REAC',
    `WikiPathways` = 'WP',
    `TRANSFAC` = 'TF',
    `miRTarBase` = 'MIRNA',
    `Human Protein Atlas` = 'HPA',
    `CORUM` = 'CORUM',
    `HP` = 'HP')
  
  species_map <- reactiveValues(
    `Homo sapiens (Human)` = 9606,
    `Mus musculus (Mouse)` = 10090,
    `Rattus rattus (Rat)` = 10116,
    `Bos taurus (Cow)` = 9913,
    `Drosophila melanogaster` = 7227,
    `Ceanorhabditis elegans` = 6239,
    `Saccharomyces cerevisiae` = 2528333,
    `Escherichia coli` = 2605620,
    `Zea mays` = 381124,
    `Arabidopsis thaliana` = 3702)
  
  
  
  
  
  
  #--Current selection (delete this?)--####
  observeEvent(input$select, {
    current_selection(input$select)
  })
  
  
  
  
  
  
  
  
  
  #----Upload and convert to html multiple files (pdf, txt)----####
  observeEvent(input$upload,  {
    cat("uploading_files...\n", file=stderr())
    cat(session$token, file=stderr())
    on.upload_new(input$upload, session)
    removeModal()
    updatePrettyCheckboxGroup(session, inputId="select",
                              choiceNames = file_names,
                              choiceValues = file_ids,
                              selected = file_ids
    )
    updatePrettyCheckboxGroup(session, inputId = 'tbl_select', choiceValues = file_ids, choiceNames = file_names, selected = file_ids)
  })
  
  #----TextAreaInput into list of files---####
  observeEvent(input$addtext, {
    txt.file_new(input$textinput, session)
    req(input$textinput)
    updateTextAreaInput(session, 'textinput', value = '',  placeholder = txt_plcholder_updated)
    removeModal()
    updatePrettyCheckboxGroup(session, "select",
                              choiceNames = file_names,
                              choiceValues = file_ids,
                              selected = file_ids)
    updatePrettyCheckboxGroup(session, inputId = 'tbl_select', choiceValues = file_ids, choiceNames = file_names, selected = file_ids)
  })
  
  #----TextAreaInput reset button---#
  observeEvent(input$clearText, {
    updateTextAreaInput(session, 'textinput', value = '',  placeholder = txt_plcholder)
    
  })
  
  observeEvent(input$addexample, {
    updateTextAreaInput(session, 'textinput', value = txt_example)
  })
  
  #----Hide panel as long as the add button has not been pushed----#
  output$text_ready <- reactive({
    return(isolate(input$textinput) != "" & input$addtext > 0)
  })
  outputOptions(output, 'text_ready', suspendWhenHidden = FALSE)  
  
  #----check if file has been uploaded----####  
  output$upload_ready <- reactive({
    return(!is.null(input$upload))
  })
  outputOptions(output, 'upload_ready', suspendWhenHidden = FALSE)
  
  
  #----Display the selected files in different tabpanels, annotation options and results----####
  observeEvent(input$select, {
    output$fileview <- renderUI({
      myTabs <- lapply(input$select, function(id) {
        
        index <- which(file_ids==id)
        name <- file_names[[index]]
        fpath <- file_paths[[index]]
        tabPanel(title = strong(span((glue('{name}')), style='color:rgb(31, 191, 164)')),
                 tabBox(
                   id = sprintf('tabset%s', id), 
                   tabPanel('File', icon = icon('file-alt'), 
                            fluidRow(
                              div(id = sprintf('info%s', id), p('Selected entity type(s) are shown in', strong('"Entities"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px"),
                              div(id = sprintf('infonew%s', id), p(strong('New'), 'selected data are shown in', strong('"Entities"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px"),
                              actionButton(sprintf('showhide%s', id), label = NULL, icon = icon('angle-up'), size = 'sm'),
                              div(id = sprintf('boxpanel%s', id),
                                  fluidRow(
                                    column(6, pickerInput(
                                      inputId = sprintf('typepicker%s', id),
                                      label = 'Select entity type(s):',
                                      choices = filterchoices, 
                                      multiple = T,
                                      selected = filterchoices,
                                      width = '98%',
                                      options = list(
                                        `actions-box` = T,
                                        `deselect-all-text` = 'Deselect all',
                                        `select-all-text` = 'Select all',
                                        `none-selected-text` = 'No entity type selected',
                                        `selected-text-format` = paste0('count > ', length(filterchoices)-1),
                                        `count-selected-text` = 'ALL'
                                      )
                                    )
                                    ),
                                    column(6,
                                           selectizeInput(
                                             inputId = sprintf("orgpicker%s", id),
                                             label = "Select organism for protein annotation:",
                                             choices = organisms$print_name,
                                             multiple = F,
                                             selected = "Homo sapiens (Human) [NCBI Tax. ID: 9606]", # maybe use "Homo sapiens (Human) [NCBI Tax. ID: 9606]"
                                             width = "98%",
                                             options = list(
                                               placeholder = 'Select an option or start typing...'
                                             )
                                           )
                                    ),
                                    column(2, offset=10,
                                           actionLink(sprintf("org_list%s", id), "View available organisms", style="font-size:12px;text-align:right")
                                    )
                                  ),
                                  fluidRow(
                                    actionBttn(inputId = sprintf('annotationbtn%s', id), label = ' Annotate ', style = 'material-flat', color="success", size = 'sm', icon = icon('highlighter')),
                                    actionBttn(inputId = sprintf('annotreset%s', id), label = ' Reset ', style="material-flat", color="danger", size = 'sm', icon = icon('redo-alt'))
                                  ),
                                  
                              ),
                              
                              boxPlus(
                                width = 70,
                                solidHeader = T,
                                closable = F,
                                collapsible = T,
                                div(id=sprintf("tagging_legend%s",id), HTML('<table style="border-spacing: 0;border-collapse: collapse;width:100%">
<tr><td><b>Entity Categories:</b></td><td style="background-color:#FB8072; color:black">&nbsp;&nbsp;Protein&nbsp;&nbsp;</td><td style="background-color: #FDB462; color:black;">&nbsp;&nbsp;Chemical Compound&nbsp;&nbsp;</td><td style="background-color: #FFFFB3; color:black;">&nbsp;&nbsp;Organism&nbsp;&nbsp;</td><td style="background-color: #B3DE69; color:black;">&nbsp;&nbsp;Environment&nbsp;&nbsp;</td><td style="background-color: #8DD3C7; color:black;">&nbsp;&nbsp;Tissue&nbsp;&nbsp;</td><td style="background-color: #80B1D3; color:black;">&nbsp;&nbsp;Disease/Phenotype&nbsp;&nbsp;</td><td style="background-color: #D9D9D9; color:black;">&nbsp;&nbsp;Gene Ontology term&nbsp;&nbsp;</td></tr>
</table>'), br(), style="display:none"),
                                tags$iframe(id = sprintf("document-%s", id), class = 'pdf_frame', src = sprintf("%s", fpath), frameborder = '0'),
                                enable_dropdown = T,
                                dropdown_icon = 'search-plus',
                                dropdown_menu = dropdownItemList(
                                  style = 'background-color:rgba(0, 0, 0, 0.3);',
                                  sliderTextInput(toString(id), '', choices = seq(from = 10, to = 200, by = 10), grid = F, selected = 100, post = '% zoom', hide_min_max = T)
                                ),
                                uiOutput(sprintf("annpar-%s", id))
                              )
                            )
                   ),
                   tabPanel('Entities', icon = icon('table'), style = 'width:100%;',
                            div(id = sprintf('infonewtab%s', id), p(strong('New'), 'selected data are shown below', style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px"),
                            boxPlus(
                              width = 70,
                              closable = F,
                              solidHeader = T,
                              collapsible = T,
                              pickerInput(
                                inputId = sprintf('filter%s', id),
                                label = 'Filter by Type:',
                                choices = filterchoices,
                                selected = filterchoices,
                                multiple = T,
                                options = list(
                                  `actions-box` = T,
                                  `deselect-all-text` = 'Deselect all',
                                  `select-all-text` = 'Select all',
                                  `none-selected-text` = 'No Type selected',
                                  `selected-text-format` = paste0('count > ', length(filterchoices)-1),
                                  `count-selected-text` = 'ALL'
                                )
                              ),
                              DT::dataTableOutput(sprintf('tablentities%s', id)),
                              enable_dropdown = T, 
                              dropdown_icon = 'download',
                              dropdown_menu = dropdownItemList(
                                style = 'background-color: thristle;', 
                                downloadBttn(outputId = sprintf('downloadData%s', id), label = 'Download', style = 'material-flat', size = 'xs'),
                                p(id = sprintf('downloadtext%s', id), '(Download full or filtered table)')
                              ),
                              uiOutput(sprintf("annpar-%s-ent", id))
                            )
                   )
                 )
        )
      })
      do.call(tabsetPanel, myTabs)
    })
    
    
  })
  
  
  #----Show-hide annotation options----####
  observe({
    lapply(input$select, function(id) {
      observeEvent(input[[sprintf('showhide%s', id)]], {
        show_hide_options(input[[sprintf('showhide%s', id)]],
                          sprintf('showhide%s', id),
                          sprintf('boxpanel%s', id), 
                          session)
      })
    })
  })
  
  
  #----Show annotate buttons----####  
  observe({
    lapply(input$select, function(id) {
      observeEvent(input[[sprintf('typepicker%s', id)]], {
        shinyjs::show(sprintf('annotationbtn%s', id))
        shinyjs::show(sprintf('annotreset%s', id))
      })
    })
  })
  
  
  #----Rename files----####
  # This event passes program execution to javascript which prompts the user for new names for chosen files
  # @param "Rename Button" click
  observeEvent(input$rename, {
    global_positions <<- which(file_ids %in% input$select) # keeping the positions in a global variable to access after the rename
    files_to_change<-c()
    for(i in 1:length(global_positions))
    {
      files_to_change[i]<-file_names[[i]]
      # session$sendCustomMessage("handler_rename", input$select)
    }
    session$sendCustomMessage("handler_rename", files_to_change)
  })
  
  # input$js_fileNames returns the new "renamed" file names from javascript
  observeEvent(input$js_fileNames,{
    for (i in 1:length(global_positions)){
      if(input$js_fileNames[i] != ""){
        if (file_names[global_positions[[i]][1]] != input$js_fileNames[[i]][1]){
          if(is.na(match(input$js_fileNames[i], file_names))){
            file_names[global_positions[i]] <<- input$js_fileNames[i]
          } else session$sendCustomMessage("handler_alert", paste("Duplicate name: ", input$js_fileNames[i], " . Name didn't change.", sep="")) 
        }
      } else session$sendCustomMessage("handler_alert", paste("Empty name found. Name didn't change.", sep="")) 
    }
    updatePrettyCheckboxGroup(session, inputId="select",
                              choiceNames = file_names,
                              choiceValues = file_ids,
                              selected = NULL)
    updatePrettyCheckboxGroup(session, inputId="select",
                              selected = file_ids)
    updatePrettyCheckboxGroup(session, inputId = 'tbl_select', choiceValues = file_ids, choiceNames = file_names, selected = file_ids)
  })
  
  
  
  #----Remove selected files dialog----####
  observeEvent(input$remove, {
    req(input$select)
    confirmSweetAlert(
      session = session,
      inputId = 'confirm',
      type = 'warning',
      title = 'Are you sure you want to delete this/these file(s)?',
      btn_labels = c('No', 'Yes'),
      btn_colors = c('#04B404', '#DD6B55') 
    )
  })
  
  
  #----Confirm to delete the file----####
  observeEvent(input$confirm, {
    if (isTRUE(input$confirm)) {
      file.remove(input$select, file_names, file_ids)
      updatePrettyCheckboxGroup(session, "select",
                                choiceNames = file_names,
                                choiceValues = file_ids,
                                selected = file_ids) 
      updatePrettyCheckboxGroup(session, inputId = 'tbl_select', choiceValues = file_ids, choiceNames = file_names, selected = file_ids)
    }
    if(length(file_names)==0)
    {
      print("File list is empty.")
      
    }
  }, 
  ignoreNULL = TRUE
  )
  
  
  
  #----Run annotation with EXTRACT----####
  observe({
    lapply(input$select, function(id){
      observeEvent(input[[sprintf('annotationbtn%s', id)]], {
        if (!is.null(input[[sprintf('typepicker%s', id)]])) {
          shinyjs::show(sprintf('info%s', id))
          dbs=input[[sprintf('typepicker%s', id)]]
          
          #code for the new organism input
          inp_org=input[[sprintf("orgpicker%s", id)]]
          if(inp_org!="")
          {
            org <- organisms[organisms$print_name==inp_org,]$Taxonomy_ID
          }
          else
          {
            org=""
          }
          var <- array(c(org, dbs))
          js$table(var)
          js$annotate(var)
          shinyjs::show(sprintf("tagging_legend%s", id))
          
          
          output[[sprintf("annpar-%s", id)]] <- renderUI({
            div(
              hr(),
              h5(strong("Search Parameters:")),
              p(strong("Search Organism: "), paste(org, collapse=", "), " | ", strong("Sources: "), paste(dbs, collapse=", ")))
          })
          output[[sprintf("annpar-%s-ent", id)]] <- renderUI({
            div(
              hr(),
              h5(strong("Search Parameters:")),
              p(strong("Search Organism: "), paste(org, collapse=", "), " | ", strong("Sources: "), paste(dbs, collapse=", ")))
          })
        }
        else {
          sendSweetAlert(
            session = session,
            type = 'warning',
            title = 'Select entity type(s)'
          )
        }
        if (input[[sprintf('annotationbtn%s', id)]] >= 2 & !is.null(input[[sprintf('typepicker%s', id)]])) {
          shinyjs::show(sprintf('infonew%s', id))
          shinyjs::show(sprintf('infonewtab%s', id))
          shinyjs::hide(sprintf('info%s', id))
        }
      })
    })
  })
  
  
  
  
  #----Reset Annotation form ---#### 
  observe({
    lapply(input$select, function(id){
      observeEvent(input[[sprintf('annotreset%s', id)]], {
        updatePickerInput(session, sprintf('typepicker%s', id), selected= filterchoices )
        updatePickerInput(session, sprintf('orgpicker%s', id), selected= "Homo sapiens (Human) [NCBI Tax. ID: 9606]" )
        
        index <- which(file_ids==id)
        fpath <- file_paths[[index]]
        
        runjs(sprintf("document.getElementById('document-%s').src='%s'", id, fpath))
        shinyjs::hide(sprintf('infonew%s', id))
        shinyjs::hide(sprintf('infonewtab%s', id))
        shinyjs::hide(sprintf('info%s', id))
        shinyjs::hide(sprintf("tagging_legend%s", id))
        
      })
    })
  })
  
  
  
  #----Rendering of entities datatables----####
  observeEvent (input$entities, {
    variable <- csv.entities(input$entities)
    data <- variable[[2]]
    data2 <- variable[[3]]
    if(!is.null(variable)) {
      #req_tables[[ toString(variable[[1]]) ]] <- data
      req_tables[[ toString(variable[[1]]) ]] <- data2
      react_filter <- eventReactive(input[[sprintf('filter%s', variable[[1]])]], {
        return(data[data$Type %in% input[[sprintf('filter%s', variable[[1]])]],])
      })
      react_df <- eventReactive(input[[sprintf('tblchoose%s', variable[[1]])]], {
        return(data2[data2$Type %in% input[[sprintf('tblchoose%s', variable[[1]])]],])
      })
      if(!is.null(variable)) {
        output[[sprintf('tablentities%s', variable[[1]])]] <- DT::renderDataTable({
          datatable(react_filter(), rownames = F, escape = F, selection = 'none', options = list(paging=F, scrollY="400px", scroller=T))
        })
        output[[sprintf('tblentities%s', variable[[1]])]] <- DT::renderDataTable({
          datatable(react_df(), rownames = F, escape = F, selection = list(mode = "multiple", target = 'row'),  options = list( paging=F, scrollY="300px", scroller=T,  columnDefs = list(list(visible=F, targets=c(3,4))) ))
        })
        dt_proxy <- DT::dataTableProxy(sprintf('tblentities%s', variable[[1]]))
        
        #---- Select / Deselect all rows---#
        observeEvent(input[[sprintf('tbl_sel%s', variable[[1]])]], {
          if (isTRUE(input[[sprintf('tbl_sel%s', variable[[1]])]])) {
            DT::selectRows(dt_proxy, input[[sprintf('%s_rows_all', sprintf('tblentities%s', variable[[1]]))]])
          } 
          else {
            DT::selectRows(dt_proxy, NULL)
          }
        })
      }
      else {
        lapply(input$select, function(id) {
          sendSweetAlert(
            session = session,
            title = sprintf('No biological terms were found'),
          )
        })
      }
    }
    else {
      lapply(input$select, function(id) {
        sendSweetAlert(
          session = session,
          title = sprintf('No biological terms were found'),
        )
      })
    }
  })
  
  
  #----Download entities table----####
  observe(
    lapply(input$select, function(id) {
      output[[sprintf('downloadData%s', id)]] <- downloadHandler(
        filename = function() {
          paste('Entities_', id, '.csv', sep='')
        },
        content = function(file) {
          tbl_download <- eventReactive(input[[sprintf('filter%s', id)]], {
            return(req_tables[[ toString(id) ]][req_tables[[ toString(id) ]]$Type %in% input[[sprintf('filter%s', id)]],])
          })
          output_d <- tbl_download()
          write.csv(output_d, file)
        }
      )
    })
  ) 
  
  #----Show table in combined dataset tab-----####
  observe(
    lapply(input[["tbl_select"]], function(id) {
      observeEvent(input[[sprintf('select%s', id)]], {
        data2 <- req_tables[[ toString(id) ]]
        react_df <- eventReactive(input[[sprintf('tblchoose%s', id)]], {
          return(data2[data2$Type %in% input[[sprintf('tblchoose%s', id)]],])
        })
        on.selection(input[[sprintf('%s_rows_selected', sprintf('tblentities%s', id))]], react_df(), selected_values, all_sel_ids)
        choices_all <- all_sel_ids$dt
        shinyjs::show(sprintf('sel_info%s', id))
        shinyjs::show(sprintf('dataset_info', id))
        shinyjs::hide(sprintf('dataset_null', id))
        shinyjs::show("collect_FE")
        shinyjs::show("collect_PMID")
        shinyjs::show("collect_Pfam")
        shinyjs::show("collect_STRING")
        shinyjs::show("collect_STITCH")
        shinyjs::show("reset_dataset")
        updateTabsetPanel(session, "dataset_creator", "Dataset")
        
        
        react_df_collected <- eventReactive(input$tblchoose, {
          return(choices_all[choices_all$Type %in% input$tblchoose,])
        })
        
        
        output$collected_dataset_table <- DT::renderDataTable({
          datatable(react_df_collected(), extensions = c("Buttons") ,rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", dom="Bfrti", scroller=T, buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
        }, server = F)
      })
    })
  )
  
  #----Show table in FE gProfiler tab----####
  observeEvent(input$collect_FE, {
    all_sel_ids_FE<<-all_sel_ids
    if(nrow(all_sel_ids_FE$dt)>0)
    {
      choices_all_FE <- all_sel_ids_FE$dt[all_sel_ids_FE$dt$Type=="Protein",]
      shinyjs::hide('nodata_FE_info')
      shinyjs::hide(sprintf('dataset_info', id))
      shinyjs::hide(sprintf('dataset_null', id))
      shinyjs::show(sprintf('analyzeinfo_FE', id))
      shinyjs::show('analyze')
      shinyjs::show('delete_all')
      
      output$sel_analysis <- DT::renderDataTable({
        datatable(choices_all_FE, extensions = c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", dom="Bfrti", scroller=T, buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
      }, server=F)
    }
    else {
      sendSweetAlert(
        session = session,
        title = sprintf('No terms detected in dataset.'),
      )
    }
  })
  
  #----Show table in FE aGOtool tab----####
  observeEvent(input$collect_Pfam, {
    all_sel_ids_Pfam<<-all_sel_ids
    if(nrow(all_sel_ids_Pfam$dt)>0)
    {
      choices_all_Pfam <- all_sel_ids_Pfam$dt[all_sel_ids_Pfam$dt$Type=="Protein",]
      shinyjs::hide('nodata_Pfam_info')
      shinyjs::hide(sprintf('dataset_info', id))
      shinyjs::hide(sprintf('dataset_null', id))
      shinyjs::show(sprintf('analyzeinfo_Pfam', id))
      shinyjs::show("dataset_form_Pfam")
      shinyjs::show('analyze_Pfam')
      shinyjs::show('delete_all_Pfam')
      
      
      output$sel_analysis_Pfam <- DT::renderDataTable({
        datatable(choices_all_Pfam, extensions = c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", dom="Bfrti", scroller=T, buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
      }, server=F)
    }
    else {
      sendSweetAlert(
        session = session,
        title = sprintf('No terms detected in dataset.'),
      )
    }
  })
  
  
  #----Show table in literature search  tab----####
  observeEvent(input$collect_PMID, {
    all_sel_ids_PMID<<-all_sel_ids
    if(nrow(all_sel_ids_PMID$dt)>0)
    {
      choices_all_PMID <- all_sel_ids_PMID$dt[all_sel_ids_PMID$dt$Type=="Protein",]
      shinyjs::hide('nodata_PMID_info')
      shinyjs::hide(sprintf('dataset_info', id))
      shinyjs::hide(sprintf('dataset_null', id))
      shinyjs::show(sprintf('analyzeinfo_PMID', id))
      shinyjs::show("dataset_form_PMID")
      shinyjs::show('analyze_PMID')
      shinyjs::show('delete_all_PMID')
      
      
      output$sel_analysis_PMID <- DT::renderDataTable({
        datatable(choices_all_PMID, extensions = c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", dom="Bfrti", scroller=T, buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
      }, server=F)
    }
    else {
      sendSweetAlert(
        session = session,
        title = sprintf('No terms detected in dataset.'),
      )
    }
  })
  
  
  
  
  #----Show table in STRING Network tab----####
  observeEvent(input$collect_STRING, {
    all_sel_ids_network_STRING<<-all_sel_ids
    if(nrow(all_sel_ids_network_STRING$dt)>0)
    {
      choices_all_STRING <- all_sel_ids_network_STRING$dt[all_sel_ids_network_STRING$dt$Type=="Protein",]
      shinyjs::hide('nodata_STRING_info')
      shinyjs::show('dataset_form_STRING')
      
      shinyjs::hide(sprintf('dataset_info', id))
      shinyjs::hide(sprintf('dataset_null', id))
      shinyjs::show(sprintf('analyzeinfo_network', id))
      shinyjs::show('network_string')
      shinyjs::show('delete_all_network_STRING')
      
      
      output$sel_analysis_network_STRING <- DT::renderDataTable({
        datatable(choices_all_STRING, extensions=c("Buttons"),rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, dom=" Brfti",scrollY="400px", scroller=T, buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
      }, server=F)
    }
    else
    {
      sendSweetAlert(
        session = session,
        title = sprintf('No terms detected in dataset.'),
      )
    }
  })
  
  
  
  #----Show table in STITCH Network tab----####
  observeEvent(input$collect_STITCH, {
    all_sel_ids_network_STITCH<<-all_sel_ids
    
    if(nrow(all_sel_ids_network_STITCH$dt)>0)
    {
      choices_all_STITCH <- all_sel_ids_network_STITCH$dt
      
      shinyjs::hide('nodata_STITCH_info')
      shinyjs::show('dataset_form_STITCH')
      
      shinyjs::hide(sprintf('dataset_info', id))
      shinyjs::hide(sprintf('dataset_null', id))
      shinyjs::show(sprintf('analyzeinfo_network_STITCH', id))
      shinyjs::show('network_stitch')
      shinyjs::show('delete_all_network_STITCH')
      
      
      react_df_STITCH <- eventReactive(input$tblchoose_STITCH, {
        return(choices_all_STITCH[choices_all_STITCH$Type %in% input$tblchoose_STITCH,])
      })
      output$sel_analysis_network_STITCH <- DT::renderDataTable({
        datatable(react_df_STITCH(), extensions=c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
      }, server=F)
    }
    else {
      sendSweetAlert(
        session = session,
        title = sprintf('No terms detected in dataset.'),
      )
    }
  })
  
  
  
  #----Delete rows in combined Dataset tab----####
  observeEvent(input$collected_dataset_table_rows_selected, {
    req(input$collected_dataset_table_rows_selected)
    all_sel_ids$dt <- data.frame(
      all_sel_ids$dt[-input$collected_dataset_table_rows_selected, ]
    )
    output$collected_dataset_table <- DT::renderDataTable({
      datatable(all_sel_ids$dt, extensions=c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
    }, server=F)
  })
  
  #----Delete rows in FE gProfiler tab----####
  observeEvent(input$sel_analysis_rows_selected, {
    req(input$sel_analysis_rows_selected)
    all_sel_ids_FE$dt <- data.frame(
      all_sel_ids_FE$dt[-input$sel_analysis_rows_selected, ]
    )
    output$sel_analysis <- DT::renderDataTable({
      datatable(all_sel_ids_FE$dt, extensions=c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
    }, server=F)
  })
  
  #----Delete rows in literature search tab----####
  observeEvent(input$sel_analysis_PMID_rows_selected, {
    req(input$sel_analysis_PMID_rows_selected)
    all_sel_ids_PMID$dt <- data.frame(
      all_sel_ids_PMID$dt[-input$sel_analysis_PMID_rows_selected, ]
    )
    output$sel_analysis_PMID <- DT::renderDataTable({
      datatable(all_sel_ids_PMID$dt, rownames = F, extensions=c("Buttons"), colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
    }, server=F)
  })
  
  #----Delete rows in FE aGOtool tab----####
  observeEvent(input$sel_analysis_Pfam_rows_selected, {
    req(input$sel_analysis_Pfam_rows_selected)
    all_sel_ids_Pfam$dt <- data.frame(
      all_sel_ids_Pfam$dt[-input$sel_analysis_Pfam_rows_selected, ]
    )
    output$sel_analysis_Pfam <- DT::renderDataTable({
      datatable(all_sel_ids_Pfam$dt, rownames = F, extensions=c("Buttons"), colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
    }, server=F)
  })
  
  #----Delete rows in STRING Network tab----####
  observeEvent(input$sel_analysis_network_STRING_rows_selected, {
    req(input$sel_analysis_network_STRING_rows_selected)
    all_sel_ids_network_STRING$dt <- data.frame(
      all_sel_ids_network_STRING$dt[-input$sel_analysis_network_STRING_rows_selected, ]
    )
    output$sel_analysis_network_STRING <- DT::renderDataTable({
      datatable(all_sel_ids_network_STRING$dt, extensions=c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
    }, server=F)
  })
  
  #----Delete rows in STITCH Network tab----####
  observeEvent(input$sel_analysis_network_STITCH_rows_selected, {
    req(input$sel_analysis_network_STITCH_rows_selected)
    all_sel_ids_network_STITCH$dt <- data.frame(
      all_sel_ids_network_STITCH$dt[-input$sel_analysis_network_STITCH_rows_selected, ]
    )
    output$sel_analysis_network_STITCH <- DT::renderDataTable({
      datatable(all_sel_ids_network_STITCH$dt, extensions=c("Buttons"), rownames = F, colnames = c("Identifier", "Type", "Name", "Document", ""), selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T, dom="Brfti", buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download Dataset"))))
    }, server=F)
  })
  
  
  #----Delete all in combined_dataset tab----####
  observeEvent(input$reset_dataset, {
    shinyjs::hide('analyzeinfo_FE')
    shinyjs::hide('analyzeinfo_PMID')
    shinyjs::hide('analyzeinfo_Pfam')
    shinyjs::hide('analyzeinfo_network')
    shinyjs::hide('analyzeinfo_network_STITCH')
    shinyjs::show('dataset_null')
    all_sel_ids$dt <- data.frame()
    output$collected_dataset_table <- DT::renderDataTable({
      datatable(all_sel_ids$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })  
  
  #----Delete all in FE gProfiler tab----####
  observeEvent(input$delete_all, {
    all_sel_ids_FE$dt <- data.frame()
    output$sel_analysis <- DT::renderDataTable({
      datatable(all_sel_ids_FE$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })
  
  #----Delete all in literature search tab----####
  observeEvent(input$delete_all_PMID, {
    all_sel_ids_PMID$dt <- data.frame()
    output$sel_analysis_PMID <- DT::renderDataTable({
      datatable(all_sel_ids_PMID$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })  
  
  #----Delete all in FE aGOtool tab----####
  observeEvent(input$delete_all_Pfam, {
    all_sel_ids_Pfam$dt <- data.frame()
    output$sel_analysis_Pfam <- DT::renderDataTable({
      datatable(all_sel_ids_Pfam$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })  
  
  
  #----Delete all in STRING Network tab----####
  observeEvent(input$delete_all_network_STRING, {
    all_sel_ids_network_STRING$dt <- data.frame()
    output$sel_analysis_network_STRING <- DT::renderDataTable({
      datatable(all_sel_ids_network_STRING$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })
  
  #----Delete all in STITCH Network tab----####
  observeEvent(input$delete_all_network_STITCH, {
    all_sel_ids_network_STITCH$dt <- data.frame()
    output$sel_analysis_network_STITCH <- DT::renderDataTable({
      datatable(all_sel_ids_network_STITCH$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })  
  
  #----ZoomIframe content----####
  observe({
    lapply(input$select, function(id){
      observeEvent(input[[toString(id)]], {
        req(input$select)
        js$ZoomInIframe(input[[toString(id)]]);
      })
    })
  })
  
  
  
  
  
  #----------------------Tab 'Create Dataset'---------------------------####
  
  ##----Selection of entity tables----####
  output$table_select <- renderUI({
    
    prettyCheckboxGroup ( #checkboxes instead of selectinput
      inputId = 'tbl_select',
      label = 'Select annotated documents:',
      shape = 'curve',
      choiceValues = file_ids,
      choiceNames = file_names,
      selected = file_ids
    )
  })
  
  
  #----Tabset panel of entity tables----####
  observeEvent(input$tbl_select, {
    shinyjs::hide("nodata_create_dataset")
    output$tableview <- renderUI({
      mytabs <- lapply(input$tbl_select, function(id) {
        index <- which(file_ids==id)
        name <- file_names[[index]]
        tabPanel(title = strong(span((glue('{name}')), style='color:rgb(31, 191, 164)')),
                 id = sprintf('tabset%s', id), 
                 style = 'width:100%;',
                 div(id = sprintf('selinfo%s', id), p('Select one or more', strong('entities'), 'by clicking the row(s) in the Entities table below. Check the ', 
                                                      strong("Select All"), ' box to select all entities.  Click the ', strong("Add to Dataset"),' button to append your selection to the ',strong("Dataset"),".",
                                                      style = 'margin-left: 8px;'), style="background-color:#e7f3fe;font-size:18px"),
                 div(id = sprintf('sel_info%s', id), p('Check your selected terms in the ', strong("Dataset"), "panel.", style = 'margin-left: 8px;'), style="background-color:#e7f3fe;font-size:18px"),                 
                 boxPlus(width = 70, closable = F,  solidHeader = T,
                         pickerInput(
                           inputId = sprintf('tblchoose%s', id),
                           label = 'Filter by Type:',
                           choices = specifichoices,
                           selected = specifichoices,
                           multiple = T,
                           options = list(
                             `actions-box` = T,
                             `deselect-all-text` = 'Deselect all',
                             `select-all-text` = 'Select all',
                             `none-selected-text` = 'No Type selected'
                           )
                         ),
                         awesomeCheckbox(inputId = sprintf('tbl_sel%s', id), label = "Select / Deselect all"),
                         DT::dataTableOutput(sprintf('tblentities%s', id)),
                         fluidRow(
                           column(3,offset=10, actionBttn(inputId = sprintf('select%s', id), label = 'Add to Dataset', style ="material-flat", color="primary", size = 'sm', icon = icon('plus')))
                         )
                         
                         
                         
                         
                 )
        )
      })
      do.call(tabsetPanel, mytabs)
    })
  }) 
  
  
  
  #------------------ANALYSIS TOOLS----------------------####  
  
  #----FE with gProfiler----####  
  observeEvent(input$analyze, {
    showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
    
    #a quick POST request to see if the gProfiler service is available
    gprof_check <- POST(get_base_url(), timeout(connect_timeout))
    tryCatch(
      expr={
        gprof_check <- POST(get_base_url(), timeout(connect_timeout))
        
      },
      error = function(err) {
        cat("Some connection error, probably timeout\n", file=stderr())
        cat(sprintf("%s\n", err), file=stderr())
      },
      finally = {
        if(!exists("gprof_check"))
        {
          gprof_check <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
          gprof_check$status_code=404             
        }
      }
    )
    cat(paste("gprof_check\n", gprof_check, sep=" ", collapse=" "), file=stderr())
    if(gprof_check$status_code ==200)
    {
      if(input$organisms !="")
      {
        updateTabsetPanel(session,'all_identifiers_FE', 'Results')
        req(input$organisms)
        req(input$sources)
        req(input$correction_method)
        req(input$pvalue)
        shinyjs::show('result_info')
        #org = org_map[[input$organisms]] #organism
        
        org = organisms[organisms$print_name==input$organisms,]$gprofiler_ID
        
        srcs = unlist(input$sources) #db sources
        pvalue = input$pvalue #pvalue
        corr = input$correction_method #correction type
        id_output_type = unlist(input$FE_id_types) # type of gene IDs for the output
        
        identifiers <- all_sel_ids_FE$dt$Identifier #initial input identifiers
        ids_init <-character(0)
        for(i in 1:length(identifiers)) #remove CIDs, keep only proteins/genes
        {
          if(!is.na(identifiers[i]) & substring(identifiers[i],0,4) != 'CIDs')
          {
            ids_init <- append(ids_init, identifiers[i])
          }
        }
        #getting all sources in a vector
        dbs <- c()
        for (i in srcs) {
          dbs <- c(dbs, db_map[[i]])
        }
        #checking if ids are found, if not, nothing runs
        if (length(ids_init) != 0) {
          if (id_output_type=="ENSP")
          {
            gost_query <- ids_init
          }
          else
          {
            go_conv <-gconvert(query=ids_init, organism = org, target=id_output_type, mthreshold = Inf, filter_na = TRUE)
            gost_query <- go_conv$target
          }
          
          #
          
          mixed_gost <- gost(
            query = gost_query,
            organism = org,
            user_threshold = pvalue,
            correction_method = corr,
            sources = dbs,
            evcodes = T,
            significant = T
          )
          print(get_base_url())
          
          #box with input parameters used, this will appear on the top of the results panels
          output$FE_parameters <- renderUI({
            
            p(strong("Organism: "), org, " | ", strong("Sources: "), paste(dbs, collapse=", "), " | ", strong("Significance Threshold type:"), corr, " | ", strong("P-value cut-off: "), pvalue)
          })
          
          if (!is.null(mixed_gost)) {
            
            # Results table - initial data frame manipulation
            query_results <- mixed_gost$result
            query_results <- query_results[,-c(1:2)] #delete the first 2 columns (not important)
            query_results <- query_results[,-c(12:13)] #delete also the following, since we don't want them
            query_results <- query_results[,-c(10:11)]
            query_results <- query_results[,-c(5:6)]
            query_results$intersection <- gsub(",", ", ", query_results$intersection) #add space after commas, to help wrap text easier
            #renaming columns
            names(query_results)[1] <- 'P-value'
            names(query_results)[2] <- 'Term size'
            names(query_results)[3] <- 'Query size'
            names(query_results)[4] <- 'No. of Positive Hits'
            names(query_results)[5] <- 'Term ID'
            names(query_results)[6] <- 'Source'
            names(query_results)[7] <- 'Term Name'
            names(query_results)[8] <- 'Positive Hits'
            
            log_pval=c()
            enr_score=c()
            for (i in 1:nrow(query_results))
            {
              log_pval[i]<- format((-log10(as.numeric(as.character(format(query_results[["P-value"]][i], scientific = F))))),format="e", digit=2)
              enr_score[i] <-enrich_score(query_results[["No. of Positive Hits"]][i], query_results[["Term size"]][i])
            }
            query_results$log_pval=as.numeric(log_pval)
            query_results$enr_score=as.numeric(enr_score)
            names(query_results)[9]<- '-log10(P-value)'
            names(query_results)[10] <- 'Enrichment Score'
            query_results["P-value"] <- format(query_results["P-value"], scientific = T, digits = 3) #formatting p-value in scientific notation
            
            
            #adding hyperlinks to term IDs
            query_links <-list()
            entrez_genes<-c()
            for (i in 1:nrow(query_results))
            {
              
              #Create hyperlinks
              source <- query_results$Source[i]
              term_id <- query_results$`Term ID`[i]
              id_split<- strsplit(term_id, ":")
              id_number<-id_split[[1]][[length(id_split[[1]])]]
              
              if(source %in% names(FE_hyperlinks))
              {
                url_base = FE_hyperlinks[[source]]
                if(source =="KEGG")
                {
                  prefix=organisms[organisms$print_name==input$organisms,]$KEGG
                  ref_url <- sprintf("%s%s%s", url_base, prefix, id_number)
                  #convert the ENSEMBL IDs to gene names
                  ensids<- strsplit(query_results$`Positive Hits`[i], ", ")
                  if (id_output_type=="ENTREZGENE")
                  {
                    genes = ensids
                  }
                  else
                  {
                    #if not entrezgenes, convert them to entrezgenes
                    entrez <- gconvert(ensids[[1]], organism = org, target="ENTREZGENE", mthreshold = Inf, filter_na = TRUE)
                    genes<-entrez$target 
                  }
                  entrez_url_elem <- paste(unlist(genes), sep = '%20orange+', collapse = '%20orange+')
                  
                  ref_url <- sprintf("%s+%s%%20orange", ref_url, entrez_url_elem)
                }
                else
                {
                  ref_url <- sprintf("%s%s", url_base, id_number)
                }
                
              }
              else
              {
                ref_url<-""
              }
              query_links[[term_id]] <- ref_url
              if(ref_url !="")
              {
                query_results$`Term ID`[i] <- sprintf("<a href='%s' target='_blank'>%s</a>", ref_url, term_id)
              }
              
            }
            
            #Reordering columns for output: 1. Source, 2. ID, 3. Name, 4. P-value, 5. Term Size, 6. Query Size, 7. Intersection size, 8. Positive Hits, 9. -log10(pval) 10. enrichment score
            gost_output_table <- query_results[,c(6, 5, 7, 1, 2, 3, 4, 8,9,10)]
            
            #initialize vector of categories with sources
            gost_results_tables <- c("All")
            #filling it with the user-selected sources
            for (i in 1:length(dbs))
            {
              gost_results_tables<-append(gost_results_tables,dbs[i])
            }
            
            
            #FE gProfiler: tables output-####
            
            output[["FE_table_All"]] <- create_FE_table(gost_output_table)
            
            if ("GO:BP" %in% dbs) { output[["FE_table_BP"]] <- create_FE_table(gost_output_table[grepl("^GO:BP$", gost_output_table$Source), ])      } 
            if ("GO:MF" %in% dbs) { output[["FE_table_MF"]] <- create_FE_table(gost_output_table[grepl("^GO:MF$", gost_output_table$Source), ])      }
            if ("GO:CC" %in% dbs) { output[["FE_table_CC"]] <- create_FE_table(gost_output_table[grepl("^GO:CC$", gost_output_table$Source), ])      }
            if ("KEGG" %in% dbs)  { output[["FE_table_KEGG"]] <- create_FE_table(gost_output_table[grepl("^KEGG$", gost_output_table$Source), ])     }
            if ("REAC" %in% dbs)  { output[["FE_table_REAC"]] <- create_FE_table(gost_output_table[grepl("^REAC$", gost_output_table$Source), ])     }
            if ("WP" %in% dbs)    { output[["FE_table_WP"]] <- create_FE_table(gost_output_table[grepl("^WP$", gost_output_table$Source), ])         }
            if ("TF" %in% dbs)    { output[["FE_table_TF"]] <- create_FE_table(gost_output_table[grepl("^TF$", gost_output_table$Source), ])         }
            if ("MIRNA" %in% dbs) { output[["FE_table_MIRNA"]] <- create_FE_table(gost_output_table[grepl("^MIRNA$", gost_output_table$Source), ])   }
            if ("HPA" %in% dbs)   { output[["FE_table_HPA"]] <- create_FE_table(gost_output_table[grepl("^HPA$", gost_output_table$Source), ])       }
            if ("HP" %in% dbs)    { output[["FE_table_HP"]] <- create_FE_table(gost_output_table[grepl("^HP$", gost_output_table$Source), ])         }
            if ("HPA" %in% dbs)   { output[["FE_table_CORUM"]] <- create_FE_table(gost_output_table[grepl("^CORUM$", gost_output_table$Source), ])   }
            
            output$FE_results_table <- renderUI({
              withProgress(message = 'Rendering Enrichment Table',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
              tabBox(
                tabPanel(id="FE_all", "All", DT::dataTableOutput('FE_table_All')),
                tabPanel(id="FE_BP", "GO:BP", DT::dataTableOutput('FE_table_BP')),
                tabPanel(id="FE_MF", "GO:MF", DT::dataTableOutput('FE_table_MF')),
                tabPanel(id="FE_CC", "GO:CC", DT::dataTableOutput('FE_table_CC')),
                tabPanel(id="FE_KEGG", "KEGG", DT::dataTableOutput('FE_table_KEGG')),
                tabPanel(id="FE_REAC", "REACTOME", DT::dataTableOutput('FE_table_REAC')),
                tabPanel(id="FE_WP", "WikiPathways", DT::dataTableOutput('FE_table_WP')),
                tabPanel(id="FE_TF", "TransFac", DT::dataTableOutput('FE_table_TF')),
                tabPanel(id="FE_MIRNA", "miRTarBase", DT::dataTableOutput('FE_table_MIRNA')),
                tabPanel(id="FE_HPA", "HPA", DT::dataTableOutput('FE_table_HPA')),
                tabPanel(id="FE_CORUM", "CORUM", DT::dataTableOutput('FE_table_CORUM')),
                tabPanel(id="FE_HP", "HPO", DT::dataTableOutput('FE_table_HP'))
              )
              
            })
            
            
            
            #FE gProfiler: Manhattan plot-####
            manhattan_plot<-gostplot(mixed_gost, capped = T, interactive = T)
            output$FE_plot <- renderPlotly({
              withProgress(message = 'Rendering Manhattan Plot',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
              manhattan_plot
            })
            config(manhattan_plot, displayModeBar = T, displaylogo = F) 
            
            
            #FE gProfiler: bar plot preparation-####
            
            #rendering and updating menu options:
            shinyjs::show("barplot_controls")
            #updating options in barplot select source
            updatePickerInput(session, "barSelect", choices=dbs, selected = dbs[1])
            
            #assigning the gost_output_table in the global variable for the bar plot and manhattan onclick event
            barplot_table <<- data.frame()
            barplot_table <<-gost_output_table
            #rendering the barplot output layout loading slider (hack)
            output$barplot_loading <- renderUI({
              withProgress(message = 'Rendering Bar Plot',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
            })
            
            removeModal()
          }
          else {
            removeModal()
            shinyalert(
              title = 'No results found',
              text = 'Check the selected organism or select other Identifiers from Selection tab',
              size = 's', 
              closeOnEsc = T,
              type = 'error',
              showConfirmButton = T,
              confirmButtonText = "OK",
              confirmButtonCol = 'rgb(31, 191, 164)',
              animation = T
            )
          }
          
        }
        else {
          shinyalert(
            title = 'No Identifiers found',
            text = 'Select Identifiers from Selection tab',
            size = 's', 
            closeOnEsc = T,
            type = 'error',
            showConfirmButton = T,
            confirmButtonText = "OK",
            confirmButtonCol = 'rgb(31, 191, 164)',
            animation = T
          )
        }
      }
      else
      {
        shinyalert(
          title = 'No Organism selected',
          text = 'Please select an organism for analysis',
          size = 's', 
          closeOnEsc = T,
          type = 'error',
          showConfirmButton = T,
          confirmButtonText = "OK",
          confirmButtonCol = 'rgb(31, 191, 164)',
          animation = T
        ) 
      }
    }
    else
    {
      removeModal()
      shinyalert(
        title = 'Connection to g:Profiler could not be established',
        text = 'It seems the g:Profiler web service is not responding. Please try again later...',
        size = 's', 
        closeOnEsc = T,
        type = 'error',
        showConfirmButton = T,
        confirmButtonText = "OK",
        confirmButtonCol = 'rgb(31, 191, 164)',
        animation = T
      )
    }
  })
  
  #-- FE gProfiler: Manhattan clicking events-####
  observeEvent(event_data("plotly_click"),{
    currentTermID <- event_data("plotly_click")$key
    if(!identical(currentTermID, NULL)) {
      handleManhattanClick(output)
    }
  })
  observeEvent(event_data("plotly_selected"),{
    currentTermID <- event_data("plotly_selected")$key
    if(!identical(currentTermID, NULL)) {
      handleManhattanSelect(output)
    }
  })
  
  #---FE gProfiler: Barplot rendering events--####
  observeEvent(input$barSelect,{
    if(nrow(barplot_table)>0){
      handleBarPlot(input$barSelect, input$sliderBarplot, input$barplotMode, T, output, session)
    }
  })
  observeEvent(input$sliderBarplot,{
    if(nrow(barplot_table)>0){
      handleBarPlot(input$barSelect, input$sliderBarplot, input$barplotMode, F, output, session)
    }
  })
  observeEvent(input$barplotMode,{
    if(nrow(barplot_table)>0){
      handleBarPlot(input$barSelect, input$sliderBarplot, input$barplotMode, F, output, session)
    }
  })
  
  
  #----FE aGO tool analysis---####
  observeEvent(input$analyze_Pfam, {
    
    if(input$organisms_Pfam !="")
    {
      shinyjs::show("result_info_Pfam")
      showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
      updateTabsetPanel(session,'all_identifiers_Pfam', 'Results')
      req(input$organisms_Pfam)
      req(input$sources_Pfam)
      req(input$pvalue_Pfam)
      req(input$fdr_Pfam)
      org = organisms[organisms$print_name==input$organisms_Pfam,]$Taxonomy_ID
      org_gconvert = organisms[organisms$print_name==input$organisms_Pfam,]$gprofiler_ID
      srcs = unlist(input$sources_Pfam) #db sources
      id_output_type = unlist(input$Pfam_id_types)
      pvalue = input$pvalue_Pfam #pvalue
      fdr = input$fdr_Pfam #fdr
      
      
      identifiers <- all_sel_ids_Pfam$dt$Identifier
      ids_init<-c()
      for(i in 1:length(identifiers)) #remove CIDs, keep only proteins/genes
      {
        if(!is.na(identifiers[i]) & substring(identifiers[i],0,4) != 'CIDs')
        {
          ids_init <- append(ids_init, identifiers[i])
        }
      }
      
      if (length(ids_init) != 0) 
      {
        
        if(length(ids_init)<=1000)
        {
          ids_init <- ids_init
        }
        else
        {
          ids_init <- ids_init[1:1000]
        }
        
        #convert to ensgene so that the results can be mapped
        ensgenes<-gconvert(ids_init, organism = org_gconvert, target=id_output_type, mthreshold = Inf, filter_na = TRUE)
        
        input_identifiers<-c()
        for (i in 1:length(ids_init))
        {
          input_identifiers[i] <- sprintf("%s.%s", org, ids_init[i])
        }
        #create request in aGo
        #foreground ids (the ones that will be submitted)
        foreground <- paste(unlist(input_identifiers), sep = "%0d", collapse = "%0d")
        #the databases that will be searched are set as comma separate desired entity_types (e.g. Pfams, UniProt Keywords, Pfam and Interpro)
        limit_2_entity_type <- paste(unlist(srcs), sep = ";", collapse = ";")
        #representation level : over-, underrepresented or both
        o_or_u_or_both<-"both"
        #the api POST request
        post_args <- list(output_format = "tsv",
                          enrichment_method="genome",
                          taxid = sprintf("%s",org),
                          limit_2_entity_type = limit_2_entity_type,
                          foreground = foreground,
                          o_or_u_or_both = o_or_u_or_both,
                          p_value_cutoff = pvalue,
                          FDR_cutoff = fdr
        )
        
        
        tryCatch(
          expr={
            request <- POST("https://agotool.org/api_orig", body = post_args, encode = "json", timeout(connect_timeout))
            
          },
          error = function(err) {
            cat("Some connection error, probably timeout\n", file=stderr())
            cat(sprintf("%s\n", err), file=stderr())
          },
          finally = {
            if(!exists("request"))
            {
              request <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
              request$status_code=404             
            }
          }
        )
        
        if(request$status_code != 200)
        {
          removeModal()
          shinyalert(
            title = 'Connection to aGO could not be established',
            text = 'It seems the aGOtool web server is not responding. Please try again later...',
            size = 's', 
            closeOnEsc = T,
            type = 'error',
            showConfirmButton = T,
            confirmButtonText = "OK",
            confirmButtonCol = 'rgb(31, 191, 164)',
            animation = T
          )
        }
        else
        {
          response<-rawToChar(content(request,"raw"))
          response <- gsub("PFAM \\(Protein FAMilies\\)", "PFAM", response)
          response <- gsub("UniProt keywords", "UniProt", response)
          result_df <- read.csv(text = response, sep="\t", stringsAsFactors = FALSE)
          print(result_df)
          #render the parameters box
          db_names<-c()
          for (i in 1:length(srcs))
          {
            if (srcs[i]==-55) {db_names[i]<-"PFAM"}
            else if (srcs[i]==-54) {db_names[i]<-"INTERPRO"}
            else if (srcs[i]== -51) {db_names[i]<-"UniProt"}
            else {db_names[i] <- "Disease Ontology"}
          }
          output$Pfam_parameters <- renderUI({
            p(strong("Organism: "), org, " | ", strong("Sources: "), paste(db_names, collapse=", "), " | ", strong("P-value cut-off:"), pvalue, " | ", strong("FDR cut-off: "), fdr)
          })
          if(!is.null(result_df) & nrow(result_df)>0)
          {
            #ccolumns in the original result_df:
            #[1] "term"                "hierarchical_level"  "description"         "year"                "over_under"          "p_value"             "FDR"                 "effect_size"
            #[9] "ratio_in_foreground" "ratio_in_background" "foreground_count"    "foreground_n"        "background_count"    "background_n"        "foreground_ids"      "s_value"
            #[17] "rank"                "funcEnum"            "category"            "etype"
            results_table <- result_df[,c(19, 1, 3, 6, 7, 13,12,11,15)]
            
            names(results_table)[1] <- "Source"
            names(results_table)[2] <- "ID"
            names(results_table)[3] <- "Title"
            names(results_table)[4] <- "P-value"
            names(results_table)[5] <- "FDR"
            names(results_table)[6] <- "Term Size"
            names(results_table)[7] <- "Query size"
            names(results_table)[8] <- "No. of Positive Hits"
            names(results_table)[9] <- "Positive Hits"
            
            
            
            log_pval=c()
            log_fdr=c()
            enr_score=c()
            for (i in 1:nrow(results_table))
            {
              log_pval[i] <- format((-log10(as.numeric(as.character(format(results_table[["P-value"]][i], scientific = F))))),format="e", digit=2)
              log_fdr[i] <- format((-log10(as.numeric(as.character(format(results_table[["FDR"]][i], scientific = F))))),format="e", digit=2)
              enr_score[i]  <- round(( results_table[["No. of Positive Hits"]][i]/results_table[["Term Size"]][i]) * 100, 2)
              
              result_genes<-c()
              ids<- strsplit(gsub(sprintf("%s.",org),"", results_table[["Positive Hits"]][i]), ";")
              for (j in 1:length(ids[[1]]))
              {
                r<-ensgenes[grepl(ids[[1]][j], ensgenes$input),]
                result_genes[j]<-r$target
              }
              results_table[["Positive Hits"]][i]<- paste(result_genes, sep=";", collapse = ";")
              
              
            }
            results_table$log_pval=as.numeric(log_pval)
            results_table$log_fdr=as.numeric(log_fdr)
            results_table$enr_score=as.numeric(enr_score)
            names(results_table)[10] <- '-log10(P-value)'
            names(results_table)[11] <- '-log10(FDR)'
            names(results_table)[12] <- 'Enrichment Score'
            
            results_table[["Positive Hits"]] <- gsub(";", ", ", results_table[["Positive Hits"]]) #add space after commas, to help wrap text easier
            results_table[["FDR"]] <- format(as.numeric(unlist(results_table["FDR"])), scientific = T, digits = 3)
            results_table[["P-value"]] <- format(as.numeric(unlist(results_table["P-value"])), scientific = T, digits = 3)
            
            #add the hyperlinks
            for (i in 1:nrow(results_table))
            {
              if (results_table[["Source"]][i]=="UniProt")
              {
                url=sprintf("https://www.uniprot.org/keywords/%s", results_table[["ID"]][i])
              }
              else if(results_table[["Source"]][i]=="PFAM")
              {
                url=sprintf("http://pfam.xfam.org/family/%s", results_table[["ID"]][i])
              }
              else if(results_table[["Source"]][i]=="INTERPRO")
              {
                url=sprintf("https://www.ebi.ac.uk/interpro/entry/InterPro/%s/", results_table[["ID"]][i])
              }
              else
              {
                url=sprintf("https://diseases.jensenlab.org/Entity?order=textmining,knowledge,experiments&textmining=10&knowledge=10&experiments=10&type1=-26&type2=%s&id1=%s", org, results_table[["ID"]][i])
              }
              results_table[["ID"]][i] <- sprintf("<a href='%s' target='_blank'>%s</a>", url, results_table[["ID"]][i])
              
            }
            
            
            #FE aGO tool: tables output-####
            output[["Pfam_table_All"]] <- create_literature_table(results_table)
            if (-55 %in% srcs) { output[["Pfam_table_pfam"]] <- create_literature_table(results_table[grepl("PFAM", results_table$Source), ])      } 
            if (-54 %in% srcs) { output[["Pfam_table_interpro"]] <- create_literature_table(results_table[grepl("INTERPRO", results_table$Source), ])      }
            if (-51 %in% srcs) { output[["Pfam_table_uniprot"]] <- create_literature_table(results_table[grepl("UniProt", results_table$Source), ])      }
            if (-26 %in% srcs) { output[["Pfam_table_disease"]] <- create_literature_table(results_table[grepl("Disease Ontology", results_table$Source), ]) }
            
            output$Pfam_results_table <- renderUI({
              withProgress(message = 'Rendering Results Table',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
              tabBox(
                tabPanel(id="Pfam_all", "All", DT::dataTableOutput('Pfam_table_All')),
                tabPanel(id="Pfam_pfam", "PFAM", DT::dataTableOutput('Pfam_table_pfam')),
                tabPanel(id="Pfam_interpro", "INTERPRO", DT::dataTableOutput('Pfam_table_interpro')),
                tabPanel(id="Pfam_uniprot", "UniProt", DT::dataTableOutput('Pfam_table_uniprot')),
                tabPanel(id="Pfam_disease", "Disease Ontology", DT::dataTableOutput('Pfam_table_disease'))
              )
              
            })
            #-FE aGOtool: update barplot page-####
            #rendering and updating menu options:
            shinyjs::show("barplot_controls_Pfam")
            #updating options in barplot select source
            updatePickerInput(session, "barSelect_Pfam", choices=db_names, selected=db_names[1])
            
            #assigning the gost_output_table in the global variable for the bar plot
            barplot_table_Pfam <<- data.frame()
            barplot_table_Pfam <<-results_table
            #rendering the barplot output layout loading slider (hack)
            output$barplot_loading_Pfam <- renderUI({
              withProgress(message = 'Rendering Bar Plot',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
            })
            
            removeModal()
          }
          else
          {
            removeModal()
            shinyalert(
              title = 'No results found',
              text = 'Check the selected organism, or select other Identifiers from the Selection tab',
              size = 's', 
              closeOnEsc = T,
              type = 'error',
              showConfirmButton = T,
              confirmButtonText = "OK",
              confirmButtonCol = 'rgb(31, 191, 164)',
              animation = T
            )
          }
        }
      }
      else
      {
        shinyalert(
          title = 'No Identifiers found',
          text = 'Select Identifiers from Selection tab',
          size = 's', 
          closeOnEsc = T,
          type = 'error',
          showConfirmButton = T,
          confirmButtonText = "OK",
          confirmButtonCol = 'rgb(31, 191, 164)',
          animation = T
        )
      }
    }
    else
    {
      shinyalert(
        title = 'No Organism selected',
        text = 'Please select an organism for analysis',
        size = 's', 
        closeOnEsc = T,
        type = 'error',
        showConfirmButton = T,
        confirmButtonText = "OK",
        confirmButtonCol = 'rgb(31, 191, 164)',
        animation = T
      )      
    }
  })
  
  #---FE aGO tool: Barplot rendering events--####
  observeEvent(input$barSelect_Pfam,{
    if(nrow(barplot_table_Pfam)>0){
      handleBarPlot_Pfam(input$barSelect_Pfam, input$sliderBarplot_Pfam, input$barplotMode_Pfam, T, output, session)
    }
  })
  observeEvent(input$sliderBarplot_Pfam,{
    if(nrow(barplot_table_Pfam)>0){
      handleBarPlot_Pfam(input$barSelect_Pfam, input$sliderBarplot_Pfam, input$barplotMode_Pfam, F, output, session)
    }
  })
  observeEvent(input$barplotMode_Pfam,{
    if(nrow(barplot_table_Pfam)>0){
      handleBarPlot_Pfam(input$barSelect_Pfam, input$sliderBarplot_Pfam, input$barplotMode_Pfam, F, output, session)
    }
  })
  
  
  #----Literature Search Analysis---####
  observeEvent(input$analyze_PMID, {
    if(input$organisms_PMID !="")
    {
      shinyjs::show("result_info_PMID")
      showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
      updateTabsetPanel(session,'all_identifiers_PMID', 'Results')
      req(input$organisms_PMID)
      #req(input$sources_PMID)
      req(input$pvalue_PMID)
      req(input$fdr_PMID)
      id_output_type = unlist(input$PMID_id_types)
      org = organisms[organisms$print_name==input$organisms_PMID,]$Taxonomy_ID
      org_gconvert = organisms[organisms$print_name==input$organisms_PMID,]$gprofiler_ID
      #srcs = unlist(input$sources_PMID) #db sources
      
      pvalue = input$pvalue_PMID #pvalue
      fdr = input$fdr_PMID #fdr
      
      
      identifiers <- all_sel_ids_PMID$dt$Identifier
      ids_init<-c()
      for(i in 1:length(identifiers)) #remove CIDs, keep only proteins/genes
      {
        if(!is.na(identifiers[i]) & substring(identifiers[i],0,4) != 'CIDs')
        {
          ids_init <- append(ids_init, identifiers[i])
        }
      }
      
      if (length(ids_init) != 0) 
      {
        
        if(length(ids_init)<=1000)
        {
          ids_init <- ids_init
        }
        else
        {
          ids_init <- ids_init[1:1000]
        }
        
        #convert to ensgene so that the results can be mapped
        ensgenes<-gconvert(ids_init, organism = org_gconvert, target=id_output_type, mthreshold = Inf, filter_na = TRUE)
        
        input_identifiers<-c()
        for (i in 1:length(ids_init))
        {
          input_identifiers[i] <- sprintf("%s.%s", org, ids_init[i])
        }
        #create request in aGo
        #foreground ids (the ones that will be submitted)
        foreground <- paste(unlist(input_identifiers), sep = "%0d", collapse = "%0d")
        #the databases that will be searched are set as comma separate desired entity_types (e.g. PMIDs, UniProt Keywords, Pfam and Interpro)
        #representation level : over-, underrepresented or both
        o_or_u_or_both<-"both"
        #the api POST request
        post_args <- list(output_format = "tsv",
                          enrichment_method="genome",
                          taxid = sprintf("%s",org),
                          limit_2_entity_type = -56,
                          foreground = foreground,
                          o_or_u_or_both = o_or_u_or_both,
                          p_value_cutoff = pvalue,
                          FDR_cutoff = fdr
        )
        
        
        
        tryCatch(
          expr={
            request <- POST("https://agotool.org/api_orig", body = post_args, encode = "json", timeout(connect_timeout))
            
          },
          error = function(err) {
            cat("Some connection error, probably timeout\n", file=stderr())
            cat(sprintf("%s\n", err), file=stderr())
          },
          finally = {
            if(!exists("request"))
            {
              request <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
              request$status_code=404             
            }
          }
        )
        
        
        
        
        if(request$status_code != 200)
        {
          removeModal()
          shinyalert(
            title = 'Connection to aGO could not be established',
            text = 'It seems the aGOtool web server is not responding. Please try again later...',
            size = 's', 
            closeOnEsc = T,
            type = 'error',
            showConfirmButton = T,
            confirmButtonText = "OK",
            confirmButtonCol = 'rgb(31, 191, 164)',
            animation = T
          )
        }
        else
        {
          response<-rawToChar(content(request,"raw"))
          response<-gsub("PMID \\(PubMed IDentifier\\)", "PubMed", response)
          result_df <- read.csv(text = response, sep="\t", stringsAsFactors = FALSE)
          
          
          
          
          output$PMID_parameters <- renderUI({
            p(strong("Organism: "), org,  " | ", strong("P-value cut-off:"), pvalue, " | ", strong("FDR cut-off: "), fdr)
          })
          if(!is.null(result_df) & nrow(result_df)>0)
          {
            #ccolumns in the original result_df:
            #[1] "term"                "hierarchical_level"  "description"         "year"                "over_under"          "p_value"             "FDR"                 "effect_size"
            #[9] "ratio_in_foreground" "ratio_in_background" "foreground_count"    "foreground_n"        "background_count"    "background_n"        "foreground_ids"      "s_value"
            #[17] "rank"                "funcEnum"            "category"            "etype"
            results_table <- result_df[,c(19, 1, 3, 6, 7, 13,12,11,15)]
            
            names(results_table)[1] <- "Source"
            names(results_table)[2] <- "ID"
            names(results_table)[3] <- "Title"
            names(results_table)[4] <- "P-value"
            names(results_table)[5] <- "FDR"
            names(results_table)[6] <- "Term Size"
            names(results_table)[7] <- "Query size"
            names(results_table)[8] <- "No. of Positive Hits"
            names(results_table)[9] <- "Positive Hits"
            
            pmids_req<-gsub("PMID:","",paste(results_table$ID, sep="+", collapse="+"))
            
            #HTTP request to the NCBI entrez API to get information on the papers from PubMed
            tryCatch(
              expr={
                pubmed_request <- POST(sprintf("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id=%s", pmids_req))
              },
              error = function(err) {
                cat("Some connection error, probably timeout\n", file=stderr())
                cat(sprintf("%s\n", err), file=stderr())
              },
              finally = {
                if(!exists("request"))
                {
                  pubmed_request <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
                  pubmed_request$status_code=404             
                }
              }
            )
            
            if(pubmed_request$status_code==200)
            {
              pubmed_data<-fromJSON(rawToChar(pubmed_request$content))
              #print(pubmed_data)
              year<-c()
              for (i in 1:nrow(results_table))
              {
                #adding the year
                m<-str_match(results_table[["Title"]][i], "\\((\\d+)\\) (.*)")
                year[i]<-as.integer(m[2])
                plain_title<-m[3]
                print(m)
                
                #now proceeding to reformat the Title column
                pmid=gsub("PMID:","",results_table[["ID"]][i])
                authors<-paste(pubmed_data$result[[sprintf("%s",pmid)]]$authors$name, sep="; ", collapse="; ")
                if(pubmed_data$result[[sprintf("%s",pmid)]]$issue!="")
                {
                  journal<-sprintf("<i>%s</i> %s(%s), pp. %s", pubmed_data$result[[sprintf("%s",pmid)]]$source, pubmed_data$result[[sprintf("%s",pmid)]]$volume, pubmed_data$result[[sprintf("%s",pmid)]]$issue, pubmed_data$result[[sprintf("%s",pmid)]]$pages)
                }
                else
                {
                  journal<-sprintf("<i>%s</i> %s, pp. %s", pubmed_data$result[[sprintf("%s",pmid)]]$source, pubmed_data$result[[sprintf("%s",pmid)]]$volume, pubmed_data$result[[sprintf("%s",pmid)]]$pages)
                }
                results_table[["Title"]][i]<-sprintf("%s (%s) <b>%s</b> %s", authors, year[i], plain_title, journal)
                
              }
              #results_table$Year=year
              #print(year)
            }
            else
            {
              year<-c()
              for (i in 1:nrow(results_table))
              {
                #adding the year
                m<-str_match(results_table[["Title"]][i], "\\((\\d+)\\) .*")
                year[i]<-as.integer(m[2])
              }
            }
            
            
            log_pval=c()
            log_fdr=c()
            enr_score=c()
            for (i in 1:nrow(results_table))
            {
              log_pval[i] <- format((-log10(as.numeric(as.character(format(results_table[["P-value"]][i], scientific = F))))),format="e", digit=2)
              log_fdr[i] <- format((-log10(as.numeric(as.character(format(results_table[["FDR"]][i], scientific = F))))),format="e", digit=2)
              enr_score[i]  <- round(( results_table[["No. of Positive Hits"]][i]/results_table[["Term Size"]][i]) * 100, 2)
              
              result_genes<-c()
              ids<- strsplit(gsub(sprintf("%s.",org),"", results_table[["Positive Hits"]][i]), ";")
              for (j in 1:length(ids[[1]]))
              {
                r<-ensgenes[grepl(ids[[1]][j], ensgenes$input),]
                result_genes[j]<-r$target
              }
              results_table[["Positive Hits"]][i]<- paste(result_genes, sep=";", collapse = ";")
              
            }
            results_table$log_pval=as.numeric(log_pval)
            results_table$log_fdr=as.numeric(log_fdr)
            results_table$enr_score=as.numeric(enr_score)
            results_table$year=as.numeric(year)
            names(results_table)[10] <- '-log10(P-value)'
            names(results_table)[11] <- '-log10(FDR)'
            names(results_table)[12] <- 'Enrichment Score'
            names(results_table)[13] <- 'Publication Year'
            
            results_table[["Positive Hits"]] <- gsub(";", ", ", results_table[["Positive Hits"]]) #add space after commas, to help wrap text easier
            results_table[["FDR"]] <- format(as.numeric(unlist(results_table["FDR"])), scientific = T, digits = 3)
            results_table[["P-value"]] <- format(as.numeric(unlist(results_table["P-value"])), scientific = T, digits = 3)
            
            #add the hyperlinks
            for (i in 1:nrow(results_table))
            {
              if(results_table[["Source"]][i]=="PubMed")
              {
                id_split<- strsplit(results_table[["ID"]][i], ":")
                id_number<-id_split[[1]][[length(id_split[[1]])]]
                url=sprintf("https://pubmed.ncbi.nlm.nih.gov/%s/", id_number)
              }
              
              results_table[["ID"]][i] <- sprintf("<a href='%s' target='_blank'>%s</a>", url, results_table[["ID"]][i])
              
            }
            
            print(names(results_table))
            
            #Literature search: tables output-####
            output[["PMID_table_All"]] <- create_literature_table(results_table)
            
            output$PMID_results_table <- renderUI({
              withProgress(message = 'Rendering Results Table',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
              
              DT::dataTableOutput('PMID_table_All')
              
              
            })
            #-Literature search: updatebarplot page-####
            #rendering and updating menu options:
            shinyjs::show("barplot_controls_PMID")
            #updating options in barplot select source
            
            
            #assigning the gost_output_table in the global variable for the bar plot
            barplot_table_PMID <<- data.frame()
            barplot_table_PMID <<-results_table
            #rendering the barplot output layout loading slider (hack)
            output$barplot_loading_PMID <- renderUI({
              withProgress(message = 'Rendering Bar Plot',
                           detail = 'Please wait...', value = 0, {
                             for (i in 1:10) {
                               incProgress(1/10)
                               Sys.sleep(0.25)
                             }
                           })
            })
            handleBarPlot_PMID("PubMed", input$sliderBarplot_PMID, input$barplotMode_PMID, T, output, session)
            removeModal()
          }
          else
          {
            removeModal()
            shinyalert(
              title = 'No results found',
              text = 'Check the selected organism, or select other Identifiers from the Selection tab',
              size = 's', 
              closeOnEsc = T,
              type = 'error',
              showConfirmButton = T,
              confirmButtonText = "OK",
              confirmButtonCol = 'rgb(31, 191, 164)',
              animation = T
            )
          }
        }
      }
      else
      {
        shinyalert(
          title = 'No Identifiers found',
          text = 'Select Identifiers from Selection tab',
          size = 's', 
          closeOnEsc = T,
          type = 'error',
          showConfirmButton = T,
          confirmButtonText = "OK",
          confirmButtonCol = 'rgb(31, 191, 164)',
          animation = T
        )
      }
    }
    else
    {
      shinyalert(
        title = 'No Organism selected',
        text = 'Please select an organism for analysis',
        size = 's', 
        closeOnEsc = T,
        type = 'error',
        showConfirmButton = T,
        confirmButtonText = "OK",
        confirmButtonCol = 'rgb(31, 191, 164)',
        animation = T
      ) 
    }
  })
  
  #---Literature search Barplot rendering events--####
  
  observeEvent(input$sliderBarplot_PMID,{
    if(nrow(barplot_table_PMID)>0){
      handleBarPlot_PMID("PubMed", input$sliderBarplot_PMID, input$barplotMode_PMID, F, output, session)
    }
  })
  observeEvent(input$barplotMode_PMID,{
    if(nrow(barplot_table_PMID)>0){
      handleBarPlot_PMID("PubMed", input$sliderBarplot_PMID, input$barplotMode_PMID, F, output, session)
    }
  })
  
  
  #----Tab STRINGdb network----####
  observeEvent(input$network_string, {
    if(input$organisms_network!="")
    {
      
      
      identifiers <- all_sel_ids_network_STRING$dt$Identifier
      if(length(identifiers)>0)
      {
        updateTabsetPanel(session,'all_identifiers_string', 'Network Viewer')
        org = organisms[organisms$print_name==input$organisms_network,]$Taxonomy_ID
        showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
        shinyjs::show('result_info_STRING')
        ids_init <-character(0)
        for(i in 1:length(identifiers))
        {
          if(!is.na(identifiers[i]) & substring(identifiers[i],0,4) != 'CIDs')
          {
            ids_init <- append(ids_init, identifiers[i])
          }
        }
        
        
        if(length(ids_init)<=500)
        {
          ids_init <- ids_init
        }
        else
        {
          ids_init <- ids_init[1:500]
        }
        
        ids_init <- gsub("[[:space:]]", "", ids_init)
        ids_interactive <- paste(unlist(ids_init), sep = "','", collapse = "','")
        
        species_interactive <- org
        type_interactive <- input$type_string_network
        edges_interactive <- input$edges_string_network
        score_interactive <- input$score_string_network
        
        output$string_out <- renderUI ({
          withProgress(message = 'Preparing network for visualization',
                       detail = 'Please wait...', value = 0, {
                         for (i in 1:10) {
                           incProgress(1/10)
                           Sys.sleep(0.25)
                         }
                       })
          
          tags$div(class = 'string_db_network',
                   tags$script(sprintf("
        var proteins = ['%s']; 
        var species = ['%s'];
        var type = ['%s'];
        var edges = ['%s'];
        var score = ['%s'];
        getSTRING('https://string-db.org', {
        'species':species, 
        'identifiers':proteins,
        'network_type':type,
        'network_flavor':edges,
        'required_score':score});", ids_interactive, species_interactive, type_interactive, edges_interactive, score_interactive) 
                   ),
                   tags$div(id = 'stringEmbedded')
          )
        })
        
        ids_dnl_string <- paste(unlist(ids_init), sep = "%0d", collapse = "%0d")
        
        #A small API call to get the STRING URL:
        # 'get_link' returns a file (json, tsv or XML) containing the URL to the string website
        #we call it with a curl request and decode it
        
        tryCatch(
          expr={
            h_open <- new_handle(url="https://string-db.org/api/tsv-no-header/get_link", CONNECTTIMEOUT = connect_timeout)
            handle_setform(h_open,
                           identifiers=ids_dnl_string,
                           species=sprintf("%s",species_interactive),
                           network_type=type_interactive,
                           network_flavor=edges_interactive,
                           required_score=score_interactive,
                           caller_identity = "OnTheFly@bib.fleming"
            )
            h_open_curl <- curl_fetch_memory("https://string-db.org/api/tsv-no-header/get_link", h_open)          },
          error = function(err) {
            cat("Some connection error, probably timeout\n", file=stderr())
            cat(sprintf("%s\n", err), file=stderr())
          },
          finally = {
            if(!exists("h_open_curl"))
            {
              h_open_curl <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
              h_open_curl$status_code=404             
            }
          }
        )
        
        if(h_open_curl$status_code != 200)
        {
          removeModal()
          shinyalert(
            title = 'Connection to STRING could not be established',
            text = 'It seems the STRING web server is not responding. Please try again later...',
            size = 's', 
            closeOnEsc = T,
            type = 'error',
            showConfirmButton = T,
            confirmButtonText = "OK",
            confirmButtonCol = 'rgb(31, 191, 164)',
            animation = T
          )
        }
        else
        {
          string_link <- rawToChar(h_open_curl$content)
          string_link <- trimws(string_link)
          
          
          
          h_tsv <- new_handle(url="https://string-db.org/api/tsv/network", CONNECTTIMEOUT = connect_timeout)
          handle_setform(h_tsv,
                         identifiers=ids_dnl_string,
                         species=sprintf("%s",species_interactive),
                         network_type=type_interactive,
                         network_flavor=edges_interactive,
                         required_score=score_interactive,
                         caller_identity = "OnTheFly@bib.fleming"
          )
          h_tsv_curl <- curl_fetch_memory("https://string-db.org/api/tsv/network", h_tsv)
          string_tsv <- rawToChar(h_tsv_curl$content)
          
          
          svg_to_png_js_code="var dv = document.getElementById('stringEmbedded');
  var svg = dv.getElementsByTagName('svg')[0];
  var svgData = new XMLSerializer().serializeToString( svg );
  
  var canvas = document.createElement( 'canvas' );
  var ctx = canvas.getContext( '2d' );
  
  var img = document.createElement( 'img' );
  img.setAttribute( 'src', 'data:image/svg+xml;base64,' + btoa( svgData ) );
  
  img.onload = function() {
    var canvas = document.createElement('canvas');
    canvas.width = img.width;
    canvas.height = img.height;
    var context = canvas.getContext('2d');
    context.drawImage(img, 0, 0);
    
    var a = document.createElement('a');
    a.download = 'network.png';
    a.href = canvas.toDataURL('image/png');
    document.body.appendChild(a);
    a.click();
  }"
          
          
          
          
          if(type_interactive=="functional")
          {
            print_type="Full (functional & physical)"
          }
          else
          {
            print_type="Physical"
            
          }
          output$string_parameters_table <- renderUI({
            p(strong("Organism: "), species_interactive, " | ", strong("Network Type: "), print_type, " | ", strong("Meaning of network edges:"), edges_interactive, " | ", strong("Interaction score cut-off: "), as.numeric(score_interactive)/1000)
          })
          
          output$tsv_string <- renderUI({
            fluidRow(
              actionButton(inputId = 'string_link', label = 'Open in STRING', icon = icon('link'), style='md-flat', onclick = sprintf("window.open('%s', '_blank')", string_link)),
              downloadButton(outputId = 'dnl_tsv_string', label = 'Download Network', icon = icon('download'),  style='md-flat'),
              actionButton(inputId = 'dnl_png_string', label = 'Export Image', icon = icon('image'),  style='md-flat', onclick = svg_to_png_js_code)
            )
          })
          
          
          #download file dialog for saving a tsv text
          output$dnl_tsv_string <-downloadHandler(
            filename = "network.tsv",
            content = function(file) {
              write(string_tsv, file)
            }
          )
          
          
          output$string_legend <- create_network_legend("string", edges_interactive)
          
          removeModal()
          js$int_network()
        }
      }
      else
      {
        shinyalert(
          title = 'No Identifiers found',
          text = 'Select Identifiers from Selection tab',
          size = 's', 
          closeOnEsc = T,
          type = 'error',
          showConfirmButton = T,
          confirmButtonText = "OK",
          confirmButtonCol = 'rgb(31, 191, 164)',
          animation = T
        )
      }
    }
    else
    {
      shinyalert(
        title = 'No Organism selected',
        text = 'Please select an organism for analysis',
        size = 's', 
        closeOnEsc = T,
        type = 'error',
        showConfirmButton = T,
        confirmButtonText = "OK",
        confirmButtonCol = 'rgb(31, 191, 164)',
        animation = T
      ) 
    }
  })
  
  
  #----Tab STITCHdb network----####
  observeEvent(input$network_stitch, {
    if(input$organisms_stitch_network!="")
    {
      ids_init_stitch <- all_sel_ids_network_STITCH$dt$Identifier
      if(length(ids_init_stitch)>0)
      {
        showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
        shinyjs::show('result_info_STITCH')
        updateTabsetPanel(session,'all_identifiers_stitch', 'Network Viewer')
        
        org = organisms[organisms$print_name==input$organisms_stitch_network,]$Taxonomy_ID
        
        
        ids_init_stitch <- gsub("[[:space:]]", "", ids_init_stitch)
        
        species_stitch <- org
        type_stitch <- input$type_stitch_network
        edges_stitch <- input$edges_stitch_network
        score_stitch <- input$score_stitch_network
        
        if(length(ids_init_stitch)<=100)
        {
          ids_init_stitch <- ids_init_stitch
        }
        else
        {
          ids_init_stitch <- ids_init_stitch[1:100]
        }
        
        
        for(i in 1:length(ids_init_stitch))
        {
          if(!is.na(ids_init_stitch[i]))
          {
            if(substring(ids_init_stitch[i],0,4) == 'ENSP')
            {
              ids_init_stitch[i] <- sprintf("%s.%s", species_stitch, ids_init_stitch[i]) # STITCH wants protein IDs like this: txid.ID, e.g. 9606.ENSP00000296271
            }
            else
            {
              ids_init_stitch[i] <- gsub('CIDs', '-', ids_init_stitch[i]) # in chemicals, the 'CIDs' prefix needs to be substituted by '-'
            }
          }
        }
        ids_svg_stitch <- paste(unlist(ids_init_stitch), sep = "%0d", collapse = "%0d")
        
        
        #the SVG canvas is fetched through a curl request.  Standard jquery requests, like those used in the STRING API of STRING v11, DO NOT WORK (error in CORS policy)
        stitch_url <- sprintf("http://stitch.embl.de/api/svg/networkList?identifiers=%s&species=%s&network_type=%s&network_flavor=%s&required_score=%s", ids_svg_stitch, species_stitch, type_stitch, edges_stitch, score_stitch)
        
        
        tryCatch(
          expr={
            request <- POST(stitch_url, timeout(connect_timeout))
          },
          error = function(err) {
            cat("Some connection error, probably timeout\n", file=stderr())
            cat(sprintf("%s\n", err), file=stderr())
            request <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
            request$status_code=404
          },
          finally = {
            if(!exists("request"))
            {
              request <- list() #create a "dummy" response list and set its status code to 404, to indicate error in the check below
              request$status_code=404             
            }
          }
        )
        if(request$status_code != 200)
        {
          removeModal()
          shinyalert(
            title = 'Connection to STRING could not be established',
            text = 'It seems the STRING web server is not responding. Please try again later...',
            size = 's', 
            closeOnEsc = T,
            type = 'error',
            showConfirmButton = T,
            confirmButtonText = "OK",
            confirmButtonCol = 'rgb(31, 191, 164)',
            animation = T
          )
        }
        else
        {
          svg_html<-rawToChar(content(request,"raw"))
          svg_html<-gsub("svg_network_image", "svg_network_image_stitch", svg_html) # this is because the svgs generated by STRING & STITCH are given with the same ID.  Differentiating this will help selecting things more accurately, where needed
          
          
          output$stitch_out <- renderUI ({
            withProgress(message = 'Preparing network for visualization',
                         detail = 'Please wait...', value = 0, {
                           for (i in 1:10) {
                             incProgress(1/10)
                             Sys.sleep(0.25)
                           }
                         })
            
            tags$div(class = 'string_db_network',
                     tags$div(id = 'stitchEmbedded', HTML(svg_html))
            )
          })
          if(type_stitch=="functional")
          {
            print_type="Full (functional & physical)"
          }
          else
          {
            print_type="Physical"
            
          }
          output$stitch_parameters_table <- renderUI({
            p(strong("Organism: "), species_stitch, " | ", strong("Network Type: "), print_type, " | ", strong("Meaning of network edges:"), edges_stitch, " | ", strong("Interaction score cut-off: "), as.numeric(score_stitch)/1000)
          })
          
          ids_svg_stitch <- paste(unlist(ids_init_stitch), sep = "%0d", collapse = "%0d")
          
          # link to stitch
          stitch_link <-  sprintf("http://stitch.embl.de/api/image/network?identifiers=%s&species=%s&network_type=%s&network_flavor=%s&required_score=%s", ids_svg_stitch, species_stitch, type_stitch, edges_stitch, score_stitch)
          
          
          #request to create a tsv for the network
          tryCatch(
            expr={
              h_tsv <- new_handle(url="https://string-db.org/api/tsv/network", CONNECTTIMEOUT = connect_timeout)
              handle_setform(h_tsv,
                             identifiers=ids_svg_stitch,
                             species=sprintf("%s",species_stitch),
                             network_type=type_stitch,
                             network_flavor=edges_stitch,
                             required_score=score_stitch,
                             caller_identity = "OnTheFly@bib.fleming"
              )
              h_tsv_curl <- curl_fetch_memory("https://string-db.org/api/tsv/network", h_tsv)
              stitch_tsv <- rawToChar(h_tsv_curl$content)
            },
            error = function(err) {
              cat("Some connection error, probably timeout\n", file=stderr())
              cat(sprintf("%s\n", err), file=stderr())
            },
            finally = {
              if(!exists("stitch_tsv"))
              {
                stitch_tsv=stitch_link
              }
            }
            
          )
          
          
          
          
          svg_to_png_js_code="var dv = document.getElementById('stitchEmbedded');
  var svg = dv.getElementsByTagName('svg')[0];
  var svgData = new XMLSerializer().serializeToString( svg );
  
  var canvas = document.createElement( 'canvas' );
  var ctx = canvas.getContext( '2d' );
  
  var img = document.createElement( 'img' );
  img.setAttribute( 'src', 'data:image/svg+xml;base64,' + btoa( svgData ) );
  
  img.onload = function() {
    var canvas = document.createElement('canvas');
    canvas.width = img.width;
    canvas.height = img.height;
    var context = canvas.getContext('2d');
    context.drawImage(img, 0, 0);
    
    var a = document.createElement('a');
    a.download = 'network.png';
    a.href = canvas.toDataURL('image/png');
    document.body.appendChild(a);
    a.click();
  }"
          
          
          output$tsv_stitch <- renderUI({
            fluidRow(
              actionButton(inputId = 'stitch_link', label = 'Open in STITCH', icon = icon('link'), onclick = sprintf("window.open('%s', '_blank')", stitch_link)),
              downloadButton(outputId = 'dnl_tsv_stitch', label = 'Download Network', icon = icon('download')),
              actionButton(inputId = 'dnl_png_stitch', label = 'Export Image', icon = icon('image'), onclick =svg_to_png_js_code)
            )
          })
          
          
          #download file dialog for saving a tsv text
          output$dnl_tsv_stitch <-downloadHandler(
            filename = "network.tsv",
            content = function(file) {
              write(stitch_tsv, file)
            }
          )
          
          
          output$stitch_legend <- create_network_legend("stitch", edges_stitch)
          
          
          js$int_network()
          removeModal()
        }
      }
      else
      {
        shinyalert(
          title = 'No Identifiers found',
          text = 'Select Identifiers from Selection tab',
          size = 's', 
          closeOnEsc = T,
          type = 'error',
          showConfirmButton = T,
          confirmButtonText = "OK",
          confirmButtonCol = 'rgb(31, 191, 164)',
          animation = T
        )
      }
    }
    else
    {
      shinyalert(
        title = 'No Organism selected',
        text = 'Please select an organism for analysis',
        size = 's', 
        closeOnEsc = T,
        type = 'error',
        showConfirmButton = T,
        confirmButtonText = "OK",
        confirmButtonCol = 'rgb(31, 191, 164)',
        animation = T
      ) 
    }
  })
  
  ##Help, About and Cookies functions-####
  
  #render table of available organisms for the Help section-#### 
  output$org_table <- table_of_organisms()
  
  #--cookie consent box event----####
  #this will redirect to the privacy policy panel
  observeEvent(input$privacy_notice, {
    
    updateTabItems(session, "dashboardtabs", "about")
    updateTabsetPanel(session, inputId = "about_pages", selected = "Privacy Policy")
    #}
  })
  
  #-go to organisms list events-####
  observe(
    lapply(input[["select"]], function(id) {
      observeEvent(input[[sprintf('org_list%s', id)]], {
        shinyjs::show("annotate_redirect_org")
        updateTabItems(session, "dashboardtabs", "help")
        updateTabsetPanel(session, inputId = "help_pages", selected = "Available Organisms")    
      })
    })
  )
  #-dismiss the above banner-####
  observeEvent(input$dismiss_annot_msg_org, {
    shinyjs::hide("annotate_redirect_org")
  })
  
  
  
  
  #----Events on session end----####
  session$onSessionEnded(function() {
    file_names <<- list()
    file_ids <<- list()
    global_positions <<-list()
    barplot_table <<- data.frame()
    #files_to_change <<-c()
    cat("Session Ended\n", file=stderr())
    print(file_ids)
  })
  
}

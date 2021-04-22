
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
  
  
  
  #----Show alert if annotation is not ready and the user selects another tab----####
  observeEvent(input$dashboardtabs, {
    if(input$dashboardtabs == 'selections' & is.null(input$upload)) {
      shinyalert(
        inputId = 'no_dataset',
        title = 'No data yet',
        text = 'File annotation is required',
        size = 's', 
        closeOnEsc = T,
        type = 'warning',
        showConfirmButton = T,
        confirmButtonText = "OK",
        confirmButtonCol = 'rgb(31, 191, 164)',
        animation = T
      )
      observeEvent(input$no_dataset, {
        if(input$no_dataset == T) {
          updateTabItems(session, "dashboardtabs", 'annotation')
        }
      })
    }
  })
  
  
  
  
  
  #----Upload and convert to html multiple files (pdf, txt)----####
  observeEvent(input$upload,  {
    cat("uploading_files...\n", file=stderr())
    cat(session$token, file=stderr())
    print(input$preserve_layout)
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
                                      label = '(Required) Select entity type(s):',
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
                                    column(6, style = "float: right;", 
                                           pickerInput(
                                             inputId = sprintf('orgpicker%s', id),
                                             label = '(Optional) Select organism(s) for protein annotation:',
                                             choices = organismchoice,
                                             multiple = T,
                                             selected = organismchoice[[1]],
                                             width = '98%',
                                             options = list(
                                               `actions-box` = T,
                                               `deselect-all-text` = 'Deselect all',
                                               `select-all-text` = 'Select all',
                                               `none-selected-text` = 'No organism selected',
                                               `selected-text-format` = paste0('count > ', length(organismchoice)-1),
                                               `count-selected-text` = 'ALL'
                                             )
                                           ),
                                           textInput(inputId = sprintf('moreorg%s', id), label = '(Optional) Write a Taxon Identifier:', placeholder = org_plcholder, width = '96%')
                                    ),
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
                                tags$iframe(id = sprintf("document-%s", id), class = 'pdf_frame', src = sprintf('tmp/%s.html', id), frameborder = '0'),
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
    #print(input$select)
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
    print(input$js_fileNames)
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
          if(!is.null(input[[sprintf('orgpicker%s', id)]])){
            org=input[[sprintf('orgpicker%s', id)]]
          }
          else if(!is.null(input[[sprintf('moreorg%s', id)]])){
            org=input[[sprintf('moreorg%s', id)]]
          }          
          else
          {
            org=input[[sprintf('orgpicker%s', id)]]
          }
          #print(var)
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
          #updateTabsetPanel(session, sprintf('tabset%s', id), selected = 'Entities')
        }
      })
    })
  })
  
  
  
  
  #----Reset Annotation form ---#### 
  observe({
    lapply(input$select, function(id){
      observeEvent(input[[sprintf('annotreset%s', id)]], {
        updatePickerInput(session, sprintf('typepicker%s', id), selected= filterchoices )
        updatePickerInput(session, sprintf('orgpicker%s', id), selected= organismchoice[[1]] )
        updateTextInput(session,  sprintf('moreorg%s', id), value = '')
        runjs(sprintf("document.getElementById('document-%s').src='tmp/%s.html'", id, id))
        shinyjs::hide(sprintf('infonew%s', id))
        shinyjs::hide(sprintf('infonewtab%s', id))
        shinyjs::hide(sprintf('info%s', id))
        shinyjs::hide(sprintf("tagging_legend%s", id))
        
      })
    })
  })
  
  
  
  
  #  observe({
  #    lapply(input$select, function(id) {
  #      observeEvent(input[[sprintf('moreorg%s', id)]], {
  #        if (input[[sprintf('moreorg%s', id)]] != '') {
  #          var <- array(input[[sprintf('moreorg%s', id)]])
  #          js$table(var)
  #        }
  #      })
  #    })
  #  })
  
  
  #----Rendering of entities datatables----####
  observeEvent (input$entities, {
    variable <- csv.entities(input$entities)
    data <- variable[[2]]
    data2 <- variable[[3]]
    #print(variable)
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
  
  #----Show table in analysis FE_enrichment tab----####
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
      datatable(all_sel_ids$dt, rownames = F, selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T))
    })
  })
  
  
  #----Delete rows in Identifiers_FE tab----####
  observeEvent(input$sel_analysis_rows_selected, {
    req(input$sel_analysis_rows_selected)
    all_sel_ids_FE$dt <- data.frame(
      all_sel_ids_FE$dt[-input$sel_analysis_rows_selected, ]
    )
    output$sel_analysis <- DT::renderDataTable({
      datatable(all_sel_ids_FE$dt, rownames = F, selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T))
    })
  })
  
  
  #----Delete rows in STRING Network tab----####
  observeEvent(input$sel_analysis_network_STRING_rows_selected, {
    req(input$sel_analysis_network_STRING_rows_selected)
    all_sel_ids_network_STRING$dt <- data.frame(
      all_sel_ids_network_STRING$dt[-input$sel_analysis_network_STRING_rows_selected, ]
    )
    output$sel_analysis_network_STRING <- DT::renderDataTable({
      datatable(all_sel_ids_network_STRING$dt, rownames = F, selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T))
    })
  })
  
  #----Delete rows in STITCH Network tab----####
  observeEvent(input$sel_analysis_network_STITCH_rows_selected, {
    req(input$sel_analysis_network_STITCH_rows_selected)
    all_sel_ids_network_STITCH$dt <- data.frame(
      all_sel_ids_network_STITCH$dt[-input$sel_analysis_network_STITCH_rows_selected, ]
    )
    output$sel_analysis_network_STITCH <- DT::renderDataTable({
      datatable(all_sel_ids_network_STITCH$dt, rownames = F, selection = list(mode = "multiple", target = 'row'), options = list(paging=F, scrollY="400px", scroller=T))
    })
  })  
  
  
  #----Delete all in combined_dataset tab----####
  observeEvent(input$reset_dataset, {
    shinyjs::hide('analyzeinfo_FE')
    shinyjs::hide('analyzeinfo_network')
    shinyjs::hide('analyzeinfo_network_STITCH')
    shinyjs::show('dataset_null')
    all_sel_ids$dt <- data.frame()
    output$collected_dataset_table <- DT::renderDataTable({
      datatable(all_sel_ids$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
    })
  })  
  
  #----Delete all in Identifiers_FE tab----####
  observeEvent(input$delete_all, {
    all_sel_ids_FE$dt <- data.frame()
    output$sel_analysis <- DT::renderDataTable({
      datatable(all_sel_ids_FE$dt, rownames = F, selection = list(mode = "multiple", target = 'row'))
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
  
  #----Functional Enrichment Analysis----####  
  observeEvent(input$analyze, {
    showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
    updateTabsetPanel(session,'all_identifiers_FE', 'Results')
    req(input$organisms)
    req(input$sources)
    req(input$correction_method)
    req(input$pvalue)
    shinyjs::show('result_info')
    org = org_map[[input$organisms]] #organism
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
        go_conv <-gconvert(ids_init, organism = org, target=id_output_type, mthreshold = Inf, filter_na = TRUE)
        gost_query <- go_conv$target
      }
      mixed_gost <- gost(
        query = gost_query,
        organism = org,
        user_threshold = pvalue,
        correction_method = corr,
        sources = dbs,
        evcodes = T,
        significant = T
      )
      
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
          enr_score <-enrich_score(query_results[["No. of Positive Hits"]], query_results[["Term size"]])
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
              #create KEGG prefix from organism name: 1st letter of genus, 2 first letters of species adjective
              # for example, homo sapiens = hsa, mus musculus = mmu etc
              organism_name <- unlist(strsplit(input$organisms, " "))
              prefix <- tolower(sprintf("%s%s", substr(organism_name[1],0,1), substr(organism_name[2],0,2)))
              
              
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
              entrez_url_elem <- paste(unlist(genes), sep = '%20orange,black+', collapse = '%20orange,blue+')
              ref_url <- sprintf("%s+%s", ref_url, entrez_url_elem)
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
        
        #gost_output_table[grepl(sprintf("^%s$", dbs[i]), gost_output_table$Source),]
        #print(gost_results_tables)
        
        #FE: tables output-####
        
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
        
        
        
        #FE: Manhattan plot-####
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
        
        
        #FE: bar plot preparation-####
        bar_colors <- c('GO:MF'= "#dc3912", 'GO:BP'= "#ff9900", 'GO:CC' = "#109618", 'KEGG' =
                          "#dd4477", 'REAC' = "#3366cc", 'WP' = "#0099c6", 'TF' = "#5574a6", 'MIRNA' = "#22aa99", 'HPA' =
                          "#6633cc", 'CORUM' = "#66aa00", 'HP' = "#990099")
        
        #rendering and updating menu options:
        shinyjs::show("barplot_controls")
        #updating options in barplot select source
        updatePickerInput(session, "barSelect", choices=dbs)
        
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
  })
  
  #-- Manhattan clicking events-####
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
  
  #---FE Barplot rendering events--####
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
  
  
  #----check if Functional Enrichment is enabled----####  
  output$FE_ready <- reactive({
    return(!is.null(input$analyze))
  })
  outputOptions(output, 'FE_ready', suspendWhenHidden = FALSE)
  
  
  #----Tab STRINGdb network----####
  observeEvent(input$network_string, {
    showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
    shinyjs::show('result_info_STRING')
    updateTabsetPanel(session,'all_identifiers_string', 'Network Viewer')
    
    identifiers <- all_sel_ids_network_STRING$dt$Identifier
    ids_init <-character(0)
    for(i in 1:length(identifiers))
    {
      if(!is.na(identifiers[i]) & substring(identifiers[i],0,4) != 'CIDs')
      {
        ids_init <- append(ids_init, identifiers[i])
      }
    }
    
    
    if(length(ids_init)<=100)
    {
      ids_init <- ids_init
    }
    else
    {
      ids_init <- ids_init[1:100]
    }
    
    ids_init <- gsub("[[:space:]]", "", ids_init)
    ids_interactive <- paste(unlist(ids_init), sep = "','", collapse = "','")
    
    species_interactive <- species_map[[input$organisms_network]]
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
    download_tsv <- sprintf("https://string-db.org/api/tsv/network?identifiers=%s&species=%s&network_type=%s&required_score=%s", ids_dnl_string, species_interactive, type_interactive, score_interactive)
    download_png <- sprintf("https://string-db.org/api/image/network?identifiers=%s&species=%s&network_type=%s&required_score=%s", ids_dnl_string, species_interactive, type_interactive, score_interactive)
    
    #A small API call to get the STRING URL:
    # 'get_link' returns a file (json, tsv or XML) containing the URL to the string website
    #we call it with a curl request and decode it
    string_link_raw <- curl_fetch_memory(sprintf("https://string-db.org/api/tsv-no-header/get_link?identifiers=%s&species=%s&network_type=%s&required_score=%s", ids_dnl_string, species_interactive, type_interactive, score_interactive))
    string_link <- trimws(rawToChar(string_link_raw$content))
    #Now you have a STRING url
    
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
        actionButton(inputId = 'dnl_tsv_string', label = 'Download Network', icon = icon('download'),  style='md-flat', onclick = sprintf("window.open('%s', '_blank')", download_tsv)),
        actionButton(inputId = 'dnl_png_string', label = 'Export Image', icon = icon('image'),  style='md-flat', onclick = sprintf("window.open('%s', '_blank')", download_png))
      )
    })
    
    output$string_legend <- create_network_legend("string", edges_interactive)
    
    removeModal()
    js$int_network()
  })
  
  
  #----Tab STITCHdb network----####
  observeEvent(input$network_stitch, {
    showModal(modalDialog(span('Analysis in Progress, please wait...', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;position:absolute;top:50%;left:50%'))
    shinyjs::show('result_info_STITCH')
    updateTabsetPanel(session,'all_identifiers_stitch', 'Network Viewer')
    
    ids_init_stitch <- all_sel_ids_network_STITCH$dt$Identifier
    ids_init_stitch <- gsub("[[:space:]]", "", ids_init_stitch)
    
    species_stitch <- species_map[[input$organisms_stitch_network]]
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
    #the SVG canvas is fetched through a curl request.  Standard jquery requests DO NOT WORK (error in CORS policy)
    stitch_url <- sprintf("http://stitch.embl.de/api/svg/networkList?identifiers=%s&network_type=%s&network_flavor=%s&required_score=%s", ids_svg_stitch, type_stitch, edges_stitch, score_stitch)
    print(stitch_url)
    svg_raw <- curl::curl_fetch_memory(stitch_url) #curl to get raw data in memory
    svg_html <- rawToChar(svg_raw$content) # convert raw memory data to ascii text
    
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
    download_tsv <- sprintf("https://string-db.org/api/tsv/network?identifiers=%s&species=%s&network_type=%s&required_score=%s", ids_svg_stitch, species_stitch, type_stitch, score_stitch)
    download_png <- sprintf("http://stitch.embl.de/api/image/networkList?identifiers=%s&species=%s&network_type=%s&required_score=%s", ids_svg_stitch, species_stitch, type_stitch, score_stitch)
    
    stitch_link <- sprintf("http://stitch.embl.de/api/image/network?identifiers=%s&species=%s&network_type=%s&required_score=%s", ids_svg_stitch, species_stitch, type_stitch, score_stitch)
    
    
    
    output$tsv_stitch <- renderUI({
      fluidRow(
        actionButton(inputId = 'stitch_link', label = 'Open in STITCH', icon = icon('link'), onclick = sprintf("window.open('%s', '_blank')", stitch_link)),
        actionButton(inputId = 'dnl_tsv_stitch', label = 'Download Network', icon = icon('download'), onclick = sprintf("window.open('%s', '_blank')", download_tsv)),
        actionButton(inputId = 'dnl_png_stitch', label = 'Export Image', icon = icon('image'), onclick = sprintf("window.open('%s', '_blank')", download_png))
      )
    })
    
    
    output$stitch_legend <- create_network_legend("stitch", edges_stitch)
    
    
    js$int_network()
    removeModal()
  })
  
  
  #----Events on session end----####
  session$onSessionEnded(function() {
    file_names <<- list()
    file_ids <<- list()
    global_positions <<-list()
    barplot_table <<- data.frame()
    #files_to_change <<-c()
    print("Session Ended")
    print(file_ids)
  })
  
}

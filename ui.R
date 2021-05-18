source('server.R')
source('help.R')
source('about.R')

ui <- shinyUI(
  dashboardPagePlus(
    
    title = app_title,
    header = dashboardHeaderPlus(
      tags$li(
        class="dropdown", 
        tags$style(".main-header {height:80px;}"),
        tags$style(".main-header .logo {height:80px;}"),
        tags$head(tags$script(src = "cookies.js")),
      ),
      title = tags$a(href="",tags$img(src="images/logo.png")),
      titleWidth = 500
    ),
    sidebar = dashboardSidebar(
      tags$style(".left-side, .main-sidebar {padding-top: 80px;}"),
      tags$style(".sidebar-toggle {display:none}"), #disable the collapse button, because we don't want it
      width = 300,
      sidebarMenu(
        id = 'dashboardtabs',
        menuItem('Home', tabName = 'welcome', icon = icon('home')),
        menuItem('Annotate Files', tabName = 'annotation', icon = icon('edit')),
        menuItem('Create Dataset', tabName = 'selections', icon = icon("check", lib = "glyphicon")), 
        menuItem('Functional Enrichment', tabName = 'FE', icon = icon("cogs"),
                 menuItem('Ontologies & Pathways (g:Profiler)', tabName = 'FE_gProfiler', icon = icon("atom")),
                 menuItem('Domains & Diseases (aGOtool)', tabName = 'FE_aGO', icon = icon("user-md"))
        ),
        menuItem('Publication Enrichment', tabName = 'PMID', icon = icon("book")),
        menuItem('Interaction Networks', tabName = 'interactions', icon = icon('project-diagram'),
                 menuItem("Protein-Protein (STRING)", tabName = "String", icon = icon('dna')),
                 menuItem("Protein-Chemical (STITCH)", tabName = "Stitch", icon = icon('flask'))
        ), 
        menuItem('Help', tabName = 'help', icon = icon('question')),
        menuItem('About', tabName = 'about', icon = icon('info-circle'))
      )
    ),
    body = dashboardBody(
      shinyDashboardThemes(theme = 'poor_mans_flatly'),
      tabItems(
        #-Home Page-####
        tabItem(tabName = 'welcome',
                fluidPage(
                  HTML("<h1>OnTheFly<sup>2.0</sup>"),
                  h3('Automated document annotation and biological information extraction'),
                  hr(),
                  HTML('<span id="paragraphs">OnTheFly<sup>2.0</sup> is a web application to aid users collecting biological information from documents. With OnTheFly<sup>2.0</sup> one is able to:</span><br>'),
                  tags$ul(
                    tags$li("Extract bioentities from individual articles in formats such as plain text, Microsoft Word, Excel and PDF files."),
                    tags$li("Scan images and identify terms by using Optical Character Recognition (OCR)."),
                    tags$li("Handle multiple files simultaneously."),
                    tags$li("Isolate proteins, chemical compounds, organisms, tissues, diseases/phenotypes and gene ontology terms."),
                    tags$li("Extract selected terms along with their identifiers in databases."),
                    tags$li("Perform functional enrichment analysis on a selected group of terms."),
                    tags$li("Identify co-occurring proteins in the scientific literature and in protein domain databases"),
                    tags$li("Generate and visualize protein-protein and protein-chemical interaction networks."),
                    style="font-size:15px"),
                  hr(),
                  HTML("<p style='font-size:15px'>If you find OnTheFly<sup>2.0</sup> useful in your work please cite:</p>
                       <ul>
                       <li>Baltoumas, F.A., Zafeiropoulou, S., Karatzas, E., Pagkaramian, S., Thanati, F., Iliopoulos, I., Eliopoulos, A.G.,  Schneider, R., Jensen, L.J., Pafilis, E., Pavlopoulos, G.A. (2021) <b>OnTheFly<sup>2.0</sup>: a text-mining web application for automated biomedical entity recognition, document annotation, network and functional enrichment analysis</b>. <i>bioRxiv</i> 2021.05.14.444150. doi: 10.1101/2021.05.14.444150</li>
                       <li>Pavlopoulos, G.A., Jensen, L.J., Pafilis, E., Kuhn, M., Hooper, S.D., Schneider, R. (2009) <b>OnTheFly: a tool for automated document-based text annotation, data linking and network generation</b>. <i>Bioinformatics</i>, Apr 1;25(7):977-8. doi: 10.1093/bioinformatics/btp081.</li>
                       </ul>")
                  
                )
        ),
        #-Annotate Documents-####
        tabItem(tabName = 'annotation',
                fluidPage(
                  useShinyjs(),
                  useShinyalert(),
                  tags$head(includeCSS(css_path)),
                  tags$script(src = js_path),
                  extendShinyjs(js_path, functions = c('annotate', 'table', 'ZoomInIframe', 'int_network')),
                  h2("Annotate Documents"),
                  sidebarLayout(
                    sidebarPanel(
                      wellPanel(
                        h5('1. Upload file(s):', style='font-weight:bold;color:#1c3b01'),
                        fileInput(inputId = 'upload',label='Select one or more files to upload', multiple = T, placeholder = file_plcholder, accept  = file_extensions),
                        #checkboxInput(inputId = 'preserve_layout', label="Fully Preserve PDF layout (for PDF files only)", value = F),
                        HTML("<p><b>Maximum upload size per file:</b> 10 MB<br>
                        <b>Acceptable File Types:</b> PDF (.pdf), Office texts (.doc, .docx, .odt, .rtf), Spreadsheet files (.xls, .xlsx, .ods), Flat text (.txt, .tsv, .csv), Images (.bmp, .png, .jpg, .tif), PostScript (.ps, .eps)
                             </p><br><b>Note:</b>For images, please use a resolution of at least 150 ppi (pixels per inch)."),
                        hr(),
                        textAreaInput(inputId = 'textinput', label = 'Or...write a text here:', placeholder = txt_plcholder, resize = 'vertical', height="80px"),
                        actionBttn(inputId = 'addtext', label = 'ADD', style = 'material-flat', size = 'sm', icon = icon('plus')),
                        actionBttn(inputId = 'addexample', label = 'LOAD EXAMPLE', 'material-flat', size = 'sm', color='warning', icon = icon('book')),
                        actionBttn(inputId = 'clearText', label = 'CLEAR', style = 'material-flat', size = 'sm', color='danger', icon = icon('minus')),
                        
                      ),
                      conditionalPanel(
                        condition = 'output.text_ready | output.upload_ready',
                        wellPanel(id="uploaded_file_selector",
                                  #uiOutput('selectfiles'),
                                  h5('2. View and manipulate files:',  style='font-weight:bold;color:#1c3b01'),
                                  prettyCheckboxGroup( #change selectizeinput to checkboxes
                                    inputId = 'select', 
                                    label = 'Click to select file(s)', 
                                    shape = 'curve', #style
                                  ),
                                  actionBttn(inputId = 'rename', label = 'Rename', style = 'material-flat', size = 'sm', icon = NULL),
                                  actionBttn(inputId = 'remove', label = 'Delete', style = 'material-flat', size = 'sm', icon = icon('trash-alt'))
                        )
                      )
                    ),
                    mainPanel(
                      
                      uiOutput('fileview')
                    )
                  )
                )
        ),
        #-Create Dataset-####
        tabItem(tabName = 'selections',
                fluidPage(
                  h2("Create Dataset for Analysis"),
                  sidebarLayout(
                    sidebarPanel(
                      uiOutput('table_select'),
                      hr(),
                      p("In this page, you can choose a number of terms to create a dataset for analysis."),
                      tags$ol(
                        tags$li(HTML("Use the <b>selection menu</b> above to select the documents you wish to analyze.")),
                        tags$li(HTML("Each selected document will appear in its own Tab panel, in the <b>Annotated Documents</b> of this page.")),
                        tags$li(HTML("For each document, select one or more proteins and/or chemicals by <b>clicking</b> on them. Click <b>Add to Dataset</b> to add them to a dataset for analysis.")),
                        tags$li(HTML("Your selected terms will appear in a new panel, marked <b>Dataset</b>.")),
                        tags$li(HTML("You can do the above for <b>multiple documents</b>, by repeating the same procedure. The produced dataset can include terms from <b>multiple</b> documents.")),
                        tags$li(HTML("In the <b>Dataset</b> panel, click on <b>Enrichment: g:Profiler</b>, <b>Enrichment: aGOtool</b>, <b>Publication Enrichment</b>, <b>Protein-Protein Network</b> or <b>Protein-Chemical Network</b> to add your selected terms to a dataset for Functional Enrichment Analysis, or creating Protein-Protein or Protein-Chemical interaction networks.")),
                        tags$li(HTML("When you are ready, click one of the options on the left-side menu to select an analysis method:"), 
                                tags$ul(
                                  tags$li(HTML("<b>Ontologies & Pathways (g:Profiler)</b> performs functional enrichment analysis on Ontology (GO, Phenotype etc) and Pathway (KEGG, Reactome tc) databases using g:Profiler.")),
                                  tags$li(HTML("<b>Databases & Diseases (aGOtool)</b> performs functional enrichment analysis on Protein family databases (Pfam, InterPro) and the DISEASES database using aGOtool.")),
                                  tags$li(HTML("<b>Literature Search</b> searches your selected proteins against the scientific literature.")),
                                  tags$li(HTML("<b>Interaction Network</b> creates protein-protein or protein-chemical interaction networks.  Two choices are given: <b>Protein-Protein</b> for protein-protein networks and <b>Protein-Chemical</b> for protein chemical networks."))
                                )
                        )
                      )
                    ),
                    mainPanel(
                      fluidPage(
                        tabBox(
                          id="dataset_creator",
                          tabPanel(id='select_files_view','Annotated Documents', icon = icon('book'),
                                   div(id = 'nodata_create_dataset', p('No annotated documents detected.  Navigate to', strong("Annotate Documents"), "to upload and annotate documents.")),
                                   uiOutput('tableview')
                          ),
                          tabPanel(id='collected_dataset', 'Dataset',
                                   div(id = 'dataset_info', p(HTML('Click <b>Enrichment: g:Profiler</b>, <b>Enrichment: aGOtool</b>, <b>Publication Enrichment</b>, <b>Protein-Protein Network</b> or <b>Protein-Chemical Network</b> to send collected data for analysis.  Click <b>Delete All</b> to clear your selection.'),  style = 'margin-left: 8px;'), style="background-color:#e7f3fe;font-size:18px;display:none"),
                                   div(id = 'dataset_null', p(HTML("Select one or more terms from the <b>Entities</b> tab." ),  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px;display:none"),
                                   div(id = 'analyzeinfo_FE', p('Check your collected Identifiers in the ', strong('"Functional Enrichment->Ontologies & Pathways (g:Profiler)"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#0d6efd;color:white;"),
                                   div(id = 'analyzeinfo_Pfam', p('Check your collected Identifiers in the ', strong('"Functional Enrichment->Domains & Diseases (aGOtool)"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#597164;color:white;"),
                                   div(id = 'analyzeinfo_PMID', p('Check your collected Identifiers in the ', strong('"Publication Enrichment"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#bd2df5;color:white;"),
                                   div(id = 'analyzeinfo_network', p('Check your collected Identifiers in the ', strong('"Interaction Networks->Protein-Protein (STRING)"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#198754;color:white"),
                                   div(id = 'analyzeinfo_network_STITCH', p('Check your collected Identifiers in the ', strong('"Interaction Networks->Protein-Chemical (STITCH)"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#ffc107;"),
                                   
                                   actionBttn(inputId = 'collect_FE', label = 'Enrichment: g:Profiler', style="material-flat", color="primary", size = 'sm', icon = icon('cogs')),
                                   actionBttn(inputId = 'collect_Pfam', label = 'Entichment: aGOtool', style="material-flat", color="default", size = 'sm', icon = icon('atom')),
                                   actionBttn(inputId = 'collect_PMID', label = 'Publication Enrichment', style="material-flat", color="royal", size = 'sm', icon = icon('book')),
                                   actionBttn(inputId = 'collect_STRING', label = 'Protein-Protein Network', style ="material-flat", color="success", size = 'sm', icon = icon('dna')),
                                   actionBttn(inputId = 'collect_STITCH', label = 'Protein-Chemical Network', style ="material-flat", color="warning", size = 'sm', icon = icon('flask')),
                                   
                                   actionBttn(inputId = 'reset_dataset', label = 'Delete All', style ="material-flat", color="danger", size = 'sm', icon = icon('trash')),
                                   boxPlus(
                                     width = 70,
                                     solidHeader = T,
                                     pickerInput(
                                       inputId = 'tblchoose',
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
                                     DT::dataTableOutput('collected_dataset_table')
                                   )
                          )
                        )
                      )
                    )
                  )
                  
                )
        ),
        #-Functional Enrichment: gProfiler-####
        tabItem(tabName = 'FE_gProfiler',
                fluidPage(
                  h2("Functional Enrichment Analysis: g:Profiler"),
                  tabBox(
                    id = 'all_identifiers_FE', 
                    tabPanel(id='input_FE','Input', icon = icon('keyboard'), 
                             fluidRow(
                               div(id = 'result_info', p('Enrichment results will be shown in', strong('"Results"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px;display:none"),
                               sidebarPanel(
                                 selectizeInput(
                                   inputId = "organisms",
                                   label = "1. Select organism:",
                                   choices = organisms$print_name,
                                   multiple = F,
                                   selected = "Homo sapiens (Human) [NCBI Tax. ID: 9606]", # maybe use "Homo sapiens (Human) [NCBI Tax. ID: 9606]"
                                   width = "98%",
                                   options = list(
                                     placeholder = 'Select an option or start typing...'
                                   )
                                 ),
                                 pickerInput(
                                   inputId = 'sources',
                                   label = '2. Select data source(s):',
                                   choices = source_choices,
                                   selected = c(source_choices$`Gene Ontology`,source_choices$`Biological Pathways`),
                                   multiple = T,
                                   options = list(
                                     `actions-box` = T,
                                     `deselect-all-text` = 'Deselect all',
                                     `select-all-text` = 'Select all',
                                     `none-selected-text` = 'No source(s) selected'
                                   )
                                 ),
                                 h5(strong("3. Select significance options")),
                                 fluidRow( id="sig_options",
                                           column(6, float="left",
                                                  pickerInput(
                                                    inputId="correction_method",
                                                    label = 'Threshold Type:',
                                                    choices = FE_significance_method,
                                                    selected = FE_significance_method[["g:SCS"]]
                                                  )),
                                           column(6, float="right", 
                                                  pickerInput(
                                                    inputId="pvalue",
                                                    label = 'P-value cut-off:',
                                                    choices = FE_cutoff_choices,
                                                    selected = FE_cutoff_choices[[6]]
                                                  )
                                           )
                                 ),
                                 pickerInput(
                                   inputId = 'FE_id_types',
                                   label = '4. Select Protein ID type for output:',
                                   choices = FE_id_types,
                                   selected = FE_id_types[[1]]
                                 ),                                 
                                 actionBttn(inputId = 'analyze', label = 'Analyze data', style = 'material-flat', size = 'md'),
                                 actionBttn(inputId = 'delete_all', label = 'Delete All', style = 'material-flat', size = 'md', icon = icon('trash-alt'))
                               ),
                               mainPanel(
                                 div(id = 'nodata_FE_info', p('No data selected.  Navigate to', strong("Create Dataset"), "to select your input data.")),
                                 DT::dataTableOutput('sel_analysis')
                               )
                             )
                    ),
                    tabPanel('Results', icon = icon('table'),
                             
                             h4(strong("Input Parameters:")),
                             uiOutput('FE_parameters'),
                             hr(),
                             tabBox(id='FE_results_box',
                                    tabPanel('Table', icon = icon('table'),
                                             boxPlus(
                                               width = 11,
                                               solidHeader = T,
                                               uiOutput("FE_results_table")
                                               
                                               
                                             )
                                    ),
                                    tabPanel('Manhattan Plot', icon = icon('chart-line'),
                                             boxPlus(
                                               width = 12,
                                               solidHeader = T,
                                               tags$style(".modebar-btn {font-size:20px !important;}"),
                                               tags$style(".annotation-text {display:none !important;}"),
                                               plotlyOutput(outputId = 'FE_plot'),
                                               hr(),
                                               p(strong("Left click"), " on a single node in the plot to display its information below. Use the ", strong("Box Select"), " or " , strong("Lasso Select") ," functions to select multiple nodes and retrieve information for all of them."),
                                               DT::dataTableOutput("manhattan_table")
                                             )
                                    ),
                                    tabPanel('Bar Plot', icon = icon('chart-bar'),
                                             useShinyjs(),
                                             boxPlus(
                                               width = 70,
                                               solidHeader = T,
                                               fluidRow(id="barplot_controls", style="display:none",
                                                        column(2, pickerInput(inputId="barSelect", label="1. Database:", choices = NULL, multiple = T,
                                                                              options = list(
                                                                                `actions-box` = T,
                                                                                `deselect-all-text` = 'Deselect all',
                                                                                `select-all-text` = 'Select all',
                                                                                `none-selected-text` = 'No source(s) selected'
                                                                              )
                                                        )
                                                        ),
                                                        column(4, radioButtons(inputId="barplotMode", label="2. Enrichment metric", choices = c("Enrichment Score", "-log10(P-value)"), inline=T)),
                                                        column(4, sliderInput(inputId="sliderBarplot", label="3. Number of terms in plot:", min = 1, max = 10, value = 10, step = 1, ticks = F),
                                                               br())
                                               ),
                                               uiOutput("barplot_loading"),
                                               br(),
                                               uiOutput( "barplot"),
                                               htmlOutput("bar_legend"),
                                               br(),
                                               DT::dataTableOutput("barplot_table")
                                             )
                                    )                    
                             )
                             
                    )
                    
                    
                  )
                )
        ),
        
        
        #-Functional enrichment: aGOtool-####
        tabItem(tabName = 'FE_aGO',
                fluidPage(
                  h2("Functional Enrichment Analysis: aGOtool"),
                  tabBox(
                    id = 'all_identifiers_Pfam', 
                    tabPanel(id='input_Pfam','Input', icon = icon('keyboard'), 
                             fluidRow(
                               div(id = 'result_info_Pfam', p('Enrichment results will be shown in', strong('"Results"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px;display:none"),
                               sidebarPanel(
                                 # pickerInput(
                                 #   inputId = 'organisms_Pfam',
                                 #   label = '1. Select organism to perform literature search:',
                                 #   choices = organismchoice
                                 # ),
                                 selectizeInput(
                                   inputId = "organisms_Pfam",
                                   label = "1. Select organism:",
                                   choices = organisms$print_name,
                                   multiple = F,
                                   selected = "Homo sapiens (Human) [NCBI Tax. ID: 9606]", # maybe use "Homo sapiens (Human) [NCBI Tax. ID: 9606]"
                                   width = "98%",
                                   options = list(
                                     placeholder = 'Select an option or start typing...'
                                   )
                                 ),
                                 pickerInput(
                                   inputId = 'sources_Pfam',
                                   label = '2. Select data source(s):',
                                   choices = Pfam_source_choices,
                                   selected = Pfam_source_choices,
                                   multiple = T,
                                   options = list(
                                     `actions-box` = T,
                                     `deselect-all-text` = 'Deselect all',
                                     `select-all-text` = 'Select all',
                                     `none-selected-text` = 'No source(s) selected'
                                   )
                                 ),
                                 h5(strong("3. Select significance options")),
                                 fluidRow( id="sig_options_Pfam",
                                           column(6, float="right",
                                                  pickerInput(
                                                    inputId="pvalue_Pfam",
                                                    label = 'P-value cut-off:',
                                                    choices = FE_cutoff_choices,
                                                    selected = FE_cutoff_choices[[6]]
                                                  )
                                           ),
                                           column(6, float="right",
                                                  pickerInput(
                                                    inputId="fdr_Pfam",
                                                    label = 'FDR correction cut-off:',
                                                    choices = FE_cutoff_choices,
                                                    selected = FE_cutoff_choices[[6]]
                                                  )
                                           )
                                 ),     
                                 pickerInput(
                                   inputId = 'Pfam_id_types',
                                   label = '4. Select Protein ID type for output:',
                                   choices = FE_id_types,
                                   selected = FE_id_types[[1]]
                                 ), 
                                 actionBttn(inputId = 'analyze_Pfam', label = 'Analyze data', style = 'material-flat', size = 'md'),
                                 actionBttn(inputId = 'delete_all_Pfam', label = 'Delete All', style = 'material-flat', size = 'md', icon = icon('trash-alt'))
                               ),
                               mainPanel(
                                 div(id = 'nodata_Pfam_info', p('No data selected.  Navigate to', strong("Create Dataset"), "to select your input data.")),
                                 div(id="dataset_form_Pfam", style="display:none",
                                     div(p(strong("Note:"), "For reasons of computational efficiency, a maximum of 1000 proteins can be used.", style="margin-left: 8px;"), style="background-color:#e7f3fe;font-size:18px;border-left: 5px solid #2e4353;margin-bottom: -5px;"),
                                     DT::dataTableOutput('sel_analysis_Pfam')
                                 )
                               )
                             )
                    ),
                    
                    tabPanel('Results', icon = icon('table'),
                             
                             h4(strong("Input Parameters:")),
                             uiOutput('Pfam_parameters'),
                             hr(),
                             tabBox(id='Pfam_results_box',
                                    tabPanel('Table', icon = icon('table'),
                                             boxPlus(
                                               width = 11,
                                               solidHeader = T,
                                               uiOutput("Pfam_results_table")
                                               
                                               
                                             )
                                    ),
                                    tabPanel('Bar Plot', icon = icon('chart-bar'),
                                             useShinyjs(),
                                             boxPlus(
                                               width = 70,
                                               solidHeader = T,
                                               fluidRow(id="barplot_controls_Pfam", style="display:none",
                                                        column(2, pickerInput(inputId="barSelect_Pfam", label="1. Database:", choices = NULL, multiple = T,
                                                                              options = list(
                                                                                `actions-box` = T,
                                                                                `deselect-all-text` = 'Deselect all',
                                                                                `select-all-text` = 'Select all',
                                                                                `none-selected-text` = 'No source(s) selected'
                                                                              )
                                                        )
                                                        ),
                                                        column(4, radioButtons(inputId="barplotMode_Pfam", label="2. Enrichment metric", choices = c("Enrichment Score", "-log10(FDR)", "-log10(P-value)"), inline=T)),
                                                        column(4, sliderInput(inputId="sliderBarplot_Pfam", label="3. Number of terms in plot:", min = 1, max = 10, value = 10, step = 1, ticks = F),
                                                               br())
                                               ),
                                               uiOutput("barplot_loading_Pfam"),
                                               br(),
                                               uiOutput( "barplot_Pfam"),
                                               htmlOutput("bar_legend_Pfam"),
                                               br(),
                                               DT::dataTableOutput("barplot_table_Pfam")
                                             )
                                    )                    
                             )
                             
                    )
                    
                    
                  )
                )
        ),
        
        #-Publication Enrichment-####
        tabItem(tabName = 'PMID',
                fluidPage(
                  h2("Publication Enrichment"),
                  tabBox(
                    id = 'all_identifiers_PMID', 
                    tabPanel(id='input_PMID','Input', icon = icon('keyboard'), 
                             fluidRow(
                               div(id = 'result_info_PMID', p('Publication Enrichment results will be shown in', strong('"Results"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px;display:none"),
                               sidebarPanel(
                                 selectizeInput(
                                   inputId = "organisms_PMID",
                                   label = "1. Select organism:",
                                   choices = organisms$print_name,
                                   multiple = F,
                                   selected = "Homo sapiens (Human) [NCBI Tax. ID: 9606]", # maybe use "Homo sapiens (Human) [NCBI Tax. ID: 9606]"
                                   width = "98%",
                                   options = list(
                                     placeholder = 'Select an option or start typing...'
                                   )
                                 ),
                                 h5(strong("2. Select significance options")),
                                 fluidRow( id="sig_options_PMID",
                                           column(6, float="right",
                                                  pickerInput(
                                                    inputId="pvalue_PMID",
                                                    label = 'P-value cut-off:',
                                                    choices = FE_cutoff_choices,
                                                    selected = FE_cutoff_choices[[6]]
                                                  )
                                           ),
                                           column(6, float="right",
                                                  pickerInput(
                                                    inputId="fdr_PMID",
                                                    label = 'FDR correction cut-off:',
                                                    choices = FE_cutoff_choices,
                                                    selected = FE_cutoff_choices[[6]]
                                                  )
                                           )
                                 ),        
                                 pickerInput(
                                   inputId = 'PMID_id_types',
                                   label = '3. Select Protein ID type for output:',
                                   choices = FE_id_types,
                                   selected = FE_id_types[[1]]
                                 ),
                                 actionBttn(inputId = 'analyze_PMID', label = 'Analyze data', style = 'material-flat', size = 'md'),
                                 actionBttn(inputId = 'delete_all_PMID', label = 'Delete All', style = 'material-flat', size = 'md', icon = icon('trash-alt'))
                               ),
                               mainPanel(
                                 div(id = 'nodata_PMID_info', p('No data selected.  Navigate to', strong("Create Dataset"), "to select your input data.")),
                                 div(id="dataset_form_PMID", style="display:none",
                                     div(p(strong("Note:"), "For reasons of computational efficiency, a maximum of 1000 proteins can be used.", style="margin-left: 8px;"), style="background-color:#e7f3fe;font-size:18px;border-left: 5px solid #2e4353;margin-bottom: -5px;"),
                                     DT::dataTableOutput('sel_analysis_PMID')
                                 )
                               )
                             )
                    ),
                    
                    tabPanel('Results', icon = icon('table'),
                             
                             h4(strong("Input Parameters:")),
                             uiOutput('PMID_parameters'),
                             hr(),
                             tabBox(id='PMID_results_box',
                                    tabPanel('Table', icon = icon('table'),
                                             boxPlus(
                                               width = 11,
                                               solidHeader = T,
                                               uiOutput("PMID_results_table")
                                               
                                               
                                             )
                                    ),
                                    tabPanel('Bar Plot', icon = icon('chart-bar'),
                                             useShinyjs(),
                                             boxPlus(
                                               width = 70,
                                               solidHeader = T,
                                               fluidRow(id="barplot_controls_PMID", style="display:none",
                                                        column(4, radioButtons(inputId="barplotMode_PMID", label="2. Enrichment metric", choices = c("Enrichment Score", "-log10(FDR)", "-log10(P-value)"), inline=T)),
                                                        column(4, sliderInput(inputId="sliderBarplot_PMID", label="3. Number of terms in plot:", min = 1, max = 10, value = 10, step = 1, ticks = F),
                                                               br())
                                               ),
                                               uiOutput("barplot_loading_PMID"),
                                               br(),
                                               uiOutput( "barplot_PMID"),
                                               htmlOutput("bar_legend_PMID"),
                                               br(),
                                               DT::dataTableOutput("barplot_table_PMID")
                                             )
                                    )                    
                             )
                             
                    )
                    
                    
                  )
                )
        ),
        
        
        #-Protein-Protein Network (STRING)-####
        tabItem(tabName = 'String',
                fluidPage(
                  tags$head(tags$script(src = string_source)),
                  h2("Protein-Protein interaction Network (STRING)"),
                  tabBox(
                    id = 'all_identifiers_string',
                    tabPanel( id='input_string', 'Input', icon = icon('keyboard'), 
                              fluidRow(
                                div(id = 'result_info_STRING', p('Network results will be shown in', strong('"Network Viewer"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px;display:none"),
                                sidebarPanel(
                                  # pickerInput(
                                  #   inputId = 'organisms_network',
                                  #   label = 'Select organism to extract network:',
                                  #   choices = organismchoice
                                  # ),
                                  selectizeInput(
                                    inputId = "organisms_network",
                                    label = "Select organism:",
                                    choices = organisms$print_name,
                                    multiple = F,
                                    selected = "Homo sapiens (Human) [NCBI Tax. ID: 9606]", # maybe use "Homo sapiens (Human) [NCBI Tax. ID: 9606]"
                                    width = "98%",
                                    options = list(
                                      placeholder = 'Select an option or start typing...'
                                    )
                                  ),
                                  hr(),
                                  radioButtons(
                                    inputId = 'type_string_network', 
                                    label = 'Select network type:', 
                                    choiceNames = list (
                                      HTML("<b>Full network</b> (edges indicate both functional and physical associations)"),
                                      HTML("<b>Physical subnetwork</b> (edges indicate existence of a physical complex)")
                                    ),
                                    choiceValues = list('functional', 'physical')
                                  ),
                                  hr(),
                                  radioButtons(
                                    inputId = 'edges_string_network', 
                                    label = 'Meaning of network edges:', 
                                    choiceNames = list (
                                      HTML("<b>Evidence</b> (edge colors indicate the type of interaction evidence)"),
                                      HTML("<b>Confidence</b> (edge thickness indicates the strength of data support based on confidence score)")
                                    ),
                                    choiceValues = list('evidence', 'confidence')
                                  ),
                                  hr(),
                                  pickerInput(
                                    inputId = 'score_string_network', 
                                    label = 'Minimum required interaction score:', 
                                    choices = STRING_network_score,
                                    selected = STRING_network_score[3]
                                  ),
                                  actionBttn(inputId = 'network_string', label = 'Create Network', style = 'material-flat', size = 'xs', icon = icon('dna')),
                                  actionBttn(inputId = 'delete_all_network_STRING', label = 'Delete All', style = 'material-flat', size = 'xs', icon = icon('trash-alt'))
                                  
                                ),
                                mainPanel(
                                  
                                  div(id = 'nodata_STRING_info', p('No data selected.  Navigate to', strong("Create Dataset"), "to select your input data.")),
                                  hidden(
                                    div(id="dataset_form_STRING",
                                        div(p(strong("Note:"), "For reasons of computational efficiency, a maximum of 500 proteins can be used.", style="margin-left: 8px;"), style="background-color:#e7f3fe;font-size:18px;border-left: 5px solid #2e4353;margin-bottom: -5px;"),
                                        DT::dataTableOutput('sel_analysis_network_STRING')
                                    )
                                  )
                                )
                              )
                    ),
                    tabPanel(id = 'results_string', 'Network Viewer', icon = icon('dna'),
                             boxPlus(
                               width = 70,
                               solidHeader = T,
                               htmlOutput('string_out'),
                               br(),
                               htmlOutput('tsv_string'),
                               br(),
                               wellPanel(
                                 width=70,
                                 h4(strong("Network parameters:")),
                                 htmlOutput('string_parameters_table'),
                                 br(),
                                 h4(strong("Network Legend:")),
                                 htmlOutput("string_legend")
                                 
                               )
                             )
                    )
                  )
                )
        ),
        #-Protein-Chemical Network (STITCH)-####
        tabItem(tabName = 'Stitch',
                fluidPage(
                  tags$head(tags$script(src = string_source)),
                  h2("Protein-Chemical interaction Network (STITCH)"),
                  tabBox(
                    id = 'all_identifiers_stitch',
                    tabPanel(id='input_stitch','Input', icon = icon('keyboard'), 
                             fluidRow(
                               div(id = 'result_info_STITCH', p('Network results will be shown in', strong('"Network Viewer"'), 'tab',  style = 'margin-left: 8px;'), style="background-color:#fcacac;font-size:18px;display:none"),
                               sidebarPanel(
                                 selectizeInput(
                                   inputId = "organisms_stitch_network",
                                   label = "Select organism:",
                                   choices = organisms$print_name,
                                   multiple = F,
                                   selected = "Homo sapiens (Human) [NCBI Tax. ID: 9606]", # maybe use "Homo sapiens (Human) [NCBI Tax. ID: 9606]"
                                   width = "98%",
                                   options = list(
                                     placeholder = 'Select an option or start typing...'
                                   )
                                 ),
                                 hr(),
                                 radioButtons(
                                   inputId = 'type_stitch_network', 
                                   label = 'Select network type:', 
                                   choiceNames = list (
                                     HTML("<b>Full network</b> (edges indicate both functional and physical associations)"),
                                     HTML("<b>Physical subnetwork</b> (edges indicate existence of a physical complex)")
                                   ),
                                   choiceValues = list('functional', 'physical')
                                 ),
                                 hr(),
                                 
                                 radioButtons(
                                   inputId = 'edges_stitch_network', 
                                   label = 'Meaning of network edges:', 
                                   choiceNames = list (
                                     HTML("<b>Evidence</b> (edge colors indicate the type of interaction evidence)"),
                                     HTML("<b>Confidence</b> (edge thickness indicates the strength of data support based on confidence score)"),
                                     HTML("<b>Molecular action</b> (edge colors and shapes indicate the biochemical types and effects of interactions)"),
                                     HTML("<b>Binding affinity</b> (edge thickness indicates binding affinity based on K<sub>i</sub> measurements, when available)")
                                   ),
                                   choiceValues = list('evidence', 'confidence', 'actions', 'ki')
                                 ),
                                 hr(),
                                 pickerInput(
                                   inputId = 'score_stitch_network', 
                                   label = 'Minimum required interaction score:', 
                                   choices = STRING_network_score,
                                   selected = STRING_network_score[3]
                                 ),
                                 actionBttn(inputId = 'network_stitch', label = 'Create Network', style = 'material-flat', size = 'xs', icon = icon('flask')),
                                 actionBttn(inputId = 'delete_all_network_STITCH', label = 'Delete All', style = 'material-flat', size = 'xs', icon = icon('trash-alt'))
                               ),
                               mainPanel(
                                 div(id = 'nodata_STITCH_info', p('No data selected.  Navigate to', strong("Create Dataset"), "to select your input data.")),
                                 hidden(div(id="dataset_form_STITCH",
                                            div(p(strong("Note:"), "For reasons of computational efficiency, a maximum of 100 proteins/chemicals can be used.", style="margin-left: 8px;"), style="background-color:#e7f3fe;font-size:18px;border-left: 5px solid #2e4353;margin-bottom: -5px;"),
                                            
                                            pickerInput(
                                              inputId = 'tblchoose_STITCH',
                                              label = 'Filter by Type:',
                                              width = '100%',
                                              choices = specifichoices,
                                              selected = specifichoices,
                                              multiple = T,
                                              options = list(
                                                `actions-box` = T,
                                                `deselect-all-text` = 'Deselect all',
                                                `select-all-text` = 'Select all',
                                                `none-selected-text` = 'No type(s) selected'
                                              )
                                            ),
                                            
                                            DT::dataTableOutput('sel_analysis_network_STITCH')
                                 )
                                 )
                               )
                             )
                    ),
                    tabPanel(id='results_stitch', 'Network Viewer', icon = icon('flask'),
                             boxPlus(
                               width = 70,
                               solidHeader = T,
                               htmlOutput('stitch_out'),
                               br(),
                               htmlOutput('tsv_stitch'),
                               br(),
                               wellPanel(
                                 width=70,
                                 h4(strong("Network parameters:")),
                                 htmlOutput('stitch_parameters_table'),
                                 br(),
                                 h4(strong("Network Legend:")),                               
                                 htmlOutput("stitch_legend")
                               )
                             )
                    )
                  )
                )
        ),
        #-Help pages----####
        tabItem(tabName = 'help',
                fluidPage(
                  h2("Help"),
                  tabsetPanel(id="help_pages",
                              tabPanel("Overview",
                                       br(),
                                       introduction_tab
                              ),                  
                              tabPanel("Annotation",
                                       br(),
                                       Annotation_tab_intro,
                                       bsCollapse(id = 'annotation_collapse', multiple = T,
                                                  bsCollapsePanel('File upload / Text input', file_upload_txt, style = 'warning'),
                                                  bsCollapsePanel('File management', file_management_txt, style = 'success'),
                                                  bsCollapsePanel('Document annotation', file_annotation_txt, style = 'info')
                                       )
                              ),
                              tabPanel("Create Dataset",
                                       br(),
                                       Dataset_tab_intro,
                                       bsCollapse(id = 'dataset_collapse', multiple = T,
                                                  bsCollapsePanel('Select Entities', entities_selection_txt, style = 'warning'),
                                                  bsCollapsePanel('Manage Dataset', sel_management_txt, style = 'success')
                                       )
                              ),
                              tabPanel("Functional Enrichment: g:Profiler",
                                       br(),
                                       FE_tab_intro,
                                       bsCollapse(id = 'FE_collapse', multiple = T,
                                                  bsCollapsePanel('Input', FE_input_txt, style = 'warning'),
                                                  bsCollapsePanel('Results', FE_results_txt, style = 'success')
                                       )
                              ),
                              tabPanel("Publication Enrichment",
                                       br(),
                                       PMID_tab_intro,
                                       bsCollapse(id = 'PMID_collapse', multiple = T,
                                                  bsCollapsePanel('Input', PMID_input_txt, style = 'warning'),
                                                  bsCollapsePanel('Results', PMID_results_txt, style = 'success')
                                       )
                              ),
                              tabPanel("Functional Enrichment: aGOtool",
                                       br(),
                                       Pfam_tab_intro,
                                       bsCollapse(id = 'Domain_collapse', multiple = T,
                                                  bsCollapsePanel('Input', Pfam_input_txt, style = 'warning'),
                                                  bsCollapsePanel('Results', Pfam_results_txt, style = 'success')
                                       )
                              ),
                              tabPanel("Interaction Networks",
                                       br(),
                                       int_network_intro,
                                       bsCollapse(id = 'network_collapse', multiple = T,
                                                  bsCollapsePanel('Protein-Protein (STRING)', string_txt, style = 'warning'),
                                                  bsCollapsePanel('Protein-Chemical (STITCH)', stitch_txt, style = 'success')
                                       )
                              ),
                              tabPanel("Example Files",
                                       br(),
                                       examples
                              ),
                              tabPanel("Available Organisms",
                                       br(),
                                       h3("List of supported organisms"),
                                       div(id = "annotate_redirect_org",
                                           p("You were redirected here from the ", strong("Annotate Documents"), " tab. Select ", strong("Annotate Documents"), " from the left sidebar menu to go back.",
                                             actionLink("dismiss_annot_msg_org", "x", style="float:right;display:inline-block;cursor:pointer;height:20px;width:20px;margin-left: -50%; ;font-weight:bold;text-align:left;font-size:10px !important;color:black !important"), style = 'margin-left: 8px;font-size:18px;'),
                                           style="background-color:#e7f3fe;display:none"),
                                       hr(),
                                       DT::dataTableOutput("org_table")
                                       
                              )
                  )
                )
        ),
        #-About pages-####
        tabItem(tabName = 'about',
                fluidPage(
                  tabsetPanel(id = "about_pages",
                              tabPanel("About",
                                       br(),
                                       About_text
                              ),
                              tabPanel("Privacy Policy",
                                       br(),
                                       privacy_notice
                              )
                    
                    
                  )
                )
        )
      )
    ),
    footer = dashboardFooter(left_text=HTML('<span>© 2021 <a href="https://sites.google.com/site/pavlopoulossite/" target="_blank" style="color:white !important">Bioinformatics and Integrative Biology Lab</a> | <a href="https://www.fleming.gr" target="_blank" style="color:white !important">Biomedical Sciences Research Center "Alexander Fleming"</a></span>')),
    div( id="cookieConsent", span(id="closeCookieConsent",'x'), HTML('This website uses cookies to improve user experience. By using OnTheFly<sup>2.0</sup> you consent to all cookies in accordance with our  privacy policy ('), actionLink('privacy_notice', 'learn more...'), HTML('). <a class="cookieConsentOK">OK</a>'))
    
    
    
  )
)

shinyApp(ui = ui, server = server)

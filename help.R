introduction_tab <- HTML('<div style="font-size:16px">
                          <h3>1. Overview</h3>
                          <p>OnTheFly<sup>2.0</sup> offers a number of tools and functions, accessible through the menu on the left side of the page. The options offered are the following:
                          <ol>
                            <li> <b>Home:</b> The web service\'s Home page.
                            <li> <b>Annotate Files:</b> Upload documents and annotate them using Named Entity Recognition (NER).
                            <li> <b>Create Dataset:</b> Use the bioentities obtained from annotated documents to prepare datasets for analysis.
                            <li> <b>Functional Enrichment:</b> Perform Functional Enrichment Analysis on your dataset. Two different sub-options are given:
                              <ol>
                              <li> <b>Ontologies & Pathways (g:Profiler):</b> Search Gene Ontology, Pathway databases, Tissue Expression and Phenotype Onotology databases with g:Profiler.
                              <li> <b>Domains & Diseases (aGOtool):</b> Search Pfam, InterPro, UniProt and the DISEASES database with aGOtool.
                              </ol>                           
                            </li>
                            <li> <b>Literature Search:</b> Perform scored searches against the literature.
                            <li> <b>Protein Domain Search:</b> Perform scored searches against protein classification databases.
                            <li> <b>Interaction Networks:</b> Create and visualize biological interaction networks. Two different sub-options are given:
                              <ol>
                              <li> <b>Protein - Protein (STRING):</b> Create protein-protein interaction networks by retrieving interactions from STRING.
                              <li> <b>Protein - Chemical (STITCH):</b> Create protein-small molecule interaction networks by retrieving interactions from STITCH.
                              </ol>
                            </li>
                            <li> <b>Help:</b> This Help page.
                            <li> <b>About:</b> Developer credits, contanct information and additional details.
                          </ol>
                          </p>
                          <br><br><br>
                          <h3>2. How to use this help page</h3>
                          <p>Topics in this manual are divided in separate tabs, accessible through header buttons at the top of the page, as shown in the figure below. 
                          Click on any of these header buttons to navigate to its respective tab:</p>
                          <img src="images/help_page/help_0_overview.png" style="border: 1px solid black">
                          <p>
                          In each tab, content is divided into collapsed sections, indicated by colored title bars, as shown in the figure above.  Click on each title to expand or collapse its content.
                          </p>
                         </div>')


Annotation_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;">The <b>Annotation tab</b> consists the principal feature of OnTheFly<sup>2.0</sup>, enabling bioentities extraction and isolation from multiple files in many different formats, as well as mapping of selected terms to their corresponding databases.</h4>')

file_upload_txt <- HTML('<div class="col-md-4">
                          <img src = "images/help_page/help_1_upload_form.png" style="border: 1px solid black">
                          <br>
                          <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 1: </b>The File Upload form</figcaption>
                        </div>
                        <div class="col-md-8">
                        <p>OnTheFly<sup>2.0</sup> provides the option to select and upload <b>multiple files</b> simultaneously and/or write in a text area field <i>(Figure 1)</i>.</p>
                        <h3>1. File Upload</h4>
                        <p>
                        Click the <b>Browse</b> button of the upload form to select and upload one or multiple files. Acceptable file formats currently include: 
                        <ul>
                        <li>PDF (.pdf)</li>
                        <li>Rich Text Format (rtf)</li>
                        <li>Microsoft Word (.doc and .docx)</li>
                        <li>OpenOffice Writer(.odt)</li>
                        <li>Microsoft Excel (.xls and .xlsx)</li>
                        <li>OpenOffice Calc (.ods)</li>
                        <li>Flat text (.txt, .tsv, .csv)</li>
                        <li>Images (.bmp, .png, .jpg, .tif)</li>
                        <li>PostScript (.ps, .eps)</li>
                        </ul>
                        <b>Notes:</b>
                        <ol>
                        <li> The size of each file cannot exceed 10 MB.
                        <li> Images should have a resolution / pixel density of at least 150 ppi/dpi.
                        <li> A maximum of 10 files can be uploaded for each session.
                        </ol></p>
                        <hr>
                                                    <h3>2. Text area field</h4>
                            <p style = "text-align:justify">The text area field forms a basic <b>text input area</b>, enabling the creation of <b>custom text</b> by writing or pasting a section of a text. 
                            By pressing the <b><i>ADD</b></i> button the formed text can be added to the list of files for further analysis, whereas the <b><i>CLEAR</b></i> button can be used to discard the unwanted text area input. Clicking
                            the <b><i>LOAD EXAMPLE</i></b> button will generate an example text in the form.</p>
                        </div>
                        ')


file_management_txt <- HTML('<div class="col-md-12">
                              <div class="col-md-5">
                                <img src = "images/help_page/help_2_manipulate_files.png" style="border: 1px solid black">
                                <br>
                                <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 2.</b> File handling: select, rename and delete.</figcaption>
                              </div>
                              <div class="col-md-7">
                                <h3>1. Select / Rename / Delete</h3>
                                <p style = "text-align:justify">After file submission, a <b>checkbox list</b> will appear, containing all uploaded files and/or submitted texts <i>(Figure 2)</i>. Any additional uploaded or created files are appended to the selection list.
                                <br>
                                Files can be selected and manipulated by clicking the checkboxes next to their names.  One or multiple files can be deleted by selecting them and clicking the <b><i>Delete</b></i> button.  Files can be renamed, by selecting them and clicking the
                                <b><i>Rename</b></i> button. In both cases an dialog box will appear, asking you to rename or delete the selected file.</p>
                              </div>
                            </div>
                            <div class="col-md-12"><hr></div>
                            <div class="col-md-12">
                              <div class="col-md-3">
                                <h3>2. File display</h3>
                                <p style = "text-align:justify;">Upon selection of one or more files from the checkbox list, a reactive tab panel will appear, containing each choice in a separate tab.
                                Every tab in the tab panel is divided into two sub-panels: <i>File</i> and <i>Entities</i> <i>(Figure 3)</i>. 
                                Selected documents are displayed in the <b><i>File</b></i> sub-panel</p>
                                <p style = "text-align: justify;">You can select or deselect a file from the checkbox list and the corresponding tab will be dynamically inserted or removed accordingly.</p>
                              </div>
                              <div class="col-md-9" style="align:center">
                                <img src = "images/help_page/help_3_display_files.png" style="border: 1px solid black">
                                <br>
                                <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 3: </b>Display selected files</figcaption>
                              </div>
                            </div>
                            ')
#It can be formatted to display multiple lines using a scroll bar that will appear as needed, while the height of the field is also adjustable.</p>

file_annotation_txt <- HTML('<div class="col-md-12">
                              <div class="col-md-5">
                                <h3>1. Select Annotation parameters</h3>
                                <p style = "text-align:justify;">OnTheFly<sup>2.0</sup> uses the <b>EXTRACT</b> Named Entity Recognition (NER) service to perform the biological annotation of documents, by highlighting terms of interest and extract identified bioentities:
                                <ol>
                                 <li> Select or deselect <b>at least one</b> out of 14 different <b>entity type(s)</b> from the <b><i>Select entity type(s)</i></b> selection list.  By default, all entity types are selected. 
                                <br>Available <b>entity types</b> currently include: <i>Chemical compound, Organism, Protein, Biological process, Cellular component, Molecular function, Tissue, Disease, ENVO environment, APO phenotype, FYPO phenotype, MPheno phenotype, NBO behavior, Mammalian phenotype.</i>
                                </li>
                                <li> In order for <b>proteins</b> to be identified, you must select an organism. The proteins of the choosen organism(s) will be highlighted in the text. OnTheFly<sup>2.0</sup> currently supports 197 organisms, a list of which can be seen by clicking on the <i>View available organisms</i> link.
                                </li>
                                <li> Click the <b><i>Annotate</i></b> button to begin NER, or the <b><i>Reset</b></i> button to clear any previous annotations and reset the input form to its default values.
                                </li>
                                </ol>
                                </p>
                              </div>
                              <div class="col-md-7">
                                <img src = "images/help_page/help_4_annotation_options.png" style="border: 1px solid black">
                                <br>
                                <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 4: </b>Annotation Parameters</figcaption>
                              </div>
                            </div>
                            <div class="col-md-12"><hr></div>
                            <div class="col-md-12">
                              <div class="col-md-6">
                                <img src = "images/help_page/help_5_annotation_results_doc.png" style="border: 1px solid black">
                                <br>
                                <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 5: </b>Annotation results in the document viewer</figcaption>
                              </div>
                              <div class="col-md-6">
                                <h3>2. Annotation Results - Graphical View</h3>
                                <p style = "text-align: justify">Upon pressing the <b><i>Annotate</b></i> button, the entire displayed document will be tagged and identified bioentities will be highlighted according to the selected parameters.
                                <br>
                                A legend, color-coding each entity term category, is shown above the document viewer.
                                </p>
                                <p style = "text-align: justify;">By hovering the mouse cursor over highlighted terms a pop-up will appear assigning each word to the corresponding <b>type</b>, <b>name</b> and <b>identifier</b> <i>(Figure 5)</i>.</p>
                                <p>A table with the parameters used during annotation is shown below the document viewer.</p>
                              </div>
                            </div>
                            <div class="col-md-12"><hr></div>
                            <div class="col-md-12">
                              <div class="col-md-4">
                                <h3>3. Annotation Results - Extracted Entities</h3>
                                <p style = "text-align:justify;">Extracted bioentities are shown in an interactive table, that can be accessed through the <b>Entities</b> tab of each document <i>(Figure 6)</i>.</p>
                                <p style = "text-align: justify;">The table shows the <b>names</b>, the <b>entity types</b> and the <b>database identifiers</b> of each extracted term. Identifiers for each term are retrieved from the following databases:
                                <ul>
                                <li> Proteins and genes: ENSEMBL
                                <li> Chemical compounds: NCBI PubChem
                                <li> Organisms: NCBI Taxonomy browser
                                <li> Ontology terms (Biol. Process, Mol. Function, Cell Component): EMBL-EBI\'s QuickGO browser for Gene Ontology
                                <li> Tissues: BRENDA Tissue Ontology
                                <li> Diseases: Disease Ontology (DOID)
                                <li> ENVO, APO, FYPO etc. phenotypes: EMBL-EBI Phenotype Ontology
                                </ul>
                                Each identifier is a hyperlink, opening a new browser tab to its page in the relevant database.
                                </p>
                                <p style = "text-align: justify;">The results can be filtered by entity type, using the selection list above the table, or by text search.  The entire table, as well as filtered results, can be downloaded in CSV format.</p>
                              </div>
                              <div class="col-md-8">
                                <img src = "images/help_page/help_6_annotation_results_table.png" style="border: 1px solid black">
                                <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 6: </b>Table of extracted bioentities</figcaption>
                              </div>
                            </div>
                            ')
#Terms are highlighted in accordance with the selected


Dataset_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;"><b>Create Dataset tab</b>, as the name indicates, enables the creation of a dataset for analysis, containing selected bioentities terms of interest, originated from one or multiple previously annotated files.</h4>')

entities_selection_txt <- HTML('<div class="col-md-12">
                                <h3>Select entities and add them to a dataset</h3>
                                <p style = "text-align:justify;">The <b>Create Dataset</b> page contains the following sections <i>(Figure 7)</i>:
                                  <ul>
                                  <li> A <i>side bar panel</i>, containing the list of annotated documents, accompanied by short instructions.
                                  <li> A main panel tab called <i>Annotated Documents</i>. The annotated terms of each document will appear there.
                                  <li> A main panel tab called <i>Dataset</i>. The dataset created by will appear there.
                                  </ul>
                                </p>
                                <img src = "images/help_page/help_7_create_dataset_1.png" style="border: 1px solid black">
                                <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 7: </b>Entity Selection for the creation of a dataset</figcaption>
                                <br>
                                <p style = "text-align: justify;">Annotated documents appear in a checkbox list in the <i>side bar panel</i> of the page. The annotated terms of each selected document appear in the <i>Annotated Documents</i> section of the main portion of the page, under a tab named after the document.</p>
                                <ul>
                                <li>Use the <b>selection menu</b> above to select the documents you wish to analyze.</li>
                                <li>For each document, select one or more proteins and/or chemicals by <b>clicking</b> on them. You can also click the <b>Select All</b> checkbox to select all entities in the table.  When you are ready, click <b>Add to Dataset</b> to add them to a dataset for analysis.</li>
                                <li>Your selected terms will appear in a new panel, marked <b>Dataset</b>.</li>
                                <li>You can do the above for <b>multiple documents</b>, by repeating the same procedure. The produced dataset can include terms from <b>multiple</b> documents.</li>
                                </ul>
                               </div>')


sel_management_txt <- HTML('<div class="col-md-12">
                            <div class="col-md-12">
                            <h3>Manage the dataset</h3>
                            <p style = "text-align: justify;">All the selected entities are collected and displayed in a table in the <b>Dataset</b> panel (Figure 8):</p>
                            </div>
                            <div class="col-md-7">
                            <img src = "images/help_page/help_8_create_dataset_2.png" style="border: 1px solid black">
                            <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 8: </b>The created dataset table</figcaption>
                            </div>
                            <div class="col-md-5">
                            <p>The table displays the identifier, name, entity type and document origin of each term. The latter refers to the document from which each term was extracted. You can filter the table by entity type, using the drop down selection above, or by text search.
                            <br>
                            Single entities can be deleted from the table by hovering the mouse over their row (the row will be colored red and a trash icon will appear) and <i>left-clicking</i>. You can also delete all lines (and empty the dataset) by clicking the <b>Delete All</b> button.
                            <br>
                            The dataset csn be downloaded in CSV, Excel or PDF format by clicking the <b>Download</b> button.
                            <br>
                            To submit your dataset for analysis, click on <b>Functional Enrichment Analysis</b>, <b>Literature Search</b>, <b>Protein Domain Search</b>, <b>Protein-Protein Network</b> or <b>Protein-Chemical Network</b> to add your selected terms to a dataset for Functional Enrichment Analysis, Literature Search, Protein Domain Search, or to create Protein-Protein or Protein-Chemical interaction networks, respectively. 
                            When you are ready, click one of the options on the left-side menu to select an analysis method:
                            <ul>

                                          <li><b>Enrichment: g:Profiler</b> performs functional enrichment analysis with g:Profiler.</li>
                                          <li><b>Enrichment: aGOtool</b> performs functional enrichment analysis with aGOtool.</li>
                                          <li><b>Literature Search</b> searches your selected proteins against the scientific literature.</li>
                                          <li><b>Interaction Network</b> creates protein-protein or protein-chemical interaction networks.  Two choices are given: <b>Protein-Protein</b> for protein-protein networks and <b>Protein-Chemical</b> for protein chemical networks.</li>
                            </ul>                           
                            </p>
                            </div>
                            </div>')


FE_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;">This tab consists of two sub-tabs: (i) <b>Input</b> and (ii) <b>Results</b> and is used to perform <b>functional enrichment analysis with g:Profiler</b> on a selected dataset of extracted terms.</h4>')

FE_input_txt <- HTML('<div class="col-md-12">
                      <h3>Prepare and run functional enrichment analysis</h3>
                      <b>Note:</b> In order to run functional enrichment analysis, you first need to create an input dataset through the <b>Create Dataset</b> menu.</p>
                      <div class="col-md-3">
                      <p>Functional enrichment analysis involves the following options:</p>
                      <ol> 
                      <li> Select organism: select organism for analysis.  A choice among 197 species is given.
                      <li> Select data sources: select databases for enrichments.  Available choices are:
                        <ul>
                        <li> <b>Gene Ontology:</b> Biological Process, Molecular Function and Cellular Component
                        <li> <b>Metabolic Pathways:</b> KEGG, Reactome, WikiPathways
                        <li> <b>Regulatory Motifs:</b> TransFac, miRTarBase
                        <li> <b>Protein Databases:</b> Human Protein Atlas (for <i>H. sapiens</i> only!), CORUM
                        <li> <b>Phenotypes:</b> Human Phenotype Ontology (for <i>H. sapiens</i> only!)
                        </ul>
                      </li>
                      <li> Significance Options: define threshold type and cut-off value:
                        <ul>
                        <li> <b>Threshold Type:</b> Define the type of evaluation threshold (i.e. the correction method for p-value).  Three options are given: g:SCS (the default g:Profiler p-value), Bonferroni and False Discovery Rate (FDR)
                        <li> <b>P-value cut-off:</b> Set the p-value cut-off.  Default value is 0.05 (5%)
                        </ul>
                      </li>
                      <li> Select Protein ID type for analysis: define the ID type that will be used in the analysis, as well as in the output.  Although extracted terms have ENSEMBL IDs, these can be converted to other database types depending on your needs.  By default, Entrez gene names are used.
                      </ol> 
                      </div>
                      <div class="col-md-9">
                      <img src="images/help_page/help_9_FE_input.png" style="border: 1px solid black">
                      <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 9: </b>The Functional Enrichment Analysis input form.</figcaption>
                      <br>
                      <p style="text-align:justify">
                      To perform functional enrichment analysis on your dataset, set the aforementioned input options to the values that best suit you.  Default selected values are <i>Homo sapiens</i> (Human) for species, All Gene Ontology (Biol. Process, Cell Component, Mol. Function) and Metabolic Pathway (KEGG, Reactome, WikiPathways) Databases, the g:SCS p-value type and a 0.05 cut-off, while protein ENSEMBL IDs will be translated to their Entrez gene name equivalents.
                      <br>Click the <b>Analyze Data</b> button to begin.  To reset your dataset, click the <b>Delete All</b> button.
                      </p>
                      </div>
                     </div>')

FE_results_txt <- HTML('<div class="col-md-12">
                        <h3>Enrichment Results: Table</h3>
                        <p>Enrichment results will appear in three sub-panels of the <b>Results</b> tab, <b>Table</b>, <b>Manhattan Plot</b> and <b>Bar plot</b>. In the <b>Table</b> sub-panel, results are shown in table format, both for all enrichment terms, and for each category separately.
                        </p>
                        <div class="col-md-9">
                        <img src = "images/help_page/help_10_FE_results1.png" style = "border: 1px solid black">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 10: </b>Enrichment analysis results in table format.</figcaption>
                        </div>
                        <div class="col-md-3">
                        <p style = "text-align: justify;"> Each results table contains the following columns:
                        <ul>
                        <li><b>Term ID:</b> The unique term identifier. In the table, Term ID is a <b>hyperlink</b> that points to the correspoding data source of the term</li>
                        <li><b>Term Name:</b> the short name of the function</li>
                        <li><b>P-value:</b> hypergeometric p-value after correction for multiple testing</li>
                        <li><b>Term size:</b> number of genes that are annotated to the term</li>
                        <li><b>Query size:</b> number of genes that were included in the query</li>
                        <li><b>No. of Prositive Hits:</b> the number of genes in the input query that are annotated to the corresponding term</li>
                        <li ><b>Positive Hits:</b> a comma separated list of genes from the query that are annotated to the corresponding term</li>
                        </ul>
                        You can filter your results using the text search field, as well as download the table to <b>CSV</b>, <b>Excel</b> and <b>PDF</b> file.</p>
                        </div>
                        </div>
                        <div class="col-md-12"><hr></div>
                        <div class="col-md-12">
                        <h3>Enrichment Results: Manhattan plot</h3>
                        <p style = "text-align: justify;">In addition to the tables, functional enrichment results are also visualized with an interactive <b>Manhattan Plot</b>, in <b>Manhattan Plot</b> sub-panel of the <b>Results</b> tab, graphically depicting the annotated <b>functional terms</b>.
                        The grouping and color-coding of the terms is made according to data sources that are represented in the <b>x-axis</b>. The <b>y-axis</b> shows the adjusted p-values in negative log10 scale (-log10(P-value). The size of each colored circle, which corresponds to one term, depends on the size of this specific term, i.e larger terms have larger circles.</p>
                        <div class="col-md-4">
                        <p style = "text-align: justify;">A wide range of <b>actions</b>, concerning the visualization of the plot, are available, including saving the plot as an image, selecting a single or multiple nodes with the mouse, zoom in/out, pan, selection of a specific area, autoscale etc. These can be accessed by the icons in the menu appearing at the top right of the plot</p>
                        <p>You can select a single node in the plot by left-clicking it.  Alternatively, you can use <b>Box Select</b> or <b>Lasso Select</b> from the plot tools (top right of the graph) to select multiple terms.
                        <br>In either case, selecting one or more nodes in the plot will show their details (ID, Name, P-value etc) in  a table at the bottom of the plot.
                        </p>
                        </div>
                        <div class="col-md-8">
                        <img src = "images/help_page/help_11_FE_results2.png" style = "border: 1px solid black;">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 11: </b>Manhattan plot of Enrichment analysis results.</figcaption>
                        </div>
                        </div>
                        <div class="col-md-12"><hr></div>
                        <div class="col-md-12">
                        <h3>Enrichment Results: Bar plot</h3>  
                        <p>Enrichment results can also be shown in an interactive bar plot, through the <b>Bar Plot</b> sub-panel. In the plot, the x-axis represents the enrichment metric function (either -log10(P-value) or an enrichment score, defined as the % ratio of observed over expected terms). The y-axis shows the terms themselves. 
                        </p>
                        <div class="col-md-9">
                        <img src = "images/help_page/help_12_FE_results3.png" style = "border: 1px solid black;">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 12: </b>Bar plot of Enrichment analysis results.</figcaption>
                        </div>
                        <div class="col-md-3">
                        <p style="text-align:justify">The components of the plot are defined from the plot controls above it.  Three control options are given:
                        <ol>
                        <li> Database: select which database(s) to plot. Multiple selections are available; in this case, each database type is colored differently, with a color index shown at the bottom left of the plot.
                        <li> Enrichment metric: select the metric for the bar lengths.  Available options are -log10(P-value) or Enrichment Score (the % ratio of observed over expected terms).
                        <li> Number of terms in plot: a slider through which you can choose the number of terms (bars) to appear in the plot.  Changing the number of terms will increase or decrease the plot height.
                        </ol>
                        </p>
                        </div>
                        <p style="text-align:justify">The terms depicted in the plot will also appear in table format below the graph.  The number of terms in the table will be the same number of terms as in the graph.  Both in the graph and in the table, the terms will appear sorted with regards to the chosen metric, in decreasing order.
                        <br>The plot is interactive; hovering your mouse over a bar will display its title and metric score. A wide range of <b>actions</b>, concerning the visualization of the plot, are available, including saving the plot as an image, selecting a single or multiple nodes with the mouse, zoom in/out, pan, selection of a specific area, autoscale etc. These can be accessed by the icons in the menu appearing at the top right of the plot.
                        <br>The results can also be downloaded through the table below the plot, in CSV, Excel or PDF format.
                        </p>
                       </div>')



PMID_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;">This tab consists of two sub-tabs: (i) <b>Input</b> and (ii) <b>Results</b> and is used to perform <b>Publication Enrichment</b> on a selected dataset of proteins and genes.</h4>')

PMID_input_txt <- HTML('<div class="col-md-12">
                      <h3>Prepare and run Literature Search</h3>
                      <b>Note:</b> In order to run functional enrichment analysis, you first need to create an input dataset through the <b>Create Dataset</b> menu.</p>
                      <div class="col-md-3">
                      <p>Literature Search involves the following options:</p>
                      <ol> 
                      <li> Select organism: select organism for analysis.  A choice among 197 species is given.
                      <li> Significance Options:  Define cut-off values for p-value and its False Discovery Rate (FDR) correction.
                      <li> Select Protein ID type: define the ID type that will be used in the analysis, as well as in the output.  Although extracted terms have ENSEMBL IDs, these can be converted to other database types depending on your needs.  By default, Entrez gene names are used.
                      </ol> 
                      </div>
                      <div class="col-md-9">
                      <img src="images/help_page/help_13_PMID_input.png" style="border: 1px solid black">
                      <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 13: </b>The Literature Search input form.</figcaption>
                      <br>
                      <p style="text-align:justify">
                      To perform Liteature search analysis on your dataset, set the aforementioned input options to the values that best suit you. 
                      <br>Click the <b>Analyze Data</b> button to begin.  To reset your dataset, click the <b>Delete All</b> button.
                      </p>
                      </div>
                     </div>')

PMID_results_txt <- HTML('<div class="col-md-12">
                        <h3>Search Results: Table</h3>
                        <p>Search results will appear in two sub-panels of the <b>Results</b> tab, <b>Table</b> and <b>Bar plot</b>. In the <b>Table</b> sub-panel, results are shown in table format, both for all enrichment terms, and for each category separately.
                        </p>
                        <div class="col-md-9">
                        <img src = "images/help_page/help_14_PMID_results1.png" style = "border: 1px solid black">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 14: </b>Search results in table format.</figcaption>
                        </div>
                        <div class="col-md-3">
                        <p style = "text-align: justify;"> Each results table contains the following columns:
                        <ul>
                        <li><b>Term ID:</b> The unique term identifier. In the table, Term ID is a <b>hyperlink</b> that points to the correspoding data source of the term</li>
                        <li><b>Term Name:</b> the short name of the function</li>
                        <li><b>P-value:</b>The p-value</li>
                        <li><b>FDR:</b> The FDR correction of the p-balue</li>
                        <li><b>Term size:</b> number of genes that are annotated to the term</li>
                        <li><b>Query size:</b> number of genes that were included in the query</li>
                        <li><b>No. of Prositive Hits:</b> the number of genes in the input query that are annotated to the corresponding term</li>
                        <li ><b>Positive Hits:</b> a comma separated list of genes from the query that are annotated to the corresponding term</li>
                        </ul>
                        You can filter your results using the text search field, as well as download the table to <b>CSV</b>, <b>Excel</b> and <b>PDF</b> file.</p>
                        </div>
                        </div>
                        <div class="col-md-12"><hr></div>
                        <div class="col-md-12">
                        <h3>Search Results: Bar plot</h3>  
                        <p>Search results can also be shown in an interactive bar plot, through the <b>Bar Plot</b> sub-panel. In the plot, the x-axis represents the enrichment metric function (-log10(FDR), -log10(P-value) or an enrichment score, defined as the % ratio of observed over expected terms). The y-axis shows the terms themselves. 
                        </p>
                        <div class="col-md-9">
                        <img src = "images/help_page/help_15_PMID_results2.png" style = "border: 1px solid black;">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 15: </b>Bar plot of search results.</figcaption>
                        </div>
                        <div class="col-md-3">
                        <p style="text-align:justify">The components of the plot are defined from the plot controls above it.  Two control options are given:
                        <ol>
                        <li> Enrichment metric: select the metric for the bar lengths.  Available options are -log10(FDR), -log10(P-value) or Enrichment Score (the % ratio of observed over expected terms).
                        <li> Number of terms in plot: a slider through which you can choose the number of terms (bars) to appear in the plot.  Changing the number of terms will increase or decrease the plot height.
                        </ol>
                        </p>
                        </div>
                        <p style="text-align:justify">The terms depicted in the plot will also appear in table format below the graph.  The number of terms in the table will be the same number of terms as in the graph.  Both in the graph and in the table, the terms will appear sorted with regards to the chosen metric, in decreasing order.
                        <br>The plot is interactive; hovering your mouse over a bar will display its title and metric score. A wide range of <b>actions</b>, concerning the visualization of the plot, are available, including saving the plot as an image, selecting a single or multiple nodes with the mouse, zoom in/out, pan, selection of a specific area, autoscale etc. These can be accessed by the icons in the menu appearing at the top right of the plot.
                        <br>The results can also be downloaded through the table below the plot, in CSV, Excel or PDF format.
                        </p>
                       </div>')


Pfam_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;">This tab consists of two sub-tabs: (i) <b>Input</b> and (ii) <b>Results</b> and is used to perform <b>Functional Enrichment Analysis</b> on a selected dataset of proteins and genes.</h4>')

Pfam_input_txt <- HTML('<div class="col-md-12">
                      <h3>Prepare and run Enrichment Analysis</h3>
                      <b>Note:</b> In order to run enrichment analysis, you first need to create an input dataset through the <b>Create Dataset</b> menu.</p>
                      <div class="col-md-3">
                      <p>Literature Search involves the following options:</p>
                      <ol> 
                      <li> Select organism: select organism for analysis.  A choice among 197 species is given.
                      <li> Select data sources: select databases for search.  Available choices are <b>Pfam</b>, <b>InterPro</b, <b>UniProt Keywords</b> and the <b>DISEASES</b> database (only for <i>H. sapiens</i>). 
                      <li> Significance Options:  Define cut-off values for p-value and its False Discovery Rate (FDR) correction.
                      </ol> 
                      </div>
                      <div class="col-md-9">
                      <img src="images/help_page/help_16_Pfam_input.png" style="border: 1px solid black">
                      <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 16: </b>The input form.</figcaption>
                      <br>
                      <p style="text-align:justify">
                      To perform enrichment analysis on your dataset, set the aforementioned input options to the values that best suit you. 
                      <br>Click the <b>Analyze Data</b> button to begin.  To reset your dataset, click the <b>Delete All</b> button.
                      </p>
                      </div>
                     </div>')

Pfam_results_txt <- HTML('<div class="col-md-12">
                        <h3>Search Results: Table</h3>
                        <p>Search results will appear in two sub-panels of the <b>Results</b> tab, <b>Table</b> and <b>Bar plot</b>. In the <b>Table</b> sub-panel, results are shown in table format, both for all enrichment terms, and for each category separately.
                        </p>
                        <div class="col-md-9">
                        <img src = "images/help_page/help_17_Pfam_results1.png" style = "border: 1px solid black">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 17: </b>Enrichment results in table format.</figcaption>
                        </div>
                        <div class="col-md-3">
                        <p style = "text-align: justify;"> Each results table contains the following columns:
                        <ul>
                        <li><b>Term ID:</b> The unique term identifier. In the table, Term ID is a <b>hyperlink</b> that points to the correspoding data source of the term</li>
                        <li><b>Term Name:</b> the short name of the function</li>
                        <li><b>P-value:</b>The p-value</li>
                        <li><b>FDR:</b> The FDR correction of the p-balue</li>
                        <li><b>Term size:</b> number of genes that are annotated to the term</li>
                        <li><b>Query size:</b> number of genes that were included in the query</li>
                        <li><b>No. of Prositive Hits:</b> the number of genes in the input query that are annotated to the corresponding term</li>
                        <li ><b>Positive Hits:</b> a comma separated list of genes from the query that are annotated to the corresponding term</li>
                        </ul>
                        You can filter your results using the text search field, as well as download the table to <b>CSV</b>, <b>Excel</b> and <b>PDF</b> file.</p>
                        </div>
                        </div>
                        <div class="col-md-12"><hr></div>
                        <div class="col-md-12">
                        <h3>Search Results: Bar plot</h3>  
                        <p>Search results can also be shown in an interactive bar plot, through the <b>Bar Plot</b> sub-panel. In the plot, the x-axis represents the enrichment metric function (-log10(FDR), -log10(P-value) or an enrichment score, defined as the % ratio of observed over expected terms). The y-axis shows the terms themselves. 
                        </p>
                        <div class="col-md-9">
                        <img src = "images/help_page/help_18_Pfam_results2.png" style = "border: 1px solid black;">
                        <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 18: </b>Bar plot of enrichment results.</figcaption>
                        </div>
                        <div class="col-md-3">
                        <p style="text-align:justify">The components of the plot are defined from the plot controls above it.  Three control options are given:
                        <ol>
                        <li> Database: select which database(s) to plot. Multiple selections are available; in this case, each database type is colored differently, with a color index shown at the bottom left of the plot.
                        <li> Enrichment metric: select the metric for the bar lengths.  Available options are -log10(FDR), -log10(P-value) or Enrichment Score (the % ratio of observed over expected terms).
                        <li> Number of terms in plot: a slider through which you can choose the number of terms (bars) to appear in the plot.  Changing the number of terms will increase or decrease the plot height.
                        </ol>
                        </p>
                        </div>
                        <p style="text-align:justify">The terms depicted in the plot will also appear in table format below the graph.  The number of terms in the table will be the same number of terms as in the graph.  Both in the graph and in the table, the terms will appear sorted with regards to the chosen metric, in decreasing order.
                        <br>The plot is interactive; hovering your mouse over a bar will display its title and metric score. A wide range of <b>actions</b>, concerning the visualization of the plot, are available, including saving the plot as an image, selecting a single or multiple nodes with the mouse, zoom in/out, pan, selection of a specific area, autoscale etc. These can be accessed by the icons in the menu appearing at the top right of the plot.
                        <br>The results can also be downloaded through the table below the plot, in CSV, Excel or PDF format.
                        </p>
                       </div>')


int_network_intro <- HTML("<h4 style = 'line-height: 1.5; text-align:justify;'><b>Interaction Networks tab</b> offers a dynamic Protein-Protein and Protein-Chemical <b>network visualization</b> by using the APIs of <i>STRING</i> and <i>STITCH</i> respectively.</h4>")

string_txt <- HTML('<div class="col-md-12">
                    <h3 style = "text-align:center; margin-top:10px;">Network settings</h3>
                    <img src = "images/help_page/help_19_STRING_input.png" style = "border: 1px solid black;">
                    <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 19: </b>Input options.</figcaption>
                    <p style = "text-align: justify;">All the selected entities for <b>Protein-Protein network</b> analysis, originated from the <i>Create dataset</i> tab, are displayed in a datatable in <b>Input</b> sub-tab. The deletion of a <b>specific row</b> by clicking on it, as well as the deletion of the entire dataset by pressing the <b>Delete All</b> button, are both possible.<p>
                    <p style = "text-align: justify;">To create a network, you must choose an organism, define the properties of the network and press the <b>Create Network</b> button. 
                    
                    <hr>
                    
                    <h3>The Interaction Network Viewer</h3>
                    <img src = "images/help_page/help_20_STRING_result.png" style = "border: 1px solid black;">
                    <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 20: </b>The Network Viewer.</figcaption>
                    <p style = "text-align: justify;">The <b>Network Viewer</b> sub-tab is dedicated to the visualization of <b>Protein-Protein associations networks</b>. The network <b>nodes</b>, which are the selected group of proteins, are connected with undirected <b>edges</b>, representing the functional or physical associations.</p>
                    <p style = "text-align: justify;">You can <b>download in TSV file</b> the Protein-Protein interactions of the displayed network, export the network as an <b>image</b> or redirect the network to <b>STRING database</b> for further analysis.</p>
                   </div>')  


stitch_txt <- HTML('<div class="col-md-12">
                    <h3 style = "text-align:center; margin-top:10px;">Network settings</h3>
                    <img src = "images/help_page/help_21_STITCH_input.png" style = "border: 1px solid black;">
                    <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 21: </b>Input options.</figcaption>
                    <p style = "text-align: justify;">All the selected entities for <b>Protein-Chemical network</b> analysis, originated from the <i>Create dataset</i> tab, are displayed in a datatable in <b>Input</b> sub-tab. The deletion of a <b>specific row</b> by clicking on it, as well as the deletion of the entire dataset by pressing the <b>Delete All</b> button, are both possible.<p>
                    <p style = "text-align: justify;">To create a network, you must choose an organism, define the properties of the network and press the <b>Create Network</b> button. 
                    
                    <hr>
                    
                    <h3>The Interaction Network Viewer</h3>
                    <img src = "images/help_page/help_22_STITCH_result.png" style = "border: 1px solid black;">
                    <figcaption style = "font-size:14px" class="figure-caption text-center"><b>Figure 22: </b>The Network Viewer.</figcaption>
                    <p style = "text-align: justify;">The <b>Network Viewer</b> sub-tab is dedicated to the visualization of <b>Protein-Protein associations networks</b>. The network <b>nodes</b>, which are the selected group of proteins, are connected with undirected <b>edges</b>, representing the functional or physical associations.</p>
                    <p style = "text-align: justify;">You can <b>download in TSV file</b> the Protein-Chemical interactions of the displayed network, export the network as an <b>image</b> or redirect the network to <b>STITCH database</b> for further analysis.</p>
                   </div>') 


examples <- HTML('<h4>Example PDF Files:</h4>
                  <li><a href="example_files/pdf_file_1.pdf" download>Example PDF 1</a></li>
                  <li><a href="example_files/pdf_file_2.pdf" download>Example PDF 2</a></li>

                  <h4>Example Office Text (MS Word, OpenOffice, LibreOffice etc) Files:</h4>
                  <li><a href="example_files/msword_example.docx" download>MS Word (*.docx) example</a></li>
                  <li><a href="example_files/openoffice_example.odt" download>OpenOffice/LibreOffice (*.odt) example</a></li>
                  <li><a href="example_files/rtf_example.rtf" download>Rich Text Format (*.rtf) example</a></li>

                  <h4>Example spreadsheet (MS Excel, LibreOffice etc) files:</h4>
                  <li><a href="example_files/openoffice_single_sheet.ods" download>LibreOffice (*.ods) example (1 sheet)</a></li>
                  <li><a href="example_files/excel_multi_sheet.xlsx" download>MS Excel (*.xslx) example (multiple sheets)</a></li>

                  <h4>Example text files: </h4>
                  <li><a href="example_files/example_txt.txt" download>Simple text file (*.txt)</a></li>
                  <li><a href="example_files/example_tab_delimited.tsv" download>Tab delimited text file (*.tsv)</a></li>
                  <li><a href="example_files/example_comma_delimited.tsv" download>Comma delimited text file (*.csv)</a></li>

                  <h4>Example image files:</h4>
                  <li><a href="example_files/image_file_1.jpg" download>Example image 1</a></li>
                  <li><a href="example_files/image_file_2.jpg" download>Example image 2</a></li>
                  <li><a href="example_files/image_file_3.png" download>Example image 3</a></li>
                 ')






ftr <- '<span style="color:white !important"> 2021 <a href="http://bib.fleming.gr" target="_blank" style="color:white !important">Bioinformatics and Integrative Biology Lab</a> | <a href="https://www.fleming.gr" target="_blank" style="color:white !important">Biomedical Sciences Research Center "Alexander Fleming"</a></span>'
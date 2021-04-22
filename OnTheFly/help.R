
Annotation_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;">The <b>Annotation tab</b> consists the principal feature of OnTheFly<sup>2.0</sup>, enabling bioentities extraction and isolation from multiple files in many different formats, as well as mapping of selected terms to their corresponding databases.</h4>')

file_upload_txt <- HTML('<img src = "images/help_page/upload.png" style = "height:375px; float:left; margin-right:20px;">
                        <p style = "margin-top:57px;">OnTheFly<sup>2.0</sup> provides the option to select and upload <b>multiple files</b> simultaneously and/or write in a text area field <i>(Picture 1)</i>. The acceptable file formats include: 
                        <li style = "list-style-type: circle; list-style-position: inside;">PDF (.pdf)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">Microsoft Word (.doc and .docx)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">OpenOffice Writer(.odt)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">Microsoft Excel (.xls, .xlsm and .xlsx)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">OpenOffice Calc (.ods)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">Flat text (.txt, .tsv, .csv)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">Images (.bmp, .png, .jpg, .tif)</li>
                        <li style = "list-style-type: circle; list-style-position: inside;">PostScript (.ps, .eps)</li>
                        <br>The files must not exceed <b>10MB</b> on upload.</br></p>
                        <footer style = "margin-top:68px; font-size:13px; margin-left:80px;"><b>Picture 1: </b>Input file(s)</footer>
                        ')


file_management_txt <- HTML('<img src = "images/help_page/file_handling.png" style = "height:540px; width:540px; float:left; margin-right:20px;">
                            <img src = "images/help_page/display.png" style = "width: 670px; float:right; margin-top:50px; margin-left:20px;">
                            
                            <h3 style = "text-align:center; margin-top:75px;">Text area field</h3>
                            <p style = "text-align:justify">The text area field forms a basic <b>text input area</b>, enabling the creation of <b>custom text</b> by writing or pasting a section of a text. 
                            By pressing the <b><i>ADD</b></i> button the formed text can be added to the list of files for further analysis, whereas the <b><i>CLEAR</b></i> button can be used to discard the unwanted text area input <i>(Picture 2)</i>.</p>
                            <br><hr></br></hr>
                            
                            <h3 style = "text-align:center;">Rename / Delete</h3>
                            <p style = "text-align:justify">Once uploading of file(s) has been completed and/or texts have been created, a <b>checkbox selection list</b> will appear, comprised of the files as options <i>(Picture 2)</i>. Any additional uploaded or created files are appended to the selection list.</p>
                            <p style = "text-align:justify">All files can be selected and deleted simultaneously by clicking the <b><i>Delete</b></i> button, but in order to be renamed, files must be selected individually.
                            By pressing the <b><i>Rename</b></i> button, an input alert dialog will appear, allowing the user to rename the selected file.</p>
                            <br></br>
                            <footer style = "margin-top:3px; font-size:13px; margin-left:85px;"><b>Picture 2: </b>File handling</footer>
                            
                            <h3 style = "float:left; margin-left:188px; margin-top:178px;">File display</h3>
                            <p style = "margin-top:215px; text-align:justify;">Upon selection of one or more files from the checkbox list, a reactive tab panel will appear, containing each choice in a separate tab.</p>
                            <p style = "text-align: justify;">Every tab in the tab panel is divided into two sub-panels: <i>File</i> and <i>Entities</i> <i>(Picture 3)</i>. 
                            Selected documents are displayed in the <b><i>File</b></i> sub-panel</p>
                            <p style = "text-align: justify;">The user can select or deselect a file from the checkbox list and the corresponding tab will be dynamically inserted or removed accordingly.</p>
                            <footer style = "font-size:13px; margin-left:905px;"><b>Picture 3: </b>Display of selected files</footer>
                            ')
#It can be formatted to display multiple lines using a scroll bar that will appear as needed, while the height of the field is also adjustable.</p>

file_annotation_txt <- HTML('<img src = "images/help_page/annotation_param.png" style = "height:425px; float:left; margin-right:20px;">
                            <img src = "images/help_page/annotation.png" style = "width: 667px; float:right; margin-top:50px; margin-left:20px;">

                            <h3 style = "text-align:center; margin-top:75px;">Annotation parameters</h3>
                            <p style = "text-align:justify;"><b>Extract<sup>2.0</sup></b> has been embedded in OnTheFly<sup>2.0</sup> so as to accomplish the annotation of selected documents by highlighting terms of interest and extract identified bioentities.<p>
                            <p style = "text-align:justify;">Notably, the selection of <b>at least one</b> out of the 14 different <b>entity type(s)</b> is a prerequisite for <b><i>Annotate</b></i> button to appear, enabling the annotation of the displayed file.</p>
                            <p style = "text-align:justify;">The <b>entity types</b> include:
                            <i>Chemical compound, Organism, Protein, Biological process, Cellular component, Molecular function, Tissue, Disease, ENVO environment, APO phenotype, FYPO phenotype, MPheno phenotype, NBO behavior, Mammalian phenotype.</i>
                            </p>
                            <p style = "text-align: justify;">In order for <b>proteins</b> to be identified, the user must select at least one out of the 10 <b>organisms</b> of interest provided or/and add another taxon identifier in the text input area <i>(Picture 4)</i>. The proteins of the choosen organism(s) will be highlighted in the text.</p>
                            <p style = "text-align: justify;">The provided <b>organisms</b> are: <i>Human, Mouse, Rat, Cow, D. melanogaster, C. elegans, E.coli, Zea mays, A. thaliana.</i></p>
                            <footer style = "font-size:13px; margin-top:16px; margin-left:149px;"><b>Picture 4: </b>Annotation parameters</footer>

                            <h3 style = "float:left; margin-left:188px; margin-top:240px;">File annotation</h3>
                            <p style = "margin-top:277px; text-align: justify">Upon pressing the <b><i>Annotate</b></i> button, the entire displayed document will be tagged and identified bioentities will be highlighted according to the selected parameters.</p>
                            <p style = "text-align: justify;">By hovering the mouse cursor over highlighted terms a pop-up will appear assigning each word to the corresponding <b>type</b>, <b>name</b> and <b>identifier</b> <i>(Picture 5)</i>.</p>
                            <footer style = "font-size:13px; margin-left:816px;"><b>Picture 5: </b>Annotated file</footer>
                            
                            <img src = "images/help_page/entities_tbl.png" style = "height:425px; float:left; margin-right:20px;">
                            <h3 style = "float:left; margin-left:188px; margin-top:135px;">Extracted entities</h3>
                            <p style = "text-align: justify; margin-top:172px;">Apart from the identification and highlighting of terms in the selected document, extracted bioentities are shown in an interactive table in <b>Entities</b> tab <i>(Picture 6)</i>.</p>
                            <p style = "text-align: justify;">Particularly, the table is consisted of the <b>names</b>, the <b>types</b> and the <b>identifiers</b> of each extracted term, allowing their mapping to the corresponding databases by selecting and clicking a specific identifier.<p>
                            <p style = "text-align: justify;">Both searching by suffix, using the Search field and filtering of the data by type are possible, while also the user can download the displayed table (filtered or not) in csv format.</p>
                            <footer style = "font-size:13px; margin-left:240px; margin-top:53px;"><b>Picture 6: </b>Entities table</footer>
                            ')
#Terms are highlighted in accordance with the selected


Dataset_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;"><b>Create Dataset tab</b>, as the name indicates, enables the creation of a dataset for analysis, containing selected bioentities terms of interest, originated from one or multiple previously annotated files.</h4>')

entities_selection_txt <- HTML('<img src = "images/help_page/entities_selection.png" style = "height:455px; margin-left:115px;">
                                <footer style = "font-size:13px; margin-top:10px; margin-left:470px; margin-bottom:35px;"><b>Picture 7: </b>Selection of identified bioentities</footer>
                                <p style = "text-align: justify;">Similarly to the Annotation tab, a <b>checkbox selection list</b> comprised of the uploaded and/or created documents is available in the sidebarpanel.<p>
                                <p style = "text-align: justify;">Upon selection of all the documents that the user wishes to analyze, a tab panel divided into two sub-panels, <b><i>Entities</b></i> and <b><i>Selections</b></i>, will appear in the right side of the page <i>(Picture 7)</i>.</p> 
                                <p style = "text-align: justify;">The <b>extracted chemical compounds and proteins</b> of each selected file will be visualized in a table format in its own separate tab panel and the user can select one or more of the terms by <b>clicking</b> on the corresponding row.</p>
                               ')


sel_management_txt <- HTML('<img src = "images/help_page/sel_management.png" style = "height:330px; margin-left:85px;">
                            <footer style = "font-size:13px; margin-top:10px; margin-left:460px; margin-bottom:35px;"><b>Picture 8: </b>Entities selection for dataset creation</footer>
                            <p style = "text-align: justify;">All the selected chemical compounds and/or proteins from the Entities sub-panel are collected and displayed in the <b>Selections</b> sub-panel for further analysis.
                            More specifically, the user can create a dataset for both <b>Functional Enrichment</b> analysis and visualization of protein-protein or protein-chemical <b>Interaction Networks</b>, by clicking the corresponding buttons. The <b>Reset Selections</b> button can be used to clear the currently selected data.
                            The aforementioned procedure can be repeated for multiple files, allowing the user to produce dataset(s) consisted of terms from different documents.</p>
                           ')


FE_tab_intro <- HTML('<h4 style = "line-height: 1.5; text-align:justify;">This tab consists of two sub-tabs: (i) <b>Input</b> and (ii) <b>Results</b> and is used to perform <b>functional enrichment analysis</b> on a selected dataset of extracted terms.</h4>')

FE_input_txt <- HTML('<img src = "images/help_page/FE_input.png" style = "height:390px; margin-left:55px;">
                      <footer style = "font-size:13px; margin-top:10px; margin-left:460px; margin-bottom:35px;"><b>Picture 9: </b>Functional Enrichment dataset</footer>
                      <p style = "text-align: justify;">Once the dataset creation for the functional enrichement analysis is accomplished, all the selected entities are presented in a datatable in <b>Input</b> sub-tab. The user can either clear the entire dataset by pressing the <b>Delete All</b> button, or delete <b>specific entities</b> by clicking on the corresponding row.</p>
                      <p style = "text-align: justify;">In order for the analysis to be performed, the user must press the <b>Analyze Data</b> button after choosing between 10 different <b>organisms</b> (Human, Mouse, Rat, Cow, D. melanogaster, C. elegans, E.coli, Zea mays, A. thaliana) and selecting at least one out of the 11 data sources.
                      In addition to <b>Gene Ontology</b> (GO molecular function, GO cellular component, GO biological process), <b>biological pathways</b> from KEGG, Reactome and WikiPathways, <b>miRNA targets</b> from TRANSFAC and miRTarBase, <b>Protein databases</b> (Human Protein Atlas and CORUM), as well as  the <b>Human Phenotype Ontology</b> are also included in the data source selection list.</p>
                     ')

FE_results_txt <- HTML('<h3 style = "text-align:center; margin-top:10px;">Result table</h3>
                        <img src = "images/help_page/FE_table.png" style = "height:575px; margin-left: 110px;">
                        <footer style = "font-size:13px; margin-top:10px; margin-left:475px; margin-bottom:35px;"><b>Picture 10: </b>Functional Enrichment result table</footer>
                        <p style = "text-align: justify;">After selecting the functional enrichment parameters and pressing the <i>Analyze Data</i> button, a datatable of the results will appear in the <b>Table</b> sub-panel of the <b>Results</b> tab. The table contains the following columns: 
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>P-value:</b> hypergeometric p-value after correction for multiple testing</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>Term size:</b> number of genes that are annotated to the term</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>Query size:</b> number of genes that were included in the query</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>No. of Prositive Hits:</b> the number of genes in the input query that are annotated to the corresponding term</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>Term ID:</b> unique term identifier. In the table, Term ID is a <b>hyperlink</b> that points to the correspoding data source of the term</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>Source:</b> the abbreviation of the data source for the term</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>Term Name:</b> the short name of the function</li>
                        <li style = "list-style-type: circle; list-style-position: inside;"><b>Positive Hits:</b> a comma separated list of genes from the query that are annotated to the corresponding term</li>
                        </p>
                        <p style = "text-align: justify;">The user can use the <b>filter</b> to display the selected data source(s), as well as download the table to <b>CSV</b>, <b>Excel</b> and <b>PDF</b> file.</p>
                        <br><hr></br></hr>

                        <h3 style = "text-align:center; margin-top:10px;">Manhattan plot</h3>
                        <img src = "images/help_page/FE_plot.png" style = "height:380px; margin-left:135px;">
                        <footer style = "font-size:13px; margin-top:10px; margin-left:485px; margin-bottom:35px;"><b>Picture 11: </b>Functional Enrichment Manhattan plot</footer>
                        <p style = "text-align: justify;">In addition to the datatable, functional enrichment results are also visualized with an interactive <b>Manhattan Plot</b>, in <b>Manhattan Plot</b> sub-panel of the <b>Results</b> tab, graphically depicting the annotated <b>functional terms</b>.
                        The grouping and color-coding of the terms is made according to data sources that are represented in the <b>x-axis</b>. The <b>y-axis</b> shows the adjusted p-values in negative log10 scale. The size of each colored circle, which corresponds to one term, depends on the size of this specific term, i.e larger terms have larger circles.</p>
                        <p style = "text-align: justify;">A wide range of <b>actions</b>, concerning the visualization of the plot, are available, including zoom in/out, pan, selection of a specific area, autoscale etc.</p>
                       ')

int_network_intro <- HTML("<h4 style = 'line-height: 1.5; text-align:justify;'><b>Interaction Networks tab</b> offers a dynamic Protein-Protein and Protein-Chemical <b>network visualization</b> by using the APIs of <i>STRING</i> and <i>STITCH</i> respectively.</h4>")

string_txt <- HTML('<h3 style = "text-align:center; margin-top:10px;">Network settings</h3>
                    <img src = "images/help_page/STRING_input.png" style = "height:480px; margin-left: 69px;">
                    <footer style = "font-size:13px; margin-top:10px; margin-left:500px; margin-bottom:35px;"><b>Picture 12: </b>Protein-Protein interaction network dataset</footer>
                    <p style = "text-align: justify;">All the selected entities for <b>Protein-Protein network</b> analysis, originated from the <i>Create dataset</i> tab, are displayed in a datatable in <b>Input</b> sub-tab. The deletion of a <b>specific row</b> by clicking on it, as well as the deletion of the entire dataset by pressing the <b>Delete All</b> button, are both possible.<p>
                    <p style = "text-align: justify;">In order for the network to be extracted, the user must choose an organism (Human, Mouse, Rat, Cow, D. melanogaster, C. elegans, E.coli, Zea mays, A. thaliana) and then press the <b>Create Network</b> button. 
                    Basic <b>Network settings</b> are also provided, including the selection of the <b>network type</b>, <b>the meaning of the edges</b> and the <b>confidence score</b>.</p>
                    <br><hr></br></hr>
                    
                    <h3 style = "text-align:center; margin-top:10px;">STRING interaction network</h3>
                    <img src = "images/help_page/STRING_network1.png" style = "height:480px; margin-left:145px;">
                    <footer style = "font-size:13px; margin-top:10px; margin-left:500px; margin-bottom:35px;"><b>Picture 13: </b>STRING interaction network</footer>
                    <p style = "text-align: justify;">The <b>Network Viewer</b> sub-tab is dedicated to the visualization of <b>Protein-Protein associations networks</b>. The network <b>nodes</b>, which are the selected group of proteins, are connected with undirected <b>edges</b>, representing the functional or physical associations.</p>
                    <p style = "text-align: justify;">The network is <b>interactive</b> as nodes can be selected and dragged anywhere on the boxed plane, while clicking on a node results in the emergence of a pop-up window, which contains informations about this particular node. Notably, the selected <b>network parameters</b> from the <i>Input</i> tab are displayed in a panel below the network.</p>
                    <p style = "text-align: justify;">Finally, the user has the option to <b>download in TSV file</b> the Protein-Protein interactions of the displayed network, export the network as an <b>image</b> or redirect the network to <b>STRING database</b> for further analysis.</p>
                   ')  


stitch_txt <- HTML('<h3 style = "text-align:center; margin-top:10px;">Network settings</h3>
                    <img src = "images/help_page/STITCH_input.png" style = "height:480px; margin-left:90px;">
                    <footer style = "font-size:13px; margin-top:10px; margin-left:458px; margin-bottom:35px;"><b>Picture 13: </b>Protein-Chemical interaction network dataset</footer>
                    <p style = "text-align: justify;">Similarly to the <i>Protein-Protein (STRING)</i> tab, all the selected entities for <b>Protein-Chemical network</b> analysis, originated from the <i>Create dataset</i> tab, are displayed in a datatable in <b>Input</b> sub-tab. The user can either clear the entire dataset by pressing the <b>Delete All</b> button, or delete <b>specific entities</b> by clicking on the corresponding row.</p>
                    <p style = "text-align: justify;">Exactly like in the STRING network, in order for the <b>STITCH network</b> to be extracted, the user must choose an organism (Human, Mouse, Rat, Cow, D. melanogaster, C. elegans, E.coli, Zea mays, A. thaliana) and then press the <b>Create Network</b> button. 
                    Basic <b>Network settings</b> are also provided, including the selection of the <b>network type</b>, <b>the meaning of the edges</b> and the <b>confidence score</b>.</p>
                    <br><hr></br></hr>
                    
                    <h3 style = "text-align:center; margin-top:10px;">STITCH interaction network</h3>
                    <img src = "images/help_page/STITCH_network1.png" style = "height:545px; margin-left:156px;">
                    <footer style = "font-size:13px; margin-top:10px; margin-left:480px; margin-bottom:35px;"><b>Picture 14: </b>STITCH interaction network</footer>
                    <p style = "text-align: justify;">The <b>Network Viewer</b> sub-tab is used for visualizing <b>Protein-Chemical associations networks</b>. The network <b>nodes</b>, which represent the selected group of proteins or/and chemicals, are connected with undirected <b>edges</b>, indicating the functional or physical associations.</p>
                    <p style = "text-align: justify;">As in protein-protein interactions network tab, nodes of the network can be selected and dragged anywhere on the boxed plane, while the selected <b>network parameters</b> from the <i>Input</i> tab are displayed in a panel below.</p>
                    <p style = "text-align: justify;">Conclusively, the user has the option to <b>download in TSV file</b> the Protein-Chemical interactions of the displayed network, export the network as an <b>image</b> or redirect the network to <b>STITCH database</b> for further analysis.</p>
                   ')


examples <- HTML('<h4>Example PDF Files:</h4>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/pdf_file_1.pdf" download>Example PDF 1</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/pdf_file_2.pdf" download>Example PDF 2</a></li>

                  <h4>Example Office Text (MS Word, OpenOffice, LibreOffice etc) Files:</h4>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/msword_example.docx" download>MS Word (*.docx) example</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/openoffice_example.odt" download>OpenOffice/LibreOffice (*.odt) example</a></li>

                  <h4>Example spreadsheet (MS Excel, LibreOffice etc) files:</h4>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/openoffice_single_sheet.ods" download>LibreOffice (*.ods) example (1 sheet)</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/excel_multi_sheet.xlsx" download>MS Excel (*.xslx) example (multiple sheets)</a></li>

                  <h4>Example text files: </h4>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/example_txt.txt" download>Simple text file (*.txt)</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/example_tab_delimited.tsv" download>Tab delimited text file (*.tsv)</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/example_comma_delimited.tsv" download>Comma delimited text file (*.csv)</a></li>

                  <h4>Example image files:</h4>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/image_file_1.jpg" download>Example image 1</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/image_file_2.jpg" download>Example image 2</a></li>
                  <li style = "list-style-type: circle; list-style-position: inside;"><a href="example_files/image_file_3.png" download>Example image 3</a></li>
                 ')



ftr <- '<span style="color:white !important"> 2021 <a href="http://bib.fleming.gr" target="_blank" style="color:white !important">Bioinformatics and Integrative Biology Lab</a> | <a href="https://www.fleming.gr" target="_blank" style="color:white !important">Biomedical Sciences Research Center "Alexander Fleming"</a></span>'
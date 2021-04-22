library(shiny)
library(shinyjs)
library(shinythemes)
library(shinydashboard)
library(dashboardthemes)
library(shinycssloaders)
library(shinydashboardPlus)  #### NOTE!!!! Requires version 0.7.5 or older!!!!
library(shinyWidgets)
library(shinyalert)
library(shinyBS)
library(gprofiler2)
library(data.table)
library(stringr)
library(plotly)
library(dplyr)
library(tidyverse)
library(tools) #built-in
library(curl)
library(glue)
library(DT)
library(xml2)
library(httpuv)


Sys.setenv(LD_LIBRARY_PATH = "/usr/lib/libreoffice/program/:$LD_LIBRARY_PATH")

#file size options
options(shiny.maxRequestSize = 10*1024^2) #maximum file size: 10 MB


#globals

#for files
file_names <- list()
file_ids <- list()
global_positions <-list()

#for FE analysis
barplot_table <- data.frame()

#Maximum number of file uploads
max_files = 10




app_title <- "OnTheFly2.0"
file_extensions <- c(".pdf",
                     ".docx", ".doc", 
                     ".odt", ".odx", ".odtx", 
                     ".rtf", ".dot", 
                     ".txt", ".dat", ".csv", "tsv", 
                     ".xls", ".xlsx", ".ods",
                     ".ppt", ".pptx",".odp",
                     ".bmp", ".jpg", ".png",
                     ".tif", ".ps", ".eps"
)

file_plcholder <- 'No files uploaded'
txt_example <- "The epidermal growth factor receptor (EGFR; ErbB-1; HER1 in humans) is a transmembrane protein that is a receptor for members of the epidermal growth factor family (EGF family) of extracellular protein ligands. The epidermal growth factor receptor is a member of the ErbB family of receptors, a subfamily of four closely related receptor tyrosine kinases: EGFR (ErbB-1), HER2/neu (ErbB-2), Her 3 (ErbB-3) and Her 4 (ErbB-4). In many cancer types, mutations affecting EGFR expression or activity could result in cancer."
txt_plcholder <- "Write or paste a text here.\n\nClick the 'Load Example' button to load an example text."
txt_plcholder_updated <- "Write or paste a text here.\n\nClick the 'Load Example' button to load an example text."
file_select_plcholder <- 'No files selected'
org_plcholder <- 'e.g. 8364 (Xenopus tropicalis)'
tbl_select_plcholder <- 'No tables selected'
js_path <- 'iframe.js'
css_path <- 'www/styles.css'
string_source <- 'https://string-db.org/javascript/combined_embedded_network_v2.0.2.js'
BSRC_image_src <- 'https://sites.google.com/site/pavlopoulossite/_/rsrc/1472850252910/work/Fleming_logo.jpg?height=82&width=320'

organismchoice <- c('Homo sapiens (Human)', 
                    'Mus musculus (Mouse)', 
                    'Rattus rattus (Rat)', 
                    'Bos taurus (Cow)', 
                    'Drosophila melanogaster', 
                    'Caenorhabditis elegans',
                    'Saccharomyces cerevisiae', 
                    'Zea mays', 
                    'Arabidopsis thaliana'
)

filterchoices <- c('Chemical compound', 
                   'Organism', 'Protein', 
                   'Biological Process', 
                   'Cellular component', 
                   'Molecular function', 
                   'Tissue', 'Disease', 
                   'ENVO environment', 
                   'APO phenotype', 
                   'FYPO phenotype', 
                   'MPheno phenotype', 
                   'NBO behavior', 
                   'Mammalian phenotype'
)

specifichoices <- c('Chemical compound', 'Protein')

Gene_Ontology <- c('GO biological process',
                   'GO molecular function', 
                   'GO cellular component'
)

Biological_Pathways <- c('KEGG', 'Reactome', 'WikiPathways')

Regulatory_Motifs <- c('TRANSFAC', 'miRTarBase')

Protein_Databases <- c('Human Protein Atlas', 'CORUM')

HP <- list('HP')

source_choices <- list(`Gene Ontology` = Gene_Ontology,
                       `Biological Pathways` = Biological_Pathways,
                       `Regulatory Motifs in DNA` = Regulatory_Motifs,
                       `Protein Database` = Protein_Databases,
                       `Human Phenotype Ontology` = HP
)
FE_id_types <- list('Entrez Gene Name' = 'ENTREZGENE',
                    'Entrez Gene Accession' = 'ENTREZGENE_ACC',
                    'UniProt Accession' = 'UNIPROT_GN_ACC',
                    'UniProt Gene Name' = 'UNIPROT_GN',
                    'EMBL Accession' = 'EMBL',
                    'ENSEMBL Protein ID' = 'ENSP',
                    'ENSEMBL Gene ID' = 'ENSG',
                    'RefSeq mRNA Accession' = 'REFSEQ_MRNA_ACC',
                    'RefSeq Protein Accession' = 'REFSEQ_PEPTIDE_ACC',
                    'RefSeq Non-coding RNA Accession' = 'REFSEQ_NCRNA_ACC'
)


FE_fitler_choices <- list (`GO molecular function (GO:MF)` = 'GO:MF',
                           `GO cellular component (GO:CC)` = 'GO:CC',
                           `GO biological process (GO:BP)` = 'GO:BP',
                           `KEGG` = 'KEGG',
                           `Reactome (REAC)` = 'REAC',
                           `WikiPathways` = 'WP',
                           `TRANSFAC (TF)` = 'TF',
                           `miRTarBase (MIRNA)` = 'MIRNA',
                           `Human Protein Atlas (HPA)` = 'HPA',
                           `CORUM` = 'CORUM',
                           `HP` = 'HP'
)

FE_significance_method <- list( 'g:SCS' = 'gSCS',
                                'False Discovery Rate' = 'fdr',
                                'Bonferroni' = 'bonferroni'
)

FE_cutoff_choices <- list(0.10, 0.09, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02, 0.01)


#NOTE: not all sources are listed, because some need to be programmatically created
FE_hyperlinks <- list("GO:BP" = "https://www.ebi.ac.uk/QuickGO/term/GO:",
                      "GO:MF" = "https://www.ebi.ac.uk/QuickGO/term/GO:",
                      "GO:CC" = "https://www.ebi.ac.uk/QuickGO/term/GO:",
                      "KEGG" = "https://www.genome.jp/kegg-bin/show_pathway?",
                      "REAC" = "https://reactome.org/PathwayBrowser/#/",
                      "CORUM"= "http://mips.helmholtz-muenchen.de/corum/#?complexID=",
                      "HP" = "https://hpo.jax.org/app/browse/term/HP:",
                      "WP" = "https://www.wikipathways.org/index.php/Pathway:"
)


STRING_network_score <- list (`highest confidence (0.900)` = 900,
                              `high confidence (0.700)` = 700,
                              `medium confidence (0.400)` = 400,
                              `low confidence (0.150)` = 150)







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
library(httr)
library(glue)
library(DT)
library(xml2)
library(httpuv)


#use the "install_libraries.R" script to install the above.  Make sure that "shinydahsboardPlus" is at version 0.7.5 or older, otherwise, the tool WILL NOT WORK


#file options.  Change these at will
max_file_size=10 #10 MB (will be entered below in the options)
#Maximum number of file uploads
max_files = 10 #10 files max


#stop editing from here on

#global system paths, gprofiler url, setting filesize computationally
Sys.setenv(LD_LIBRARY_PATH = "/usr/lib/libreoffice/program/:$LD_LIBRARY_PATH")

options(shiny.maxRequestSize = max_file_size*1024^2) #maximum file size: 10 MB




#globals

#for files
file_names <- list()
file_ids <- list()
file_paths <- list()
global_positions <-list()

#for FE analysis
barplot_table <- data.frame()
#for literature search analysis
barplot_table_PMID <-data.frame()
#for domain search analysis
barplot_table_Pfam <-data.frame()






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
txt_example <- "The combined treatment of aspirin and cisplatin suppressed the expression of the anti-apoptotic protein Bcl-2 and the EMT-related proteins, up-regulated the levels of the cleaved PARP and Bax, and blocked the PI3K/AKT and RAF-MEK-ERK signaling pathway. In addition, we demonstrated that the enhanced effect of aspirin on the cisplatin-induced inhibition of tumor cell growth was also mediated through the suppression of the binding activity of NF-κB to the COX-2 promoter. The combination of aspirin and cisplatin effectively attenuated the translocation of NF-κB p65/p50 from the cytoplasm to the nucleus, and abrogated the binding of NF-κB p65/p50 to the COX-2 promoter, thereby down-regulating COX-2 expression and PGE2 synthesis."
txt_plcholder <- "Write or paste a text here.\n\nClick the 'Load Example' button to load an example text."
txt_plcholder_updated <- "Write or paste a text here.\n\nClick the 'Load Example' button to load an example text."
file_select_plcholder <- 'No files selected'
org_plcholder <- 'e.g. 8364 (Xenopus tropicalis)'
tbl_select_plcholder <- 'No tables selected'
js_path <- 'iframe.js'
css_path <- 'www/styles.css'
string_source <- 'https://string-db.org/javascript/combined_embedded_network_v2.0.2.js'
BSRC_image_src <- 'https://sites.google.com/site/pavlopoulossite/_/rsrc/1472850252910/work/Fleming_logo.jpg?height=82&width=320'


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
                    'UniProt (SwissProt/TrEMBL) Accession' = 'UNIPROT_GN_ACC',
                    'UniProt (SwissProt) Accession' = 'UNIPROTSWISSPROT_ACC',
                    'UniProt (TrEMBL) Accession' = 'UNIPROTSPTREMBL_ACC',
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


Pfam_source_choices <- list(
  "PFAM" = -55,
  "INTERPRO" = -54,
  "UniProt" = -51,
  "Disease Ontology" = -26
)


STRING_network_score <- list (`highest confidence (0.900)` = 900,
                              `high confidence (0.700)` = 700,
                              `medium confidence (0.400)` = 400,
                              `low confidence (0.150)` = 150)






#-open organisms csv and create a data frame-####
organisms <- read.csv("./organisms_with_kegg.csv", header = T, sep="\t", stringsAsFactors = F)
organisms$print_name = paste0(sprintf("%s (%s) [NCBI Tax. ID: %s]", organisms$Species_Name, organisms$Common_Name, organisms$Taxonomy_ID))

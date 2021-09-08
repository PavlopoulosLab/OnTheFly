#----Upload files and convert them to html----####
on.upload_new <- function(upload, session){
  image_exts <- c("bmp", "jpg", "png", "tif")
  post_exts <-c("ps", "eps")
  ppt_exts <-c("ppt", "pptx","odp")
  sid=session$token
  if(length(file_ids)<max_files & nrow(upload)<max_files)
  {
    if(length(file_ids)>0)
    {
      chk<-list()
      for (i in 1:length(file_ids))
      {
        pref=strsplit(file_ids[[i]], "[.]")[[1]][1]
        if(pref==sid)
        {
          chk <- append(chk, file_ids[[i]])
        }
        else
        {
          cat(sprintf("%s seems to be from an old session. Will not keep it.\n", file_ids[i]), file=stderr())
        }
      }
      if(length(chk)>0)
      {
        file_ids<-chk
        start <- length(file_ids)
      }
      else
      {
        start=0;
      }
    }
    else
    {
      start=0;
    }
    for (i in 1:nrow(upload)) {
      showModal(modalDialog(span(sprintf('Please wait for file "%s" to be processed...', upload$name[[i]]), style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;'))
      id <- sprintf("%s.%s", sid, as.numeric(Sys.time()))
      
      ext <- file_ext(upload$name[[i]])
      error = 0 #check for errors
      file.copy(upload$datapath[[i]], sprintf('www/tmp/%s.%s', id, ext), overwrite = F);
      if (tolower(ext) == 'pdf') {
        system(sprintf('pdf2htmlEX --process-outline 0 --optimize-text 1 --zoom 1.3 --tounicode 1 --space-as-offset 1 www/tmp/%s.pdf www/tmp/%s.html', id, id))
        system(sprintf("perl -0777 -i -pe 's/<script.*?<.script>//imsg' www/tmp/%s.html", id))
        system(sprintf("bash www/remove_tags.sh www/tmp/%s.html > www/tmp/%s-ed.html", id, id))
        system(sprintf("mv www/tmp/%s-ed.html www/tmp/%s.html", id, id))
        
        
      }
      else if (tolower(ext) == 'txt' || tolower(ext) == 'xml') {
        system(sprintf('libreoffice --convert-to pdf --outdir www/tmp www/tmp/%s.%s', id, ext))
        
        #system(sprintf('unoconv -f pdf www/tmp/%s.txt', id))
        system(sprintf('pdf2htmlEX --process-outline 0 --optimize-text 1 --zoom 1.3 --tounicode 1 --space-as-offset 1 www/tmp/%s.pdf www/tmp/%s.html', id, id))
        system(sprintf("perl -0777 -i -pe 's/<script.*?<.script>//imsg' www/tmp/%s.html", id))
      }
      else if (tolower(ext) %in% image_exts) 
      {#-resample 72
        
        img_info <- strsplit(system(sprintf('identify -format "%%x,%%y,%%w,%%h" www/tmp/%s.%s', id, ext), intern=TRUE), ",")
        spl_x <- strsplit(img_info[[1]][1], " ")
        spl_y <- strsplit(img_info[[1]][1], " ")
        res_x <- as.integer(spl_x[[1]][1])
        res_y <- as.integer(spl_y[[1]][1])
        width <- as.integer(img_info[[1]][3])
        height<- as.integer(img_info[[1]][4])
        print(img_info)
        #-density 300 -units PixelsPerInch
        
        if( res_x <150 | res_y <150)
        {
          error = 1
          sendSweetAlert(
            session = session,
            title = sprintf('Please upload an image with a resolution / density of at least 150 dpi.'),
          )
        }
        else  { #-density 600
          system(sprintf("convert -units PixelsPerInch -size %dx%d -alpha off www/tmp/%s.%s www/tmp/%s.png", width,height, id, ext, id))
          cat(sprintf("Perform OCR operation...\n"), file=stderr())
          system(sprintf("ocrmypdf --output-type pdf --remove-vectors --threshold --force-ocr www/tmp/%s.png www/tmp/%s-OCR.pdf", id, id))
          system(sprintf('pdf2htmlEX --process-outline 0 --optimize-text 1 --zoom 5 --tounicode 1 --space-as-offset 1 www/tmp/%s-OCR.pdf www/tmp/%s.html', id, id))
          system(sprintf("perl -0777 -i -pe 's/<script.*?<.script>//imsg' www/tmp/%s.html", id)) 
          system(sprintf("bash www/remove_tags.sh www/tmp/%s.html > www/tmp/%s-ed.html", id, id))
          system(sprintf("mv www/tmp/%s-ed.html www/tmp/%s.html", id, id)) 
        }
      }
      else if (tolower(ext) %in% post_exts)
      {
        system(sprintf("ps2pdf www/tmp/%s.%s www/tmp/%s.pdf", id, ext, id))
        cat(sprintf("ps2pdf www/tmp/%s.%s www/tmp/%s.pdf \n", id, ext, id), file=stderr())
        Sys.sleep(10)
        system(sprintf("ocrmypdf --output-type pdf --remove-vectors --threshold --force-ocr www/tmp/%s.pdf www/tmp/%s-OCR.pdf", id, id))
        system(sprintf('pdf2htmlEX --process-outline 0 --optimize-text 1 --zoom 5 --tounicode 1 --space-as-offset 1 www/tmp/%s-OCR.pdf www/tmp/%s.html', id, id))
        system(sprintf("perl -0777 -i -pe 's/<script.*?<.script>//imsg' www/tmp/%s.html", id)) 
        system(sprintf("bash www/remove_tags.sh www/tmp/%s.html > www/tmp/%s-ed.html", id, id))
        system(sprintf("mv www/tmp/%s-ed.html www/tmp/%s.html", id, id))
      }
      else if (tolower(ext) %in% ppt_exts)
      {
        system(sprintf('libreoffice --convert-to pdf --outdir www/tmp www/tmp/%s.%s', id, ext))
        system(sprintf("ocrmypdf --output-type pdf --remove-vectors --threshold --force-ocr www/tmp/%s.pdf www/tmp/%s-OCR.pdf", id, id))
        system(sprintf('pdf2htmlEX --process-outline 0 --optimize-text 1 --zoom 1.3 --tounicode 1 --space-as-offset 1 www/tmp/%s-OCR.pdf www/tmp/%s.html', id, id))
        system(sprintf("perl -0777 -i -pe 's/<script.*?<.script>//imsg' www/tmp/%s.html", id)) 
        system(sprintf("bash www/remove_tags.sh www/tmp/%s.html > www/tmp/%s-ed.html", id, id))
        system(sprintf("mv www/tmp/%s-ed.html www/tmp/%s.html", id, id))
      }
      else {
        system(sprintf('libreoffice --convert-to html --outdir www/tmp www/tmp/%s.%s', id, ext))
      }
      if(error != 1)
      {
        file_ids<<-append(toString(id), file_ids)
        file_names<<-append(upload$name[[i]], file_names)
        file_paths<<-append(sprintf("tmp/%s.html", id), file_paths)
      }
    }
  }
  else
  {
    error = 1
    sendSweetAlert(
      session = session,
      title = sprintf('Maximum number of uploaded files reached.'),
      text="You cannot have more than 10 uploaded files at the same time."
    )
  }
}





#----Save the textInput in a file and convert it to html----####
txt.file_new <- function (textinput, session) {
  sid=session$token
  
  if(length(file_ids)>0)
  {
    chk<-list()
    for (i in 1:length(file_ids))
    {
      pref=strsplit(file_ids[[i]], "[.]")[[1]][1]
      if(pref==sid)
      {
        chk <- append(file_ids[[i]], chk)
      }
      else
      {
        cat(sprintf("%s seems to be from an old session. Will not keep it\n", file_ids[[i]]), file=stderr())
      }
    }
    if(length(chk)>0)
    {
      file_ids<-chk
      start <- length(file_ids)
    }
    else
    {
      start=0;
    }
  }
  else
  {
    start=0;
  }
  
  
  if(length(file_ids)<max_files)
  {
    if (textinput != "") {
      
      showModal(modalDialog(span('Please wait for the text to be processed', style='color:lightseagreen'), footer = NULL, style = 'font-size:20px; text-align:center;'))
      
      timeid=as.numeric(Sys.time())
      id <- sprintf("%s.%s", sid, timeid)
      conn <- file(sprintf('www/tmp/%s.txt', toString(id)) )
      writeLines(textinput, conn)
      close(conn)
      system(sprintf('libreoffice --convert-to pdf --outdir www/tmp www/tmp/%s.txt', id))
      system(sprintf('pdf2htmlEX --process-outline 0 --optimize-text 1 --zoom 1.3 www/tmp/%s.pdf www/tmp/%s.html', id, id))
      system(sprintf("perl -0777 -i -pe 's/<script.*?<.script>//imsg' www/tmp/%s.html", id))
      
      file_ids<<-append(toString(id), file_ids)
      file_names<<-append(sprintf('custom_text-%s', toString(timeid)), file_names)
      file_paths<<-append(sprintf("tmp/%s.html", id), file_paths)
    }
  }
  else
  {
    error = 1
    sendSweetAlert(
      session = session,
      title = sprintf('Maximum number of uploaded files reached.'),
      text="You cannot have more than 10 uploaded files at the same time."
    )
  }
}




##-remove file(s)-####
file.remove <- function (select, file_names, file_ids) {
  positions <- which(file_ids %in% select)
  if (!identical(positions, integer(0))){
    file_names <<- file_names[-positions]
    file_ids<<-file_ids[-positions]
  }
}




names.tolist <- function (file_names_old) {
  return (lapply(reactiveValuesToList(file_names), function(x) {
    if (!is.null(x)) {
      return (x);
    }
  }))
}


ids.tolist <- function (file_ids_old) {
  return (lapply(reactiveValuesToList(file_ids_old), function(x) {
    if (!is.null(x)) {
      return (x);
    }
  }))
}


#----Show-Hide annotation options----####
show_hide_options <- function (input_id, id, box_id, session) {
  count <- input_id
  if (count %% 2 != 0) {
    shinyjs::hide(box_id)
    updateActionButton(session, id, icon = icon('angle-down'))
  }
  else {
    shinyjs::show(box_id)
    updateActionButton(session, id, icon = icon('angle-up'))
  }
}


#----Save requested entities in csv and display in table----####
csv.entities <- function (entities) {
  csv <- entities[[1]]
  #csv2 <- entities[[1]]
  
  
  if(csv != '') {
    html_id_list=str_split(entities[[2]], "/", simplify = TRUE)
    htmlid <- gsub(".html", "", html_id_list[length(html_id_list)]);
    id <- htmlid
    index <- which(file_ids==id)
    name <- file_names[[index]]
    write.table(csv, sprintf('www/tmp/%s_entities.csv', id), sep=',', quote = FALSE, col.names = F, row.names = F)
    fcsv <- read.csv(sprintf('www/tmp/%s_entities.csv', id), header = F, sep = ',' , stringsAsFactors=FALSE)
    
    uniq_df=data.frame(matrix(ncol=5))
    ent_seen_ids<-c()
    for (i in 1:nrow(fcsv))
    {
      if(fcsv$V3[i] %in% ent_seen_ids)
      {
        uniq_df$X1[grepl(fcsv$V3[i], uniq_df$X3)] <- sprintf("%s, %s", uniq_df$X1[grepl(fcsv$V3[i], uniq_df$X3)], fcsv$V1[i])
      }
      else
      {
        uniq_df[nrow(uniq_df) + 1,] = c(as.character(fcsv$V1[i]), as.character(fcsv$V2[i]), as.character(fcsv$V3[i]), as.character(name),"")
        ent_seen_ids<-append(ent_seen_ids, fcsv$V3[i])
      }
    }
    uniq_df <- na.omit(uniq_df)
    rownames(uniq_df)<-NULL

    csv <- fcsv
    csv2 <- uniq_df
    
    
    names(csv)[1] <- 'Name'
    names(csv)[2] <- 'Type'
    names(csv)[3] <- 'Identifier'
    
    names(csv2)[1] <- 'Name'
    names(csv2)[2] <- 'Type'
    names(csv2)[3] <- 'Identifier'
    names(csv2)[4] <- 'Document'
    names(csv2)[5] <- "D"
    setcolorder(csv2, c('Identifier', 'Type', 'Name', 'Document','D'))
    
    csv$Type <- as.character(csv$Type)
    csv <- csv[(csv$Type != '-3'), ]
    csv$Type[grep("^-", csv$Type, invert = T)] <- 'Protein'
    csv$Type[csv$Type == "-1"] <- 'Chemical compound'
    csv$Type[csv$Type == "-2"] <- 'Organism'
    csv$Type[csv$Type == "-21"] <- 'Biological Process'
    csv$Type[csv$Type == "-22"] <- 'Cellular component'
    csv$Type[csv$Type == "-23"] <- 'Molecular function'
    csv$Type[csv$Type == "-25"] <- 'Tissue'
    csv$Type[csv$Type == "-26"] <- 'Disease'
    csv$Type[csv$Type == "-27"] <- 'ENVO environment'
    csv$Type[csv$Type == "-28"] <- 'APO phenotype'
    csv$Type[csv$Type == "-29"] <- 'FYPO phenotype'
    csv$Type[csv$Type == "-30"] <- 'MPheno phenotype'
    csv$Type[csv$Type == "-31"] <- 'NBO behavior'
    csv$Type[csv$Type == "-36"] <- 'Mammalian phenotype'
    
    csv2$Type <- as.character(csv2$Type)
    csv2 <- csv2[(csv2$Type != '-3'), ]
    csv2$Type[grep("^-", csv2$Type, invert = T)] <- 'Protein'
    csv2$Type[csv2$Type == "-1"] <- 'Chemical compound'
    csv2$Type[csv2$Type == "-2"] <- 'Organism'
    csv2$Type[csv2$Type == "-21"] <- 'Biological Process'
    csv2$Type[csv2$Type == "-22"] <- 'Cellular component'
    csv2$Type[csv2$Type == "-23"] <- 'Molecular function'
    csv2$Type[csv2$Type == "-25"] <- 'Tissue'
    csv2$Type[csv2$Type == "-26"] <- 'Disease'
    csv2$Type[csv2$Type == "-27"] <- 'ENVO environment'
    csv2$Type[csv2$Type == "-28"] <- 'APO phenotype'
    csv2$Type[csv2$Type == "-29"] <- 'FYPO phenotype'
    csv2$Type[csv2$Type == "-30"] <- 'MPheno phenotype'
    csv2$Type[csv2$Type == "-31"] <- 'NBO behavior'
    csv2$Type[csv2$Type == "-36"] <- 'Mammalian phenotype'
    
    CIDs <- substring(csv$Identifier[grep("^CIDs", csv$Identifier)], 5)
    BTO <- substring(csv$Identifier[grep("^BTO", csv$Identifier)], 5)
    DOID <- substring(csv$Identifier[grep("^DOID", csv$Identifier)], 6)
    APO <- substring(csv$Identifier[grep("^APO", csv$Identifier)], 5)
    FYPO <- substring(csv$Identifier[grep("^FYPO", csv$Identifier)], 6)
    PR <- substring(csv$Identifier[grep("^PR", csv$Identifier)], 4)
    NBO <- substring(csv$Identifier[grep("^NBO", csv$Identifier)], 5)
    
    exp_vec <- c("^CIDs", "^[[:digit:]]+", "^GO",
                 "^BTO", "^DOID", "^ENVO",
                 "^APO", "^FYPO", "^PR",
                 "^NBO", "^MP", "^ENS", "^FBpp")
    
    link_vec <- list(
      paste0("<a href='", sprintf('https://pubchem.ncbi.nlm.nih.gov/compound/%s', CIDs), "' target = '_blank'>", csv$Identifier[grep("^CIDs", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=%s', csv$Identifier[grep("^[[:digit:]]+", csv$Identifier)]), "' target = '_blank'>", csv$Identifier[grep("^[[:digit:]]+", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/QuickGO/GTerm?id=%s', csv$Identifier[grep("^GO", csv$Identifier)]), "' target = '_blank'>", csv$Identifier[grep("^GO", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.brenda-enzymes.org/ontology.php?f[id_tree][type]=&f[id_tree][value]=&parent_ids_string=&ontology_id=3&f[term][type]=2&f[term][value]=&f[definition][type]=2&f[definition][value]=&f[id][type]=2&f[id][value]=%s&f[tissue_link][type]=1&f[tissue_link][value]=1', BTO), "' target = '_blank'>", csv$Identifier[grep("^BTO", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/ols/search?q=%s&ontology=doid', DOID), "' target = '_blank'>", csv$Identifier[grep("^DOID", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/ols/search?q=%s&ontology=envo', csv$Identifier[grep("^ENVO", csv$Identifier)]), "' target = '_blank'>", csv$Identifier[grep("^ENVO", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/ols/ontologies/apo/terms?iri=http%3A%2F%2Fpurl.obolibrary.org%2Fobo%2FAPO_%s', APO), "' target = '_blank'>", csv$Identifier[grep("^APO", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/ols/ontologies/fypo/terms?iri=http%3A%2F%2Fpurl.obolibrary.org%2Fobo%2FFYPO_%S', FYPO), "' target = '_blank'>", csv$Identifier[grep("^FYPO", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/ols/ontologies/mp/terms?iri=http%3A%2F%2Fpurl.obolibrary.org%2Fobo%2FPR_%S', PR), "' target = '_blank'>", csv$Identifier[grep("^PR", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ebi.ac.uk/ols/ontologies/nbo/terms?iri=http%3A%2F%2Fpurl.obolibrary.org%2Fobo%2FNBO_%S', NBO), "' target = '_blank'>", csv$Identifier[grep("^NBO", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('http://www.informatics.jax.org/vocab/mp_ontology/%s', csv$Identifier[grep("^MP", csv$Identifier)]), "' target = '_blank'>", csv$Identifier[grep("^MP", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('https://www.ensembl.org/id/%s', csv$Identifier[grep("^ENS", csv$Identifier)]), "' target = '_blank'>", csv$Identifier[grep("^ENS", csv$Identifier)], "</a>"),
      paste0("<a href='", sprintf('http://ensemblgenomes.org/id/%s', csv$Identifier[grep("^FBpp", csv$Identifier)]), "' target = '_blank'>", csv$Identifier[grep("^FBpp", csv$Identifier)], "</a>"))
    csv$Identifier <- src.link(csv$Type, csv$Identifier, exp_vec, link_vec)
    
    #write.table(csv, sprintf('www/tmp/%s_processed.csv', id), sep=',', quote = FALSE, col.names = T, row.names = F)
    #write.table(csv2, sprintf('www/tmp/%s_processed.csv', id), sep=',', quote = FALSE, col.names = T, row.names = F)
    
    return(list(htmlid, csv, csv2))
  }
}

#----Create Identifiers' links----####
src.link <- function (type, identifier, exps, links) {
  not_ens <- grep("^ENS", identifier, invert = T)
  not_fbpp <- grep("^FBpp", identifier, invert = T)
  inter <- intersect(not_ens, not_fbpp)
  for (i in inter) {
    if (type[i] == 'Protein') {
      identifier[i] <- paste0("<a href='", sprintf('https://www.ncbi.nlm.nih.gov/protein/%s', identifier[i]), "' target = '_blank'>", identifier[i], "</a>")
    }
  }
  for (i in 1:length(exps)) {
    exp = exps[i]
    identifier[grep(exp, identifier)] <- unlist(links[i])
  }
  return (identifier)
}

#----Save selected identifiers in csv----####
on.selection <- function (input_row_selected, react_df, selected.values, all_sel_ids) {
  rows_selected <- input_row_selected
  selected.values <- react_df %>% filter(row_number() %in% rows_selected) 
  unlist(selected.values)
  all_sel_ids$dt <- rbind(all_sel_ids$dt, selected.values)
  all_sel_ids$dt <- unique(all_sel_ids$dt)
}









###Functional Enrichment ANalysis methods--####



#-Create Functional enrichment results table with DT --####
create_FE_table <- function(datatable) {
  
  
  out <- DT::renderDataTable(server = F, {
    
    
    datatable(datatable,
              rownames = F,
              escape = F,
              extensions = c('Responsive', 'RowGroup', 'Buttons'),
              options = list(
                autoWidth = T,
                rowGroup = list(dataSrc = 0), #group results according to source column
                dom = 'Bfrtip', #B=button, f=filtering, r=processing, t=table, i=information, p=pagination controls, l = number of entries per page
                buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download")),
                columnDefs = list(list(visible=F, targets=c(0,8,9))
                                  )
              ),
              selection = 'none',
    )
  })
  return(out)
}

#--create TransFac URL-####
create_transfac_url <- function(tf_id){
  #requires the packages: curl, stringr
  
  search_tf <- tf_id  #  for example, "M04140"
  
  #create handle for POST request to a form
  tf_handle <-new_handle()
  #POST form data
  handle_setform(tf_handle,
                 STATUS="SECOND",
                 SEARCH_TERM=search_tf,
                 CASE="no",
                 TABLE_NAME="factor",
                 TABLE_FIELD="ALL",
                 HITSPERPAGE="20",
                 NEXTHITS="0"
  )
  #perform CURL POST request and load into memory
  req <-curl_fetch_memory("http://factor.genexplain.com/cgi-bin/transfac_factor/search.cgi", handle = tf_handle)
  #convert response content to ascii
  html = rawToChar(req$content)
  #perform pattern matching and store resulting ID into a variable called tf_actual_id
  c<-str_match(html, 'getTF\\.cgi\\?AC=(\\S+)"')
  tf_actual_id <- c[[2]]
  #generate TF address
  tf_url <- sprintf("http://factor.genexplain.com/cgi-bin/transfac_factor/getTF.cgi?AC=%s", tf_actual_id)
  return(tf_url)
}

#-enrichment ratio calculation--####
enrich_score <- function(intersection_size, term_size){
  intersection_size <- as.numeric(as.character(intersection_size))
  term_size <- as.numeric(as.character(term_size))
  score <- round((intersection_size/term_size) * 100, 2)
  return(score)
}

#-barplot functions--####

#-the main barplot function-##
handleBarPlot <- function(DB_source, sliderBarplot, barplotMode, from_barPlotSelect, output, session){
  data_table <- barplot_table
  
  if (!identical(DB_source, "")){
    gostres_m <- data_table
    gostres_m <- gostres_m[0,]
    for (i in 1:length(DB_source)) 
    {
      gostres_m<- rbind(gostres_m, data_table[grepl(DB_source[[i]],data_table$Source),])
    }
    
    if (nrow(gostres_m>0)) 
    {
      if (from_barPlotSelect) {
        if(nrow(gostres_m)>=10)
        {
          sval=10
        }
        else
        {
          sval=nrow(gostres_m)
        }
        updateSliderInput(session, "sliderBarplot", max = nrow(gostres_m), value =sval)
      }
      
      # Check mode of execution
      if(barplotMode == "-log10(P-value)"){
        gostres_sort <- gostres_m[order(gostres_m[["-log10(P-value)"]], decreasing = T),]
        drawBarplot(gostres_sort, "P_VALUES BARPLOT", DB_source, sliderBarplot, output)
        tbl_out <- gostres_sort[, c(1,2,3,4,9,5,6,7,8)]
        
      }
      else { # Enrichment Mode
        gostres_sort <- gostres_m[order(gostres_m[["Enrichment Score"]], decreasing = T),]
        drawBarplot(gostres_sort, "ENRICHMENT SCORE", DB_source, sliderBarplot, output)
        tbl_out <- gostres_sort[, c(1,2,3,4,10,5,6,7,8)]
        
      }
      output$barplot_table <- DT::renderDataTable(head(tbl_out, sliderBarplot), server = FALSE, 
                                                  extensions = c('Responsive', 'RowGroup', 'Buttons'),
                                                  options = list(
                                                    dom = 'Bfrtip', 
                                                    buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download"))
                                                  ),rownames= FALSE, escape=F)
    }
  }
}

#-drawing barplot functions--####
# This function creates the respective barplot for -logpvalue or enrichment score
# The height is variable and depends on the  slider input
drawBarplot<- function(dframe, mode, DB_source, sliderBarplot, output){ 
  bar_colors <- list('GO:MF'= c("#dc3912","black"),
                     'GO:BP'= c("#ff9900","black"),
                     'GO:CC' = c("#109618","black"),
                     'KEGG' = c("#dd4477","black"),
                     'REAC' = c("#3366cc", "white"), 
                     'WP' = c("#0099c6", "black"),
                     'TF' = c("#5574a6", "white"),
                     'MIRNA' = c("#22aa99", "black"),
                     'HPA' = c("#6633cc", "white"),
                     'CORUM' = c("#66aa00", "black"), 
                     'HP' = c("#990099", "white")
  )
  if (mode == "P_VALUES BARPLOT") 
  {
    score="-log10(P-value)"
  } 
  else 
  { # ENRICHMENT SCORE BARPLOT
    score="Enrichment Score"
  }
  
  if(sliderBarplot>nrow(dframe))
  {
    sliderBarplot <- nrow(dframe)
  }
  
  ax <- as.numeric(unlist(dframe[[score]][1:sliderBarplot]))
  ay <- as.character(unlist(dframe[["Term Name"]][1:sliderBarplot]))
  asource <- as.character(unlist(dframe[["Source"]][1:sliderBarplot]))
  colors<-c()
  for (i in 1:sliderBarplot)
  {
    colors[i]<-bar_colors[asource[i]][[1]][1]
  }
  data <- data.frame(ax, ay, asource, colors, stringsAsFactors = FALSE) #color,
  data$ay <- factor(data$ay, levels = unique(data$ay)[order(data$ax, decreasing = F)])
  par(las=1) # make label text perpendicular to axis
  par(mar=c(5, 30, 2, 10)) # increase y-axis margin.
  bar <- plot_ly(data, x = ~ax, y = ~ay, type = 'bar', marker=list(color=data$colors), orientation="h") %>% layout(title = paste(mode, ": ", DB_source, sep = "" ), xaxis = list(title = score), yaxis=list(title=""))
  #, color=I(~color)

  pdf(NULL) #this prevents plot_ly from automatically writing a local PDF file with the plot
  output$barplot1 <- renderPlotly({bar})
  
  #make a figure legend based on DB_source
  fig_legend = "<table style='border-spacing: 0;border-collapse: collapse;'><tr><td><b>Colors:&nbsp;&nbsp;</b></td>"
  for(i in 1:length(DB_source))
  {
    fig_legend<-paste(fig_legend, sprintf("<td style='background-color:%s; color:%s;border: 1px solid black'>&nbsp; %s &nbsp;</td>", bar_colors[DB_source[i]][[1]][1], bar_colors[DB_source[i]][[1]][2], DB_source[i]), sep="")
  }
  fig_legend<-paste(fig_legend, "</tr></table>")
  output$bar_legend<- renderUI(HTML(fig_legend))
  
  output$barplot <- renderUI({
    plotlyOutput("barplot1", height = height_barplot(sliderBarplot))
  })
  dev.off() # closes the device.  This solves the "too many open devices" bug
}


# This function calculates the height of the barplot plot. The height is variable and depends on the value of slider
# @param num_entries: integer value of slider, with number of entries to print
# @return height: total calculated pixels to be assigned to div height
height_barplot<-function(num_entries){
  height <- paste( ((num_entries*20) + 100), "px", sep="")
  return(height)
}


#-Manhattan plot functionality----####
# This function receives the clicked element from the Manhattan plot and prints a table with a single line
# containing the gprofiler result row below
handleManhattanClick <- function(output){
  currentTermID <-  event_data("plotly_click")$key #, source = "A"
  
  table_man <- barplot_table[grepl(currentTermID, barplot_table[["Term ID"]]), ] 
  output$manhattan_table <- DT::renderDataTable(table_man, server = FALSE,
                                                extensions = 'Responsive',
                                                options = list(
                                                  pageLength = 11,
                                                  dom = 't'
                                                ), rownames= FALSE, escape = FALSE
  )
}
handleManhattanSelect <- function(output){
  currentTermIDs <-  event_data("plotly_selected")$key #, source = "A"
  table_man <- barplot_table
  table_man <- table_man[0,]
  for (i in 1:length(currentTermIDs))
  {
    table_man[nrow(table_man) + 1,] <- barplot_table[grepl(currentTermIDs[i], barplot_table[["Term ID"]]), ]
  }
  output$manhattan_table <- DT::renderDataTable(table_man, server = FALSE,
                                                extensions = 'Responsive',
                                                options = list(
                                                  pageLength = 11,
                                                  dom = 'Brftip',
                                                  buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download")),
                                                  columnDefs = list(list(visible=F, targets=c(8,9)))
                                                ), rownames= FALSE, escape = FALSE
  )
}


# Literature Search styling methods-####

####-----create literature results table-####
create_literature_table <- function(datatable) {
  
  
  out <- DT::renderDataTable(server = F, {
    datatable(datatable,
              rownames = F,
              escape = F,
              extensions = c('Responsive', 'RowGroup' , 'Buttons'),
              options = list(
                autoWidth = F,
                rowGroup = list(dataSrc = 0), #group results according to source column
                dom = 'Bfrtip', #B=button, f=filtering, r=processing, t=table, i=information, p=pagination controls, l = number of entries per page
                buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download")),
                columnDefs = list(list(visible=F, targets=c(0,9,10,11)))
              ),
              selection = 'none',
    )
  })
  return(out)
}

#-literature search: the main barplot function-##
handleBarPlot_PMID <- function(DB_source, sliderBarplot, barplotMode, from_barPlotSelect, output, session){
  data_table <- barplot_table_PMID
  
  if (!identical(DB_source, "")){
    pmid_m <- data_table
    pmid_m <- pmid_m[0,]
    for (i in 1:length(DB_source)) 
    {
      result= data_table[grepl(DB_source[[i]],data_table[["Source"]]),]
      if(nrow(result)>0)
      {
        pmid_m<- rbind(pmid_m, result)
      }
    }
    if(nrow(pmid_m)>0)
    {
      if (from_barPlotSelect) {
        if(nrow(pmid_m)>=10)
        {
          sval=10
        }
        else
        {
          sval=nrow(pmid_m)
        }
        updateSliderInput(session, "sliderBarplot_PMID", max = nrow(pmid_m), value =sval)
      }
      
      # Check mode of execution
      if(barplotMode == "-log10(P-value)"){
        pmid_sort <- pmid_m[order(pmid_m[["-log10(P-value)"]], decreasing = T),]
        drawBarplot_PMID(pmid_sort, "P_VALUES BARPLOT", DB_source, sliderBarplot, output)
        tbl_out <- pmid_sort[, c(1,2,3,4,5,10,6,7,8,9)]
        
      }
      else if (barplotMode == "-log10(FDR)")
      {
        pmid_sort <- pmid_m[order(pmid_m[["-log10(FDR)"]], decreasing = T),]
        drawBarplot_PMID(pmid_sort, "FDR BARPLOT", DB_source, sliderBarplot, output)
        tbl_out <- pmid_sort[, c(1,2,3,4,5,11,6,7,8,9)]      
      }
      else { # Enrichment Mode
        pmid_sort <- pmid_m[order(pmid_m[["Enrichment Score"]], decreasing = T),]
        drawBarplot_PMID(pmid_sort, "ENRICHMENT SCORE", DB_source, sliderBarplot, output)
        tbl_out <- pmid_sort[, c(1,2,3,4,5,12,6,7,8,9)]
        
      }
      output$barplot_table_PMID <- DT::renderDataTable(head(tbl_out, sliderBarplot), server = FALSE, 
                                                       extensions = c('Responsive', 'RowGroup', 'Buttons'),
                                                       options = list(
                                                         dom = 'Bfrtip', 
                                                         buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download"))
                                                       ),rownames= FALSE, escape=F)
    }
  }
}

#-PMID drawing barplot functions--####
# This function creates the respective barplot for -logpvalue or enrichment score
# The height is variable and depends on the  slider input
drawBarplot_PMID<- function(dframe, mode, DB_source, sliderBarplot, output){ 
  bar_colors <- list('PubMed' = c("#3366cc", "white")
  )
  
  if (mode == "P_VALUES BARPLOT") 
  {
    score="-log10(P-value)"
  } 
  else if(mode=="FDR BARPLOT")
  {
    score="-log10(FDR)"
  }
  else 
  { # ENRICHMENT SCORE BARPLOT
    score="Enrichment Score"
  }
  
  
  if(sliderBarplot>nrow(dframe))
  {
    sliderBarplot <- nrow(dframe)
  }
  ax <- as.numeric(unlist(dframe[[score]][1:sliderBarplot]))
  ay <- as.character(unlist(dframe[["ID"]][1:sliderBarplot]))
  asource <- as.character(unlist(dframe[["Source"]][1:sliderBarplot]))
  colors<-c()
  for (i in 1:sliderBarplot)
  {
    colors[i]<-bar_colors[asource[i]][[1]][1]
  }
  data <- data.frame(ax, ay, asource, colors, stringsAsFactors = FALSE) #color,
  data$ay <- factor(data$ay, levels = unique(data$ay)[order(data$ax, decreasing = F)])
  par(las=1) # make label text perpendicular to axis
  par(mar=c(5, 30, 2, 10)) # increase y-axis margin.
  bar <- plot_ly(data, x = ~ax, y = ~ay, type = 'bar', marker=list(color=data$colors), orientation="h") %>% layout(title = paste(mode, ": ", DB_source, sep = "" ), xaxis = list(title = score), yaxis=list(title=""))
  #, color=I(~color)
  pdf(NULL) #this prevents plot_ly from automatically writing a local PDF file with the plot
  output$barplot1_PMID <- renderPlotly({bar})
  
  #make a figure legend based on DB_source
  fig_legend = "<table style='border-spacing: 0;border-collapse: collapse;'><tr><td><b>Colors:&nbsp;&nbsp;</b></td>"
  for(i in 1:length(DB_source))
  {
    fig_legend<-paste(fig_legend, sprintf("<td style='background-color:%s; color:%s;border: 1px solid black'>&nbsp; %s &nbsp;</td>", bar_colors[DB_source[i]][[1]][1], bar_colors[DB_source[i]][[1]][2], DB_source[i]), sep="")
  }
  fig_legend<-paste(fig_legend, "</tr></table>")
  output$bar_legend_PMID<- renderUI(HTML(fig_legend))
  
  output$barplot_PMID <- renderUI({
    plotlyOutput("barplot1_PMID", height = height_barplot(sliderBarplot))
  })
  dev.off()
}



#### FE aGO functions-####
#-FE aGO: the main barplot function-##
handleBarPlot_Pfam <- function(DB_source, sliderBarplot, barplotMode, from_barPlotSelect, output, session){
  data_table<-data.frame()
  data_table <- barplot_table_Pfam
  if (!identical(DB_source, "")){
    pmid_m <- data.frame()
    #pmid_m <- pmid_m[0,]
    for (i in 1:length(DB_source)) 
    {
      result<- data_table[grepl(DB_source[[i]],data_table[["Source"]]),]
      if(nrow(result)>0)
      {
        pmid_m<- rbind(pmid_m, result)
      }
    }
    pmid_m <- na.omit(pmid_m)
    rownames(pmid_m)<-NULL
    if(nrow(pmid_m)>0)
    {
      if (from_barPlotSelect== T) {
        updateSliderInput(session, "sliderBarplot_Pfam", value = 0, step = 1)
        if(nrow(pmid_m)>=10)
        {
          sval <- 10
        }
        else
        {
          sval <- nrow(pmid_m)
        }
        updateSliderInput(session, "sliderBarplot_Pfam", min = 1, max = nrow(pmid_m), value = sval, step = 1)
      }
      # Check mode of execution
      if(barplotMode == "-log10(P-value)"){
        pmid_sort <- pmid_m[order(pmid_m[["-log10(P-value)"]], decreasing = T),]
        drawBarplot_Pfam(pmid_sort, "P_VALUES BARPLOT", DB_source, sliderBarplot, output)
        tbl_out <- pmid_sort[, c(1,2,3,4,5,10,6,7,8,9)]
        
      }
      else if (barplotMode == "-log10(FDR)")
      {
        pmid_sort <- pmid_m[order(pmid_m[["-log10(FDR)"]], decreasing = T),]
        drawBarplot_Pfam(pmid_sort, "FDR BARPLOT", DB_source, sliderBarplot, output)
        tbl_out <- pmid_sort[, c(1,2,3,4,5,11,6,7,8,9)]      
      }
      else { # Enrichment Mode
        pmid_sort <- pmid_m[order(pmid_m[["Enrichment Score"]], decreasing = T),]
        drawBarplot_Pfam(pmid_sort, "ENRICHMENT SCORE", DB_source, sliderBarplot, output)
        tbl_out <- pmid_sort[, c(1,2,3,4,5,12,6,7,8,9)]
        
      }
      output$barplot_table_Pfam <- DT::renderDataTable(head(tbl_out, sliderBarplot), server = FALSE, 
                                                       extensions = c('Responsive', 'RowGroup', 'Buttons'),
                                                       options = list(
                                                         dom = 'Bfrtip', 
                                                         buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download"))
                                                       ),rownames= FALSE, escape=F)
    }
  }
}

#-FE aGO drawing barplot functions--####
# This function creates the respective barplot for -logpvalue or enrichment score
# The height is variable and depends on the  slider input
drawBarplot_Pfam <- function(dframe, mode, DB_source, sliderBarplot, output){ 
  bar_colors <- list('UniProt keywords' = c("#0099c6", "black"),
                     'PFAM (Protein FAMilies)' = c("#66aa00", "black"), 
                     'INTERPRO' = c("#990099", "white"),
                     'UniProt' = c("#0099c6", "black"),
                     'PFAM' = c("#66aa00", "black"),
                     'Disease Ontology' = c("#ff9900", "black")
  )
  
  if (mode == "P_VALUES BARPLOT") 
  {
    score="-log10(P-value)"
  } 
  else if(mode=="FDR BARPLOT")
  {
    score="-log10(FDR)"
  }
  else 
  { # ENRICHMENT SCORE BARPLOT
    score="Enrichment Score"
  }
  
  if(sliderBarplot>nrow(dframe))
  {
    sliderBarplot <- nrow(dframe)
  }
  
  ax <- as.numeric(unlist(dframe[[score]][1:sliderBarplot]))
  ay <- as.character(unlist(dframe[["Title"]][1:sliderBarplot]))
  asource <- as.character(unlist(dframe[["Source"]][1:sliderBarplot]))
  colors<-c()
  for (i in 1:sliderBarplot)
  {
    colors[i]<-bar_colors[asource[i]][[1]][1]
  }
  data <- data.frame(ax, ay, asource, colors, stringsAsFactors = FALSE) #color,
  data$ay <- factor(data$ay, levels = unique(data$ay)[order(data$ax, decreasing = F)])
  par(las=1) # make label text perpendicular to axis
  par(mar=c(5, 30, 2, 10)) # increase y-axis margin.
  bar <- plot_ly(data, x = ~ax, y = ~ay, type = 'bar', marker=list(color=data$colors), orientation="h") %>% layout(title = paste(mode, ": ", DB_source, sep = "" ), xaxis = list(title = score), yaxis=list(title=""))
  #, color=I(~color)
  pdf(NULL) #this prevents plot_ly from automatically writing a local PDF file with the plot
  output$barplot1_Pfam <- renderPlotly({bar})
  
  #make a figure legend based on DB_source
  fig_legend = "<table style='border-spacing: 0;border-collapse: collapse;'><tr><td><b>Colors:&nbsp;&nbsp;</b></td>"
  for(i in 1:length(DB_source))
  {
    fig_legend<-paste(fig_legend, sprintf("<td style='background-color:%s; color:%s;border: 1px solid black'>&nbsp; %s &nbsp;</td>", bar_colors[DB_source[i]][[1]][1], bar_colors[DB_source[i]][[1]][2], DB_source[i]), sep="")
  }
  fig_legend<-paste(fig_legend, "</tr></table>")
  output$bar_legend_Pfam<- renderUI(HTML(fig_legend))
  
  output$barplot_Pfam <- renderUI({
    plotlyOutput("barplot1_Pfam", height = height_barplot(sliderBarplot))
  })
  dev.off()
}


## STRING and STITCH Styling functions -####


##Method to create legend for the network viewer-####

create_network_legend <- function(network_type, edge_meaning) {
  
  if (tolower(network_type) =="string")
  {
    table_nodes="<table>
    <tr><td><img src='images/string_icons/node_known_structure.png' /></td><td>Proteins with known 3D structure (experimental or predicted)</td></tr>
    <tr><td><img src='images/string_icons/node_unknown_structure_string.png' /></td><td>Proteins with unknown 3D structure</td></tr>
    </table>
    "
  }
  else
  {
    table_nodes="<table>
    <tr><td><img src='images/string_icons/node_known_structure.png' /></td><td>Proteins with known 3D structure (experimental or predicted)</td></tr>
    <tr><td><img src='images/string_icons/node_unknown_structure_stitch.png' /></td><td>Proteins with unknown 3D structure</td></tr>
    <tr><td><img src='images/string_icons/node_chemical.png' /></td><td>Chemical compounds</td></tr>
    </table>
    "    
  }
  
  if(tolower(edge_meaning) == "evidence")
  {
    table_edges="<table style='width:70%'>
    <th colspan=6>Known Interactions</th>
    <tr>
    <td style='width:5%'><img src='images/string_icons/edge_experiment.png' ></td><td style='width:20%'>Experimentally determined</td>
    <td style='width:5%'><img src='images/string_icons/edge_curated_database.png' ></td><td style='width:20%'>From curated databases</td>
    <td></td>
    </tr>
    <th colspan=6>Computationally inferred from gene analysis</th>
    <tr>
    <td style='width:5%'><img src='images/string_icons/edge_gene_neighborhood.png' ></td><td style='width:20%'>Gene neighborhood</td>
    <td style='width:5%'><img src='images/string_icons/edge_gene_fusions.png' ></td><td style='width:20%'>Gene fusions</td>
    <td style='width:5%'><img src='images/string_icons/edge_gene_coocurrence.png' ></td><td style='width:20%'>Gene co-occurrence</td>
    </tr>
    <th colspan=6>Computationally inferred from other sources</th>
    <tr>
    <td style='width:5%'><img src='images/string_icons/edge_textmining.png' ></td><td style='width:20%'>Text mining</td>
    <td style='width:5%'><img src='images/string_icons/edge_coexpression.png' ></td><td style='width:20%'>Co-expression</td>
    <td style='width:5%'><img src='images/string_icons/edge_homology.png' ></td><td style='width:20%'>Protein homology</td>
    </tr>
    </table>
    "
    
  }
  else if (tolower(edge_meaning=="confidence"))
  {
    table_edges="<table style='width:60%'>
    <th colspan=4>Confidence levels</th>
    <tr>
    <td style='width:8%'><img src='images/string_icons/edge_confidence_low.png' ></td><td>Low confidence (>=0.150) </td>
    <td style='width:8%'><img src='images/string_icons/edge_confidence_medium.png' ></td><td>Medium confidence (>=0.400) </td>
    </tr>
    <tr>
    <td style='width:8%'><img src='images/string_icons/edge_confidence_high.png' ></td><td>High confidence (>=0.700) </td>
    <td style='width:8%'><img src='images/string_icons/edge_confidence_highest.png' ></td><td>Highest confidence (>=0.900) </td>
    </tr>
    </table>
    "
    
  }
  else if (tolower(edge_meaning=="actions"))
  {
    table_edges="<table>
    <th colspan=8>Action Types</th>
    <tr>
    <td style='width:5%'><img src='images/string_icons/edge_action_activation.png' ></td><td>Protein activation</td>
    <td style='width:5%'><img src='images/string_icons/edge_action_binding.png' ></td><td>Ligand binding</td>
    <td style='width:5%'><img src='images/string_icons/edge_action_catalysis.png' ></td><td>Enzyme catalysis</td>
    <td style='width:5%'><img src='images/string_icons/edge_action_inhibition.png' ></td><td>Protein inhibition</td>
    </tr>
    <tr>
    <td style='width:5%'><img src='images/string_icons/edge_action_phenotype.png' ></td><td>Phenotype</td>
    <td style='width:5%'><img src='images/string_icons/edge_action_PTM.png' ></td><td>Post-transl. modification</td>
    <td style='width:5%'><img src='images/string_icons/edge_action_reaction.png' ></td><td>Chemical reaction</td>
    <td style='width:5%'><img src='images/string_icons/edge_action_expression_regulation.png' ></td><td>Transcriptional regulation<td></td>
    </tr>
    <th colspan=8>Action Effects</th>
    <tr>
    <td style='width:5%'><img src='images/string_icons/edge_effect_positive.png' ></td><td>Positive</td>
    <td style='width:5%'><img src='images/string_icons/edge_effect_negative.png' ></td><td>Negative</td>
    <td style='width:5%'><img src='images/string_icons/edge_effect_unspecified.png' ></td><td>Unspecified</td>
    <td style='width:5%'></td>
    </tr>
    </table>
    "
  }
  else
  {
    table_edges="<p>Edge thickness represents the extent of <b>binding affinity</b>.</p>"
  }
  legend <-renderUI({
    
    fluidRow(
      column(4,
             div(
               h5(strong("Nodes:")),
               HTML(table_nodes)
             )
      ),
      column(8,
             div(
               h5(strong("Edges:")),
               HTML(table_edges)
             )
      )
    )
  })
  
  
  return(legend)
  
}


# 
# #-Create Table of Available organisms-####
table_of_organisms <- function(){
  organisms_html <- organisms[, c(1,2,3,4,5)]
  
  organisms_html$Taxonomy_ID <- paste0("<a href='https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=", organisms_html$Taxonomy_ID, "' target='_blank'>", organisms_html$Taxonomy_ID, "</a>")
  organisms_html$Species_Name <- paste0("<i>", organisms_html$Species_Name,"</i>")
  for (i in 1:nrow(organisms_html))
  {
    if(organisms_html$KEGG[i]!="NAN" && is.integer(organisms_html$KEGG[i])==F)
    {
      kg= organisms_html$KEGG[i]
      organisms_html$KEGG[i] <- sprintf("<a href='https://www.genome.jp/kegg-bin/show_organism?org=%s' target='_blank'>%s</a>", kg, kg)
    }
    else
    {
      organisms_html$KEGG[i] <- "Not Available"
    }
  }
  
  table_html <- DT::renderDataTable(organisms_html, server = F,
                      colnames = c("Taxonomy ID", "Species Name", "Common Name", "g:Profiler ID", "KEGG Code"),
                      extensions = c('Buttons'),
                      options = list(
                        dom = 'Bfrti', 
                        buttons = list(list(extend='collection', buttons=c('csv', 'excel', 'pdf'), text="Download")),
                        paging=F, scrollY="500px", scroller=T
                      ),rownames= T, escape=F)
  return(table_html)
}


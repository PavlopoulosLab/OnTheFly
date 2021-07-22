#step 0 set Default repository for automated download
local({r <- getOption("repos")
       r["CRAN"] <- "http://cran.r-project.org" 
       options(repos=r)
})

#step1 check if devtools is available. If not, install it, and load it with required
if("devtools" %in% rownames(installed.packages()))
{
  require(devtools)
} else {
  install.packages("devtools")
  require(devtools)
}

#step2 check if these libraries are available and if not, install them
libraries <- c("shiny", "shinyjs", "shinythemes", "shinydashboard", "dashboardthemes",
  "shinycssloaders", "shinyWidgets", "shinyalert", "shinyBS", "gprofiler2",
  "data.table", "stringr", "plotly", "dplyr", "tidyverse", "curl", "glue",
  "DT", "xml2", "httpuv", "httr")

for (i in 1:length(libraries))
{
  if (libraries[i] %in% rownames(installed.packages()))
      {
        print(sprintf("%s is already installed.", libraries[i]))
  }
  else
  {
    install.packages(libraries[i])
  }
}

#step3 check if shinydashboardPlus is installed and if not, install version 0.7.5 with devtools
if("shinydashboardPlus" %in% rownames(installed.packages()))
{
  if(packageVersion("shinydashboardPlus")=="0.7.5")
  {
    print("shinydashboardPlus 0.7.5 is already installed.")
  }
  else {
    remove.packages("shinydashboardPlus")
    packageurl <- "https://cran.r-project.org/src/contrib/Archive/shinydashboardPlus/shinydashboardPlus_0.7.5.tar.gz"
    install.packages(packageurl, repos=NULL, type="source")
  }
} else {
  packageurl <- "https://cran.r-project.org/src/contrib/Archive/shinydashboardPlus/shinydashboardPlus_0.7.5.tar.gz"
  install.packages(packageurl, repos=NULL, type="source")
  
}

### 2022-07-21:
- Fixed a bug that prevented the processing of images with ocrmypdf versions newer than 9.6.xx.
- Changed all calls to the EXTRACT API to HTTPS instead of HTTP.
- The web server version of OnTheFly is now served over HTTPS with SSL/TLS encryption and has a new url, https://bib.fleming.gr:8084/app/onthefly.  The original links have been configured to redirect to the new address.

### 2022-01-19:
- OnTheFly now has a Docker repository, found at: https://hub.docker.com/r/pavlopouloslab/onthefly

### 2021-10-07:
- The OnTheFly2.0 paper has been published in Nucleic Acids Research Genomics and Bioinformatics!!!!!  The reference to the paper has been added to the OnTheFly2.0 GUI.
- Fixed the title and text in the STITCH "Connection Error" message to properly reference STITCH, instead of STRING.

### 2021-09-15:
- KEGG recently changed its API in the visualization of pathways, with regards to how genes/proteins are highlighted and colored. We have updated OnTheFly to reflect these changes.

### 2021-09-08:
- Added a new tab in the "Help" panel, called "Version History". This tab presents a change log (this text), detailing all changes and updates implemented in OnTheFly2.0.
- Added support for XML documents. XML files are now read natively, and parsed successfully. However, their visualization is rather plain, without any syntax highlighting for the XML tags.
- Publication enrichment now returns the full reference for each paper (Authors, year, title, journal, volume, issue and pages information).
- As part of the above, OnTheFly2.0 now also requires the installation and use of the "jsonlite" library for local use. The library has been added in the "install_libraries.R" script and in the GitHub README.md file.
- In addition, the Publication enrichment results table can now be sorted based on publication year, through a new column named "Publication year".
- Improved the status checks in all HTTP requests, to fix crashes caused by complications in the user's DNS settings (exceeding timeouts, failure to resolve domain names etc).


### 2021-07-22:
- Added status checks in all HTTP requests (g:Profiler, aGOtool, STRING and STITCH). Now, if a web service is unavailable or returns errors, an informative message appears and the tool no longer crashes.
- Added code to set the default repository in "install_libraries.R". This way, the script can be run "as-is" through Rscript without having to manually set the CRAN mirror.
- Cleaned up ui.R, server.R and global.R from obsolete (commented out) code.
- Reverted g:Profiler to its default Ensembl version, as the "missing" GO associations for mouse, rat etc re-emerged in the latest Ensembl update.
- Corrected a few typos in README.md.

### 2021-05-31:
- Re-wrote the API requests used in the STRING and STITCH networks
- Corrected the name of one of the authors in README.md, ui.R and about.R
- Configured g:Profiler to use Ensembl version 102, until version 104 is released (Ensembl 103 has some errors, and it is missing GO data for mouse, rat, and a number of other organisms)

### 2021-05-13:
- OnTheFly2.0 is LIVE! A downloadable version can be found in https://github.com/PavlopoulosLab/OnTheFly.  The web server is accessible through http://bib.fleming.gr:3838/OnTheFly/ or http://onthefly.pavlopouloslab.info.

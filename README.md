# OnTheFly<sup>2.0</sup>

A text-mining web application for automated named entity recognition, document annotation, network and functional enrichment analysis 

----

## Table of Contents

1 [Overview](#overview)

2 [Requirements](#requirements)
  * [System Requirements](#system-requirements)
  * [List of required R libraries](#list-of-required-r-libraries)

3 [Installation Instructions](#installation-instructions)
  * [On Linux](#on-linux)
  * [On Windows](#on-windows)
    + [Pure WSL installation](#pure-wsl-installation)
	+ [Hybrid Windows and WSL installation](#hybrid-windows-and-wsl-installation)
  * [Run using Docker](#run-using-docker)

4 [Advanced configuration operations](#advanced-configuration-operations)
 - [Change file size and number limitations](#change-file-size-and-number-limitations)
 - [Deploy using shiny-server](#deploy-using-shiny-server)

----
## Overview
OnTheFly<sup>2.0</sup>  is a web application to aid users collecting biological information from documents. 
With OnTheFly<sup>2.0</sup>  one is able to:  
-   Extract bioentities from individual articles in formats such as plain text, Microsoft Word, Excel and PDF files.
-   Scan images and identify terms by using Optical Character Recognition (OCR).
-   Handle multiple files simultaneously.
-   Isolate proteins, chemical compounds, organisms, tissues, diseases/phenotypes and gene ontology terms.
-   Extract selected terms along with their identifiers in databases.
-   Perform functional enrichment analysis on a selected group of terms.
-   Generate and visualize protein-protein and protein-chemical interaction networks.

Online version: http://bib.fleming.gr:3838/OnTheFly/, http://onthefly.pavlopouloslab.info

**Publication:** Baltoumas, F.A., Zafeiropoulou, S., Karatzas, E., Paragkamian, S., Thanati, F., Iliopoulos, I., Eliopoulos, A.G.,  Schneider, R., Jensen, L.J., Pafilis, E., Pavlopoulos, G.A. (2021) **OnTheFly<sup>2.0</sup>: a text-mining web application for automated biomedical entity recognition, document annotation, network and functional enrichment analysis**. NAR Genomics and Bioinformatics, 2021, Vol. 3, No. 4. doi: [10.1093/nargab/lqab090](https://doi.org/10.1093/nargab/lqab090)

----
## Requirements
### System requirements

- Operating System: Linux (any distribution), Windows with WSL (Windows Subsystem for Linux) or another Unix-like compatibility layer (e.g. Cygwin)
- [R](https://www.r-project.org/) version >= 3.6.1
- [R-studio](https://www.rstudio.com/)  | **Note:** If **not** installed, the **shiny-server** R package is required for deployment
- [poppler](https://poppler.freedesktop.org/) (specifically, the poppler-utils and poppler-data packages)
- [LibreOffice](https://www.libreoffice.org/get-help/install-howto/linux/) and the [unoconv](https://github.com/unoconv/unoconv) utility
- [Tesseract](https://github.com/tesseract-ocr/tesseract) (OCR scanning), the associated english and math training data ([tessdata](https://github.com/tesseract-ocr/tessdata) or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)) and the [OCRMyPDF](https://ocrmypdf.readthedocs.io/en/latest/) wrapper
- [ImageMagick](https://imagemagick.org/index.php) and [Ghostscript](https://www.ghostscript.com/)
- [curl](https://curl.se/), [libcurl](https://curl.se/libcurl/) and [libcurl4-openssl-dev](https://pkgs.org/download/libcurl4-openssl-dev) (required for the installation of the curl library in R)
- [pdf2htmlEX](https://pdf2htmlex.github.io/pdf2htmlEX/)

**Note: 1** Almost all of the above can be installed through your Linux distribution's  package manager (apt, zypper etc).  **An installation bash script ("install_dependencies.sh") is offered to automate setup in Debian and Debian-based (Ubuntu, Mint, etc) distributions**.  In Windows, users need to either install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and [set-up a Linux distribution](https://www.microsoft.com/en-us/search/shop/apps?q=Linux) or use a compatibility layer like [Cygwin](https://www.cygwin.com/).  However, Cygwin users will need to manually compile all the required packages by source.

**Note: 2** If you perform a **manual** installation of these packages, make sure **you install pdf2htmlEX last**.  This is because pdf2htmlEX depends on a number of pre-requisites (namely, poppler and a number of libraries for images that are automatically installed alongside ImageMagick and Ghostscript) to achieve full compatibility with all potential PDF encodings that exist.

### List of required R libraries
- Shiny
- (optional) Shiny-server (required if **R-studio** is **not** installed)
- ShinyBS
- ShinyJS
- ShinyThemes
- ShinyDashboard
- dashboardThemes
- shinydashboardPlus **version 0.7.5** (**Note**: newer versions cause errors due to a bug that still hasn't been resolved in the package)
- ShinyCSSLoaders
- ShinyWidgets
- ShinyAlert
- ShinyBS
- gProfiler2
- data.table
- stringr
- Plotly
- dplyr
- tidyverse
- curl
- httr
- glue
- DT
- XML
- xml2
- httpuv
- jsonlite

**Note:** Packages can be installed through R or R-studio. **An installation script ("install_libraries.R") is included to automate the process of installing the above**.

----

## Installation Instructions

### On Linux
Linux is the native environment OnTheFly<sup>2.0</sup> is designed to operate in.  The main steps that need to be followed are:
1. Install R and R-studio
2. Install all software dependencies (pdf2htmlEX, libreoffice etc)
3. Install all required R libraries
4. Open the tool's project file (OnTheFly.rproj) in R-studio, select **ui.R**, **server.R** or **global.R** and click "Run App" **or** (alternatively), configure shiny-server and setup OnTherFly as a web service.

To aid you in installing and configuring OnTheFly<sup>2.0</sup>, we provide two installation scripts, "install_dependencies.sh" and "install_libraries.R". 

1. The first script ("install_dependencies.sh") installs and configures all required software in your Linux distribution.  The file provided is written for Debian and Debian-based (Ubuntu, LinuxMint etc) and can be run as follows:

>     sudo bash install_dependencies.sh

or

>     chmod +x install_dependencies.sh
>     sudo ./install_dependencies.sh

**Note 1:** To run this script, you **will** need an account with administrative ("sudo") privileges.  If you are working on a system without sudo access, please consult your system administrator.
**Note 2:** Users of non-debian Linux distributions, like SUSE, Fedora, Arch etc, should edit this script and replace "apt-get" with the analogous package manager of their system (e.g. "zypper").

2. The second script ("install_libraries.R") will install all required libraries in your R environment.  It can be run as follows:

>     Rscript install_libraries.R

(local installation of R packages in the user's home environment)
or

>     sudo Rscript install_libraries.R

(system-wide installation)

or it can be loaded and Ran in R-studio.

### On Windows
Using OnTheFLy<sup>2.0</sup> on Windows requires the existence of a Linux/Unix-like compatibility layer.  The suggested solution (for Windows 10) is the use of the Windows Subsystem for Linux (WSL) environment.  Alternatively, one can set-up and use a terminal emulator such as Cygwin.  This is the only option for pre-Windows 10 installations (Windows 7, Windows 8 etc), for which WSL is not available.  However, since Cygwin does not, by default, implement the use of package managers like apt (or zypper, rpm etc), the dependencies have to be installed by hand and, in several cases, to be compiled by source.  Below we describe the procedure to install and use OnTheFly<sup>2.0</sup> on a Windows 10 system with WSL.

#### Pure WSL installation
In this option, everything will be installed in WSL and be operated through the Linux environment in Windows.
1. Install and configure WSL in your system.  You can find the procedure for doing this in [this](https://www.windowscentral.com/install-windows-subsystem-linux-windows-10) link.
2. Install and setup (root access, passwords etc) a Linux distribution from the collection available in the [Windows Store](https://www.microsoft.com/en-us/search/shop/apps?q=Linux).  For the purposes of this guide, an Ubuntu or Debian installation is assumed.
3. Enable the use of GUI applications in WSL, following [this guide](https://techcommunity.microsoft.com/t5/windows-dev-appconsult/running-wsl-gui-apps-on-windows-10/ba-p/1493242).
4. Open a Linux terminal window and run the "install_dependencies.sh" script to install all required software:
    
>     sudo bash install_dependencies.sh

or

>     chmod +x install_dependencies.sh
>     sudo ./install_dependencies.sh
5. Install all required libraries in R by running the "install_libraries.R" script:

>     Rscript install_libraries.R

(local installation of R packages in the user's home environment)
or

>     sudo Rscript install_libraries.R

(system-wide installation)

6. Open the tool's project file (OnTheFly.rproj) in R-studio, select **ui.R**, **server.R** or **global.R** and click "Run App":

>     rstudio OnTheFly.rproj

#### Hybrid Windows and WSL installation
In this case, all of the software dependencies will be installed in WSL, but all R-related operations, including the final application itself, will be controlled by R-studio in native Windows.

1. Install and configure WSL in your system.  You can find the procedure for doing this in [this](https://www.windowscentral.com/install-windows-subsystem-linux-windows-10) link.
2. Install and setup (root access, passwords etc) a Linux distribution from the collection available in the [Windows Store](https://www.microsoft.com/en-us/search/shop/apps?q=Linux).  For the purposes of this guide, an Ubuntu or Debian installation is assumed.
3. Install all the software dependencies in WSL, by running the "install_dependencies.sh" script:
>     sudo bash install_dependencies.sh

or

>     chmod +x install_dependencies.sh
>     sudo ./install_dependencies.sh

4.  Install [R](https://cloud.r-project.org/bin/windows/) (version 3.6.1 or newer) and [R-studio](https://www.rstudio.com/products/rstudio/download/#download) for Windows.
5. Install all required libraries in R (or in R-studio), by loading and running the "install_libraries.R" script.
6. Open the tool's project file (OnTheFly.rproj) in R-studio, select  **ui.R**, **server.R** or **global.R** and click "Run App".  The first time you do this, your antivirus or firewall may request that you grant access to a program called "wsl".  This is a component of the WSL environment that allows you to run Linux applications in native Windows (i.e. outside the WSL environment). 


### Run using Docker
A Docker repository for OnTheFly<sup>2.0</sup> can be found at [https://hub.docker.com/r/pavlopouloslab/onthefly](https://hub.docker.com/r/pavlopouloslab/onthefly). The image already has every dependency pre-installed, meaning that you simply have to pull it and run it through a Docker container. This, of course, requires some familiarity with Docker.

1. Install and configure Docker in your system. You can find the procedure for doing this in the [Docker documentation](https://docs.docker.com/engine/install/).
2. (optional) Install a graphical application for managing Docker, such as Docker Desktop (Windows, MacOS) or Portainer (Windows, Linux, MacOS).
3. Pull the OnTheFly image from DockerHub:

>     docker pull pavlopouloslab/onthefly

4. Create a container and run the image. You can do this through Docker Desktop/Portainer, or through the command line. In any case, you will need to assign a port for the created container. Note that the image, by default, has port 3838 exposed for the created container. Therefore, published ports should be set-up in the format XXXX:3838, where "XXXX" is the port assigned to the host (your computer), e.g. 8084. This can be done with a command such as the following:
 
>     docker run -ti --rm -p 8084:3838 pavlopouloslab/onthefly

and in this case, the container would be accessible through a web browser in the address http://localhost:8084.


----

## Advanced configuration operations

### Change file size and number limitations
By default, OnTheFly<sup>2.0</sup> is configured to accept files with a maximum size of 10 MBs, and to handle up to 10 documents simultaneously. To change these options, open the **global.R** file with R-studio or a text editor, and alter the numerical values of the following two lines:
>     max_file_size = 10
>     max_files = 10

Save the altered script and then reload OnTheFly<sup>2.0</sup> (**Note:** If you are using shiny-server, you may have to restart its service for the changes to fully take place).

### Deploy using shiny-server
As an alternative to R-studio, you can deploy OnTheFly<sup>2.0</sup> as a web service, using **shiny-server**. This procedure requires a number of extra steps to be taken:

1. Install shiny-server. You can find instructions on how to do this using [this](https://www.rstudio.com/products/shiny/download-server/) link.
2. Configure shiny-server and set-up its service.  You can find instructions on how to adjust the configuration to best fit your system [here](https://docs.rstudio.com/shiny-server/#default-configuration). For the purposes of this guide, we assume that you use the standard configuration:
	- The port assigned to Shiny apps is **3838**
	- Shiny apps are located in `/srv/shiny-server/` and/or `/opt/shiny-server/samples/` (with symbolic links made to `/srv/shiny-server/`)
3. Download or clone (with git) the GitHub directory
>     git clone https://github.com/PavlopoulosLab/OnTheFly.git
4. Move the downloaded directory to `/srv/shiny-server/` directly or, alternatively, to `/opt/shiny-server/samples/`. In the latter case, create a symbolic link for OnTheFly in the `/srv/shiny-server/` directory. In this guide, we will follow the second option:
>     sudo mv OnTheFly /opt/shiny-server/samples/
>	  sudo ln -s /opt/shiny-server/samples/OnTheFly/ /srv/shiny-server/OnTheFly/
5. Change the owner of the OnTheFly directory to shiny
>     sudo chown shiny -R /opt/shiny-server/samples/OnTheFly/
6. Change the read/write/execute permissions for the temporary files directory, located in `OnTheFly/www/tmp/`:
>     sudo chmod 766 -R /opt/shiny-server/samples/OnTheFly/www/tmp/
7. Restart shiny-server to apply all changes:
>     sudo service shiny-server restart
8. Open your favorite web browser and visit http://localhost:3838/OnTheFly/.



# OnTheFly<sup>2.0</sup>

A text-mining web application for automated named entity recognition, document annotation, network and functional enrichment analysis 

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

----

Online version: http://bib.fleming.gr:3838/OnTheFly/

----
## Requirements
### System requirements
- Operating System: Linux (any distribution), Windows with WSL (Windows Subsystem for Linux) or another Unix-like compatibility layer (e.g. Cygwin)
- [R](https://www.r-project.org/) version >= 3.6.1
- [R-studio](https://www.rstudio.com/)  | **Note:** If **not** installed, the **shiny-server** R package is required for deployment
- [poppler](https://poppler.freedesktop.org/) (specifically, the poppler-utils and poppler-data packages)
- [pdf2htmlEX](https://pdf2htmlex.github.io/pdf2htmlEX/)
- [LibreOffice](https://www.libreoffice.org/get-help/install-howto/linux/) and the [unoconv](https://github.com/unoconv/unoconv) utility
- [Tesseract](https://github.com/tesseract-ocr/tesseract) (OCR scanning), the associated english and math training data ([tessdata](https://github.com/tesseract-ocr/tessdata) or [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast)) and the [OCRMyPDF](https://ocrmypdf.readthedocs.io/en/latest/) wrapper
- [ImageMagick](https://imagemagick.org/index.php) and [Ghostscript](https://www.ghostscript.com/)
- [curl](https://curl.se/), [libcurl](https://curl.se/libcurl/) and [libcurl4-openssl-dev](https://pkgs.org/download/libcurl4-openssl-dev) (required for the installation of the curl library in R)

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
- ShinyDashboardPlus **version 0.7.5** (**Note**: newer versions cause errors due to a bug that still hasn't been resolved in the package)
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
- xml2
- httpuv

**Note:** Packages can be installed through R or R-studio. **An installation script ("install_libraries.R") is included to automate the process of installing the above**.

----

## Installation Instructions

### On Linux
Linux is the native environment OnTheFly<sup>2.0</sup> is designed to operate in.  The main steps that need to be followed are:
1. Install R and R-studio
2. Install all software dependencies (pdf2htmlEX, libreoffice etc)
3. Install all required R libraries
4. Open the tool's project file (OnTheFly.rproj) in R-studio and click "Run App" **or** (alternatively), configure shiny-server and setup OnTherFly as a web service.

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

#### 1. Pure WSL installation
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

6. Open the tool's project file (OnTheFly.rproj) in R-studio and click "Run App":

>     rstudio OnTheFly.rproj

#### 2. Hybrid Windows R-studio / WSL installation
In this case, all of the software dependencies will be installed in WSL, but all R-related operations, including the final application itself, will be controlled by R-studio in native Windows.

1. Install and configure WSL in your system.  You can find the procedure for doing this in [this](https://www.windowscentral.com/install-windows-subsystem-linux-windows-10) link.
2. Install and setup (root access, passwords etc) a Linux distribution from the collection available in the [Windows Store](https://www.microsoft.com/en-us/search/shop/apps?q=Linux).  For the purposes of this guide, an Ubuntu or Debian installation is assumed.
3. Install all the software dependencies in WSL, by running the "install_dependencies.sh" script:
>     sudo bash install_dependencies.sh

or

>     chmod +x install_dependencies.sh
>     sudo ./install_dependencies.sh

4.  Install [R](https://cloud.r-project.org/bin/windows/) (version 3.6.1 or newer) and [R-studio](https://www.rstudio.com/products/rstudio/download/#download) for Windows.
5. Install all required libraries in R (or in R-studio), by loading an running the "install_libraries.R" script.
6. Open the tool's project file (OnTheFly.rproj) in R-studio and click "Run App".  The first time you do this, your antivirus or firewall may request that you grant access to a program called "wsl".  This is a component of the WSL environment that allows you to run Linux applications in native Windows (i.e. outside the WSL environment). 




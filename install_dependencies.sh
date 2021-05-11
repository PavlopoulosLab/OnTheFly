#!/usr/bin/env bash

#
# Automated bah script for building and setting-up all software dependencies of OnTheFly2.0
#
# Run this as sudo bash install_dependencies.sh
# or
# chmod +x install_dependencies.sh; sudo ./install_dependencies.sh
#
#
# This is expected to work properly in all Debian/Debian-based distributions (Debian, Ubuntu, LinuxMint etc)
#
# For other distributions (OpenSUSE, Fedora, Arch etc), please adapt them accordingly (replace apt-get with zypper etc)
#
# SPECIAL NOTE: Please visit https://github.com/pdf2htmlEX/pdf2htmlEX/wiki/Building#building-yourself to
# see how to build pdf2htmlEX in non-debian Linux distributions 
#
#
#


#install R
#Note: If your distribution has a version older than 3.4.4, then download and manually compile a newer version from r-project.org
apt-get --assume-yes install r-base r-base-core r-base-dev r-base-html

#install R-studio
#Note: if rstudio is not in your repositories or it is an obsolete version, then get the latest version from rstudio.com and install it manually (most likely a *.deb file you can double-click and setup)
apt-get --assume-yes install rstudio


#install poppler
apt-get --assume-yes install poppler-data poppler-utils

#Note: git is required to clone from github, cmake is required to install its dependencies
#if git and cmake are already installed, the following two commands will do nothing
apt-get --assume-yes install git
apt-get --assume-yes install cmake





#install tesseract and ocrmypdf
apt-get --assume-yes install libleptonica libtesseract3 libwebp2 tesseract-ocr tesseract-ocr-eng tesseract-ocr-equ tesseract-ocr-osd
apt-get --assume-yes install ocrmypdf


#install libreoffice & unoconv
apt-get --assume-yes install libreoffice
apt-get --assume-yes install unoconv

#install ghostscript and imagemagick
apt-get --assume-yes install ghostscript
apt-get --assume-yes install imagemagick


#install culr and the libcurl libraries
apt-get --assume-yes install curl libcurl4 libcurl4-openssl-dev




#install pdf2htmlEX
#this needs to be handled last, so that pdf2htmlEX is compiled using ALL required libraries
#clone pdf2htmlEX from repository
git clone https://github.com/pdf2htmlEX/pdf2htmlEX.git
#install it
cd pdf2htmlEX
./buildScripts/buildInstallLocallyApt

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
#Note: If your distribution has a version older than 3.6.1, then download and manually compile a newer version from r-project.org
apt-get install r-base r-base-core r-base-dev r-base-html

#install R-studio
#Note: you can also get the latest version
apt-get install rstudio


#install pdf2htmlEX
#Note: git is required to clone from github, cmake is required to install its dependencies
#if git and cmake are already installed, the following two commands will do nothing
apt-get install git
apt-get install cmake

#clone pdf2htmlEX from repository
git clone https://github.com/pdf2htmlEX/pdf2htmlEX.git
#install it
cd pdf2htmlEX
./buildScripts/buildInstallLocallyApt



#install tesseract and ocrmypdf
apt-get install libleptonica libtesseract3 libwebp2 tesseract-ocr tesseract-ocr-eng tesseract-ocr-equ tesseract-ocr-osd
apt-get install ocrmypdf


#install libreoffice & unoconv
apt-get install libreoffice
apt-get install unoconv

#install ghostscript and imagemagick
apt-get install ghostscript
apt-get install imagemagick


#install culr and the libcurl libraries
apt-get install curl libcurl4 libcurl4-openssl-dev


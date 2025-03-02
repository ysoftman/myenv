#!/bin/bash

glibc_version="2.41"
echo "install glibc $glibc_version"
wget https://ftp.gnu.org/gnu/glibc/glibc-$glibc_version.tar.gz
tar -zxvf glibc-$glibc_version.tar.gz
cd glibc-$glibc_version
mkdir build
cd build
../configure --prefix=$HOME/glibc-$glibc_version/build
make -j
make install

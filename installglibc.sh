#!/bin/bash

echo "install glibc 2.29"
wget https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
tar -zxvf glibc-2.29.tar.gz
mkdir build
cd build
../configure --prefix=$HOME/glibc-2.29/build
make -j
make install

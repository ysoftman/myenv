#!/bin/bash

glibc_version="2.41"
rm -rf glibc-$glibc_version
rm -rf $HOME/glibc-$glibc_version

echo "install glibc $glibc_version"
if [ ! -f "glibc-$glibc_version.tar.gz" ]; then
    wget https://ftp.gnu.org/gnu/glibc/glibc-$glibc_version.tar.gz
fi

tar -zxvf glibc-$glibc_version.tar.gz
cd glibc-$glibc_version || exit
mkdir build
cd build || exit
../configure --prefix=$HOME/glibc-$glibc_version/build
make -j
make install

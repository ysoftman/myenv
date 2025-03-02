#!/bin/bash

base_glibc_version="2.29"
cur_glibc_version=$(ldd --version | head -1 | awk '{print $4}')
highest_version="$(echo -e "${cur_glibc_version}\n${base_glibc_version}" | sort -r | head -n1)"
if [[ ${highest_version} != "${cur_glibc_version}" ]]; then
    echo "cur_glibc_version:$cur_glibc_version >= ${base_glibc_version}"
    exit 0
fi
echo "cur_glibc_version:$cur_glibc_version < ${base_glibc_version}"
echo "install glibc 2.29"
wget https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
tar -zxvf glibc-2.29.tar.gz
mkdir build
cd build
../configure --prefix=$HOME/glibc-2.29/build
make -j
make install

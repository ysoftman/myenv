#!/bin/bash
# GNU Multiple Precision Arithmetic Library (GMP)
wget https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0 || exit
./configure --prefix=$HOME/gmp
make -j
make install
cd ..

# GNU Multiple Precision Floating-Point Reliable Library (GNU MPFR)
wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.0.tar.xz
tar -xf mpfr-4.2.0.tar.xz
cd mpfr-4.2.0 || exit
./configure --prefix=$HOME/mpfr --with-gmp=$HOME/gmp
make -j
make install
cd ..

# GNU MPC is a C library for the arithmetic of complex numbers with arbitrarily high precision and correct rounding of the result
wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
tar -xf mpc-1.3.1.tar.gz
cd mpc-1.3.1 || exit
./configure --prefix=$HOME/mpc --with-gmp=$HOME/gmp --with-mpfr=$HOME/mpfr
make -j
make install
cd ..

wget http://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz
tar -zxvf gcc-14.2.0.tar.gz
cd gcc-14.2.0 || exit
./configure --prefix=$HOME/gcc-14.2.0 \
    --enable-languages=c,c++ \
    --disable-multilib \
    --with-gmp=$HOME/gmp \
    --with-mpfr=$HOME/mpfr \
    --with-mpc=$HOME/mpc

# 환경변수가 : 로 끝나면 LIBRARY_PATH shouldn't contain the current directory when building gcc 에러가 발생한다
export C_INCLUDE_PATH="$HOME/gmp/include:$HOME/mpfr/include:$HOME/mpc/include"
export LIBRARY_PATH="$HOME/gmp/lib:$HOME/mpfr/lib:$HOME/mpc/lib"
export LD_LIBRARY_PATH="$HOME/gmp/lib:$HOME/mpfr/lib:$HOME/mpc/lib"

make -j
make install

ls -ahl $HOME/gcc-14.2
$HOME/gcc-14.2/bin/gcc --version

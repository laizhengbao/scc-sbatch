#!/bin/sh

set -e

module purge

module load apps/adf/2024.102-intelmpi-intel

LIBPATH="${WORK1}/lib"
# NPROC="$(nproc)"
NPROC=4

if [ ! -d mpiP ]
then
	git clone -b 3.5 https://github.com/llnl/mpiP.git
fi

if [ ! -d libunwind ]
then
	git clone https://github.com/libunwind/libunwind.git
fi

cd libunwind
autoreconf -vfi
./configure --prefix="${LIBPATH}" CC=mpicc
make -j"${NPROC}"
make install

export PKG_CONFIG_PATH="${LIBPATH}/lib/pkgconfig:${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

cd ..

module load tools/miniconda3

conda create -n mpip_env python=3.10 -y
conda activate mpip_env

cd mpiP

./configure \
	--prefix="${LIBPATH}" \
	--with-binutils-dir=/usr \
	CFLAGS="$(pkg-config --cflags libunwind)" \
	LDFLAGS="-Wl,-rpath,${LIBPATH}/lib -L${LIBPATH}/lib $(pkg-config --libs-only-L libunwind)" \
	LIBS="$(pkg-config --libs-only-l libunwind)" \
	CC=mpicc

make -j"${NPROC}"

make install

cd ..

conda deactivate

echo ""
echo "Done Building!"

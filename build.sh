#!/bin/bash

echo "----------------------------------------"
echo "Check and Install Library"
echo "----------------------------------------"

sudo apt update
sudo apt install -y \
         netcdf-bin libnetcdf-mpi-dev libnetcdf-pnetcdf-dev libnetcdff-dev libpnetcdf-dev \
    	 libhdf5-openmpi-dev libfl-dev libpng-dev build-essential cmake byacc git

CURRENT_DIR=$(pwd)
PROXY_LIB=$(pwd)/dep-libs

echo "----------------------------------------"
echo -e "Setup proxy lib directory"
echo "----------------------------------------"
if [ ! -d $PROXY_LIB ]; then
	mkdir $PROXY_LIB
	mkdir $PROXY_LIB/tmp
fi

if [ ! -d $PROXY_LIB/bin ]; then
	ln -s /usr/bin $PROXY_LIB/bin
fi
if [ ! -d $PROXY_LIB/lib ]; then
	ln -s /usr/lib/x86_64-linux-gnu $PROXY_LIB/lib
fi
if [ ! -d $PROXY_LIB/include ]; then
	ln -s /usr/include $PROXY_LIB/include
fi

if [ ! -e $PROXY_LIB/lib/libhdf5.so ]; then
	sudo ln -s $PROXY_LIB/lib/libhdf5_openmpi.so $PROXY_LIB/lib/libhdf5.so
fi
if [ ! -e $PROXY_LIB/lib/libhdf5_hl.so ]; then
	sudo ln -s $PROXY_LIB/lib/libhdf5_hl_openmpi.so $PROXY_LIB/lib/libhdf5_hl.so
fi




echo "----------------------------------------"
echo "Clone or update WRF source"
echo "----------------------------------------"
if [ ! -d WRF ]; then
	git clone https://github.com/wrf-model/WRF.git
else
	cd WRF
	git pull
	cd ..
fi

echo "----------------------------------------"
echo "Clone or update WPS source"
echo "----------------------------------------"
if [ ! -d WPS ]; then
	git clone https://github.com/wrf-model/WPS.git
else
	cd WPS
	git pull
	cd ..
fi


export NETCDF=$PROXY_LIB
export WRF_CHEM=1
export WRF_KPP=1
export YACC='/usr/bin/yacc -d'
export FLEX_LIB_DIR='/usr/lib/x86_64-linux-gnu'

echo "----------------------------------------"
echo "Compile WRF"
echo "----------------------------------------"

cd WRF
./configure 

if [ ! -e configure.wrf ]; then
	echo "Error cannot continue"
	exit 1
fi

./compile -j 4 em_real
if [ $? != 0 ]; then
	echo "Compile error"
	exit 1
fi

cd ..



echo "----------------------------------------"
echo "Check and Compile Jasper"
echo "----------------------------------------"

if [ ! -e $PROXY_LIB/tmp/jasper-2.0.14.tar.gz ]; then
	wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-2.0.14.tar.gz --directory-prefix=$PROXY_LIB/tmp/
fi
if [ ! -d $PROXY_LIB/tmp/jasper-2.0.14 ]; then
	tar zxvf $PROXY_LIB/tmp/jasper-2.0.14.tar.gz --directory=$PROXY_LIB/tmp/
fi

mkdir -p $PROXY_LIB/tmp/jasper-2.0.14/build-dir
cd $PROXY_LIB/tmp/jasper-2.0.14/build-dir 
cmake ..
make
sudo make install

cd $CURRENT_DIR


echo "----------------------------------------"
echo "Compile WPS"
echo "----------------------------------------"
cd WPS
./configure
if [ ! -e configure.wps ]; then
	echo "Error cannot continue"
	exit 1
fi

./compile
if [ $? != 0 ]; then
	echo "Compile error"
	exit 1
fi

cd ..

if [ ! -e $PROXY_LIB/tmp/prep_chem_sources_v1.5_24aug2015.tar.gz ]; then
	wget ftp://aftp.fsl.noaa.gov/divisions/taq/global_emissions/prep_chem_sources_v1.5_24aug2015.tar.gz --directory-prefix=$PROXY_LIB/tmp/
fi

if [ ! -d prep_chem_sources_v1.5 ]; then
	tar zxvf $PROXY_LIB/tmp/prep_chem_sources_v1.5_24aug2015.tar.gz
fi





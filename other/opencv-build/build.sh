#!/bin/bash

read -p 'Please manually install Intel MKL: https://software.intel.com/en-us/articles/free-mkl [ok]' OK
[ ! "$OK" = ok -a "$OK" ] && exit

read -p 'Install dependencies? [ok]' OK
[ ! "$OK" = ok -a "$OK" ] || sudo apt install gcc g++ git libjpeg-dev libpng-dev libtiff5-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev pkg-config cmake libgtk2.0-dev libeigen3-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev sphinx-common libtbb-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenexr-dev libgstreamer-plugins-base1.0-dev libavcodec-dev libavutil-dev libavfilter-dev libavformat-dev libavresample-dev -y

# MacOS: brew install git cmake pkg-config jpeg libpng libtiff openexr eigen tbb

cd /tmp
echo "Downloading"
wget https://github.com/Itseez/opencv/archive/3.2.0.zip

unzip 3.2.0.zip
cd opencv*

mkdir release
cd release

cmake -DBUILD_TIFF=ON -DBUILD_opencv_java=OFF -DWITH_CUDA=OFF -DENABLE_AVX=ON -DWITH_OPENGL=ON -DWITH_OPENCL=ON -DWITH_IPP=ON -DWITH_TBB=ON -DWITH_EIGEN=ON -DWITH_V4L=ON -DWITH_VTK=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_opencv_python2=OFF -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") -DPYTHON3_EXECUTABLE=$(which python3) -DPYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -DPYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") ..

make -j4
make install   # do not use sudo !

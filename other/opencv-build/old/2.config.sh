#!/bin/bash

cmake_install_prefix=`python3 -c 'import sys; print(sys.prefix)'`
python3_executable=`which python3`
python3_include_dir=`python3 -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())'`
python3_packages_path=`python3 -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())'`
python3_numpy_include_dirs=$python3_packages_path/numpy/core/include

cd ~/.opencv/build
cmake -D BUILD_TIFF=ON \
      -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
      -D BUILD_opencv_java=OFF \
      -D WITH_CUDA=OFF \
      -D ENABLE_AVX=ON \
      -D WITH_OPENGL=ON \
      -D WITH_OPENCL=ON \
      -D WITH_IPP=ON \
      -D WITH_TBB=ON \
      -D WITH_EIGEN=ON \
      -D WITH_V4L=ON \
      -D WITH_VTK=OFF \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D CMAKE_BUILD_TYPE=RELEASE \
      -D BUILD_opencv_python2=OFF \
      -D CMAKE_INSTALL_PREFIX=$cmake_install_prefix \
      -D PYTHON3_EXECUTABLE=$python3_executable \
      -D PYTHON3_INCLUDE_DIR=$python3_include_dir \
      -D PYTHON3_PACKAGES_PATH=$python3_packages_path \
      -D PYTHON3_NUMPY_INCLUDE_DIRS=$python3_numpy_include_dirs \
      ..


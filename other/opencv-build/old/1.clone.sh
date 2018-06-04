#!/bin/bash

git clone --depth 1 https://github.com/opencv/opencv ~/.opencv
cd ~/.opencv
git clone --depth 1 https://github.com/opencv/opencv_contrib
mkdir build
cd build

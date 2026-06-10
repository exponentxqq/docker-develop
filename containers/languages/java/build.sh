#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "VERSION is not defined, use 4.2.0 instead"
  VERSION=4.2.0
else
  VERSION=$1
fi

echo "Build opencv of version: ${VERSION}"

BASEDIR=$(cd "$(dirname "$0")"; pwd)

REMOTE_ADDR=https://codeload.github.com/opencv/opencv/zip/$VERSION

if [ ! -f opencv-$VERSION.zip ]; then
  curl -o opencv-$VERSION.zip $REMOTE_ADDR
fi

if [ ! -d opencv-$VERSION ]; then
  unzip -qq opencv-$VERSION.zip
fi
cd opencv-$VERSION

if [ -d build ]; then
  rm -rf build
fi
mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DBUILD_TESTS=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_opencv_ts=OFF \
  -DBUILD_opencv_python3=OFF \
  -DBUILD_opencv_python_bindings_generator=OFF \
  -DBUILD_IPP_IW=OFF \
  -DBUILD_ITT=OFF \
  -DBUILD_OPENEXR=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DBUILD_TIFF=OFF \
  -DBUILD_opencv_calib3d=OFF \
  -DBUILD_opencv_dnn=OFF \
  -DBUILD_opencv_features2d=OFF \
  -DBUILD_opencv_flann=OFF \
  -DBUILD_opencv_gapi=OFF \
  -DBUILD_opencv_highgui=OFF \
  -DBUILD_opencv_ml=OFF \
  -DBUILD_opencv_objdetect=OFF \
  -DBUILD_opencv_photo=OFF \
  -DBUILD_opencv_python_tests=OFF \
  -DBUILD_opencv_stitching=OFF \
  -DBUILD_opencv_video=OFF \
  -DBUILD_opencv_videoio=OFF \
  -DVIDEOIO_ENABLE_PLUGINS=OFF \
  -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK=OFF ..
make -j8

echo "========================================="
echo "Make success.."
echo "opencv-*.jar in ${BASEDIR}/bin/"
echo "libopencv_java*.so in ${BASEDIR}/lib/"
echo "========================================="

#!/bin/bash
which docker 2> /dev/null 2> /dev/null
if [ "$?" -eq "1" ]
then
  echo 'Docker not found. Install it first.'
  exit 1
fi

stat .git 2> /dev/null 2> /dev/null
if [ "$?" -eq "1" ]
then
  echo 'Run this inside the rippled directory. (.git dir not found).'
  exit 1
fi
docker run -t -i --rm  -v `pwd`:/io --network host ghcr.io/foobarwidget/holy-build-box-x64 /hbb_exe/activate-exec bash -x -c '
cd /io;
rm -rf release-build;
mkdir release-build;
mkdir .nih_c;
mkdir .nih_toolchain;
cd .nih_toolchain;
yum install wget lz4 lz4-devel git -y &&
echo "-- Install Cmake 3.23.1 --" &&
wget -nc https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-linux-x86_64.tar.gz &&
tar -xzf cmake-3.23.1-linux-x86_64.tar.gz -C /hbb/ &&
echo "-- Install Boost 1.75.0 --" &&
wget -nc https://boostorg.jfrog.io/artifactory/main/release/1.75.0/source/boost_1_75_0.tar.gz &&
tar -xzf boost_1_75_0.tar.gz &&
cd boost_1_75_0 && ./bootstrap.sh && ./b2  link=static -j8 && ./b2 install &&
cd ../;
echo "-- Install Protobuf 3.20.0 --" &&
wget -nc https://github.com/protocolbuffers/protobuf/releases/download/v3.20.0/protobuf-all-3.20.0.tar.gz &&
tar -xzf protobuf-all-3.20.0.tar.gz &&
cd protobuf-3.20.0/ &&
./autogen.sh && ./configure --prefix=/usr --disable-shared link=static && make -j8 && make install &&
cd ../../;
sed -E -i "s/^include.deps\/Rocksdb.$/#\0/g" CMakeLists.txt &&
echo "-- Build Rippled --" &&
cd release-build &&
export BOOST_ROOT="/usr/local/src/boost_1_75_0" &&
export Boost_LIBRARY_DIRS="/usr/local/lib" &&
export BOOST_INCLUDEDIR="/usr/local/src/boost_1_75_0" &&
cmake .. -DBoost_NO_BOOST_CMAKE=ON &&
make -j8 &&
echo "Build host: `hostname`" > release.info &&
echo "Build date: `date`" >> release.info &&
echo "Git remotes:" >> release.info && 
git remote -v >> release.info 
echo "Git status:" >> release.info &&
git status -v >> release.info &&
echo "Git log [last 20]:" >> release.info &&
git log -n 20 >> release.info &&
./rippled -u > test.log;
cd .. &&
sed -E -i "s/^#(include.deps\/Rocksdb.)$/\1/g" CMakeLists.txt'




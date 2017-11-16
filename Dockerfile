FROM aarch64/ubuntu

COPY qemu-aarch64-static /usr/bin/

RUN apt update && apt install -y bzip2 curl unp sudo

WORKDIR /tmp

# drivers first
RUN curl -s https://s3-us-west-1.amazonaws.com/jetson-packages/Tegra186_Linux_R28.1.0_aarch64.tbz2 | tar --use-compress-prog=bzip2 -xv  && \
    /tmp/Linux_for_Tegra/apply_binaries.sh -r / && \
    rm -fr /tmp/*

RUN curl https://s3-us-west-1.amazonaws.com/jetson-packages/cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb -so /tmp/cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb && \
    curl https://s3-us-west-1.amazonaws.com/jetson-packages/libcudnn6-dev_6.0.21-1%2Bcuda8.0_arm64.deb -so /tmp/libcudnn6-dev_6.0.21-1+cuda8.0_arm64.deb && \
    curl https://s3-us-west-1.amazonaws.com/jetson-packages/libcudnn6_6.0.21-1%2Bcuda8.0_arm64.deb -so /tmp/libcudnn6_6.0.21-1+cuda8.0_arm64.deb && \
    dpkg -i /tmp/cuda-repo-l4t-8-0-local_8.0.84-1_arm64.deb && \
    apt update && \
    apt install -y cuda-toolkit-8.0 && \
    dpkg -i /tmp/libcudnn6_6.0.21-1+cuda8.0_arm64.deb && \
    dpkg -i /tmp/libcudnn6-dev_6.0.21-1+cuda8.0_arm64.deb && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/tegra && \
    ln -s /usr/lib/aarch64-linux-gnu/libcuda.so /usr/lib/aarch64-linux-gnu/libcuda.so.1 && \
    rm -fr /tmp/* \
    && apt-get -y clean all

# GIT
RUN apt install -y git

# Python 2.7
RUN apt install -y \
    python-pip \
    python-dev \
    python-numpy \
    python-py \
    python-pytest \
    && apt-get -y clean all


# Now TensorFlow

WORKDIR /tmp
RUN curl https://s3-us-west-1.amazonaws.com/jetson-packages/tensorflow-1.3.0-cp27-cp27mu-linux_aarch64.whl -so /tmp/tensorflow-1.3.0-cp27-cp27mu-linux_aarch64.whl && \
    pip install tensorflow-1.3.0-cp27-cp27mu-linux_aarch64.whl && rm /tmp/tensorflow-1.3.0-cp27-cp27mu-linux_aarch64.whl


# OPENCV Stuff

RUN apt install -y \
    libglew-dev \
    libtiff5-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng12-dev \
    libjasper-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libpostproc-dev \
    libswscale-dev \
    libeigen3-dev \
    libtbb-dev \
    libgtk2.0-dev \
    cmake \
    pkg-config \
    && apt-get -y clean all

# GStreamer
#RUN apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev


# Python 3.5 and stuff
RUN apt install -y \
    python3-pip \
    python3-dev \
    python3-numpy \
    python3-py \
    python3-pytest \
    wget \
    unzip \
    && apt-get -y clean all \
    && rm -rf /var/lib/apt/lists/*



ENV CV_VERSION 3.3.0

# Opencv

RUN wget https://github.com/Itseez/opencv/archive/$CV_VERSION.zip -O opencv.zip && \
    unzip -q opencv.zip && \
    wget https://github.com/Itseez/opencv_contrib/archive/$CV_VERSION.zip -O opencv_contrib.zip && \
    unzip -q opencv_contrib.zip && \
    mkdir opencv-$CV_VERSION/build && \
    cd opencv-$CV_VERSION/build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DBUILD_PNG=OFF \
        -DBUILD_TIFF=OFF \
        -DBUILD_TBB=OFF \
        -DBUILD_JPEG=OFF \
        -DBUILD_JASPER=OFF \
        -DBUILD_ZLIB=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_opencv_java=OFF \
        -DBUILD_opencv_python2=ON \
        -DBUILD_opencv_python3=ON \
        -DENABLE_PRECOMPILED_HEADERS=OFF \
        -DWITH_OPENCL=OFF \
        -DWITH_OPENMP=OFF \
        -DWITH_FFMPEG=ON \
        -DWITH_GSTREAMER=OFF \
        -DWITH_GSTREAMER_0_10=OFF \
        -DWITH_CUDA=ON \
        -DWITH_GTK=ON \
        -DWITH_VTK=OFF \
        -DWITH_TBB=ON \
        -DWITH_1394=OFF \
        -DWITH_OPENEXR=OFF \
        -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0 \
        -DCUDA_ARCH_BIN=6.2 \
        -DCUDA_ARCH_PTX="" \
        -DINSTALL_C_EXAMPLES=OFF \
        -DINSTALL_TESTS=OFF \
        -DOPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-$CV_VERSION/modules .. && \
    make -j4 && \
    make install && \
    rm /tmp/opencv.zip && \
    rm /tmp/opencv_contrib.zip && \
    rm -r /tmp/opencv-$CV_VERSION

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/tegra

# PilotCli library for control with socketio
RUN pip install --upgrade pip && \
    pip install git+https://bitbucket.org/kiwicampus/pilot-cli@develop shyaml cytoolz

FROM arm64v8/ubuntu

# setup environment
ENV DEBIAN_FRONTEND noninteractive
ENV QEMU_EXECVE 1
COPY ./bin/ /usr/bin/
RUN [ "cross-build-start" ]

RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
        apt-utils \
        apt-transport-https \
        sudo \
        wget \
        curl \
        rsync \
        vim \
        git \
        expect \
        terminator \
        bash-completion \
        net-tools \
        build-essential \
        pkg-config \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-dev \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

# tensor flow dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        libhdf5-serial-dev \
        hdf5-tools \
        libhdf5-dev \
        zlib1g-dev \
        zip \
        libjpeg8-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED 1

RUN pip3 install --upgrade setuptools wheel pip

# grpcio takes forever to build... (tensorflow dependency)
RUN pip3 install grpcio
# install newer numpy... the python3-numpy package is 0xb, whereas pytorch is compiled against 0xc
RUN pip3 install --upgrade numpy
# ... and so does the libraries below (i.e. they take a while to build)
RUN pip3 install h5py
RUN pip3 install pandas

# install tensorflow dependencies
RUN pip3 install \
    astor gast six \
    protobuf tensorflow_estimator \
    absl-py tensorboard \
    keras-applications keras-preprocessing \
    py-cpuinfo psutil portpicker mock requests termcolor wrapt google-pasta \
    pillow
# RUN pip3 install scikit-learn # fails installing

# install other useful python libraries
RUN pip3 install \
    docopt \
    tornado \
    moviepy \
    greenlet \
    proglog \
    imageio-ffmpeg \
    MarkupSafe \
    python-engineio \
    python-socketio \
    click \
    itsdangerous \
    Jinja2 \
    flask \
    dnspython \
    monotonic \
    eventlet

# opencv
RUN apt-get update && apt-get install -y --no-install-recommends \
        libopenblas-dev \
        build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev \
        libv4l-dev v4l-utils qv4l2 v4l2ucp \
    && rm -rf /var/lib/apt/lists/*

# ref: https://jkjung-avt.github.io/opencv-on-nano/
# ref: https://devtalk.nvidia.com/default/topic/1049972/jetson-nano/opencv-cuda-python-with-jetson-nano/1
# ref: https://github.com/AastaNV/JEP/blob/master/script/install_opencv4.0.0_Nano.sh
# ref: https://github.com/jkjung-avt/jetson_nano/blob/master/install_opencv-3.4.6.sh
ARG OPENCV=3.4.6
# ARG OPENCV=4.1.0
# not using these options: -D WITH_QT=ON -D WITH_OPENGL=ON
RUN wget https://github.com/opencv/opencv/archive/${OPENCV}.tar.gz -O /tmp/opencv-${OPENCV}.tar.gz > /dev/null 2>&1 \
    && wget https://github.com/opencv/opencv_contrib/archive/${OPENCV}.tar.gz -O /tmp/opencv_contrib-${OPENCV}.tar.gz > /dev/null 2>&1 \
    && cd /tmp \
    && tar zxvf opencv-${OPENCV}.tar.gz \
    && tar zxvf opencv_contrib-${OPENCV}.tar.gz \
    && cd opencv-${OPENCV}/ \
    && mkdir build \
    && cd build/ \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_CUDA=ON -D CUDA_ARCH_BIN="5.3" -D CUDA_ARCH_PTX="" -D WITH_CUBLAS=ON -D ENABLE_FAST_MATH=ON -D CUDA_FAST_MATH=ON -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-${OPENCV}/modules -D WITH_GSTREAMER=ON -D ENABLE_NEON=ON -D OPENCV_ENABLE_NONFREE=ON -D WITH_LIBV4L=ON -D BUILD_opencv_python2=OFF -D BUILD_opencv_python3=ON -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF .. \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/opencv*

# installing tensorflow
# https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html
# https://devtalk.nvidia.com/default/topic/1048776/official-tensorflow-for-jetson-nano-/
ARG TENSORFLOW_WHL=tensorflow_gpu-1.13.1+nv19.5-cp36-cp36m-linux_aarch64.whl
RUN wget https://developer.download.nvidia.com/compute/redist/jp/v42/tensorflow-gpu/${TENSORFLOW_WHL} -O /tmp/${TENSORFLOW_WHL} > /dev/null 2>&1 \
    && pip3 install /tmp/${TENSORFLOW_WHL} \
    && rm /tmp/${TENSORFLOW_WHL}

# another long running package
RUN pip3 install scipy
# install keras
RUN pip3 install keras

# install pytorch 1.1.0
# https://devtalk.nvidia.com/default/topic/1049071/jetson-nano/pytorch-for-jetson-nano/
# https://github.com/pytorch/pytorch/blob/master/README.md#nvidia-jetson-platforms
# https://nvidia.box.com/v/torch-stable-cp36-jetson-jp42/
RUN wget https://nvidia.box.com/shared/static/j2dn48btaxosqp0zremqqm8pjelriyvs.whl -O /tmp/torch-1.1.0-cp36-cp36m-linux_aarch64.whl > /dev/null 2>&1 \
    && pip3 install /tmp/torch-1.1.0-cp36-cp36m-linux_aarch64.whl \
    && rm /tmp/torch-1.1.0-cp36-cp36m-linux_aarch64.whl

# torchvision
# TODO: needs libcudart.so.10.0 to compile torchvision
# RUN cd /tmp \ 
#     && git clone https://github.com/pytorch/vision \
#     && cd vision \
#     && python3 setup.py install \
#     && cd .. \
#     && rm -rf vision

COPY test_env.py /

# setup docker user
ARG user=jetson
ARG group=jetson
ARG uid=1000
ARG gid=1000
ARG home=/home/jetson
RUN groupadd -g ${gid} ${group} \
    && useradd -d ${home} -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    && echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudoers_${user}
    # && usermod -aG docker ${user}

USER ${user}
WORKDIR ${home}

RUN [ "cross-build-end" ]

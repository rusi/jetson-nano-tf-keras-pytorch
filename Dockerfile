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

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-numpy \
        python3-scipy \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED 1

RUN pip3 install --upgrade setuptools wheel pip

# install pytorch 1.1.0
# https://devtalk.nvidia.com/default/topic/1049071/jetson-nano/pytorch-for-jetson-nano/
# https://github.com/pytorch/pytorch/blob/master/README.md#nvidia-jetson-platforms
# https://nvidia.box.com/v/torch-stable-cp36-jetson-jp42/
RUN wget https://nvidia.box.com/shared/static/j2dn48btaxosqp0zremqqm8pjelriyvs.whl -O /tmp/torch-1.1.0-cp36-cp36m-linux_aarch64.whl \
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

# installing tensorflow
# https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html
# tensor flow dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        libhdf5-serial-dev \
        hdf5-tools \
        libhdf5-dev \
        zlib1g-dev \
        zip \
        libjpeg8-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -vvv \
    astor gast six grpcio wheel \
    protobuf tensorflow_estimator \
    absl-py tensorboard h5py \
    keras-applications keras-preprocessing \
    py-cpuinfo psutil portpicker mock requests termcolor wrapt google-pasta
# https://devtalk.nvidia.com/default/topic/1048776/official-tensorflow-for-jetson-nano-/
ARG TENSORFLOW_WHL=tensorflow_gpu-1.13.1+nv19.5-cp36-cp36m-linux_aarch64.whl
RUN wget https://developer.download.nvidia.com/compute/redist/jp/v42/tensorflow-gpu/${TENSORFLOW_WHL} -O /tmp/${TENSORFLOW_WHL} \
    && pip3 install /tmp/${TENSORFLOW_WHL} \
    && rm /tmp/${TENSORFLOW_WHL}

# install keras
RUN pip3 install scikit-learn pillow
RUN pip3 install keras

COPY test_env.py /

RUN [ "cross-build-end" ]

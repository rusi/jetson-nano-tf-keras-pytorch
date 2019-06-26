# TensorFlow, Keras, PyTorch (and OpenCV) Docker container for Jetson Nano

## Pre-req
To run this container on Jetson Nano, you need to install `docker-compose`:
```
$ sudo apt update
$ sudo apt install docker-compose
```

Add yourself to the `docker` group:
```
$ sudo gpasswd -a $USER docker
# or
$ sudo usermod -aG docker $USER
```
and reboot (or logout/login) and test:
```
$ docker ps
```

## Use
To run this container (on Jetson Nano):
```
$ git clone https://github.com/rusi/jetson-nano-tf-keras-pytorch.git
$ cd jetson-nano-tf-keras-pytorch
$ docker-compose run --rm jetson
```

## Test
To test TensorFlow, Keras, and OpenCV installation:
```
$ docker-compose run --rm jetson python3 /opt/tools/tf-cuda-test.py
```

To test CSI / RPi2 Camera:
```
$ docker-compose run --rm jetson /opt/tools/cam-test.sh
```

## Build
To build on `x86_64`, you need to install `qemu-user-static`:
```
$ sudo apt install qemu-user-static
# to test:
$ docker run -it --rm -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static arm64v8/ubuntu uname -a
```

To build and run this container locally:
```
$ docker build . -t jetson-nano-tf-keras-pytorch
$ docker run --rm -it jetson-nano-tf-keras-pytorch
```

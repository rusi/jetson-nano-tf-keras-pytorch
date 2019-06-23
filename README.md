# TensorFlow, Keras, PyTorch (and OpenCV) docker container for Jetson Nano

To use this container:
```
$ docker run --rm -it rusi/jetson-nano-tf-keras-pytorch
```

To build on `x86_64` need to install `qemu-user-static`:
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

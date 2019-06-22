# TensorFlow, Keras, PyTorch docker container for Jetson Nano

To run ARM containers on Ubuntu:
```
sudo apt install qemu-user-static
docker run -it --rm -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static arm64v8/ubuntu uname -a
```

To run this container:
```
docker build . -t jetson-nano-tf-keras-pytorch
docker run --rm -it jetson-nano-tf-keras-pytorch uname -a
```

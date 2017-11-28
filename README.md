# jetsontx2-opencv-tf

Jetson Tx2 aarch64/ubuntu Image with Tensorflow 1.3.0 for python 2.7 and Opencv 3.3.0 with python 2.7 and 3.5 bindings, all compiled with CUDA acceleration.

## How to build it

```
docker build -t custom_name .
```

```
docker tag custom_name charlielito/opencv-tf:aarch64.X.X.X
docker push charlielito/opencv-tf:aarch64.X.X.X
```

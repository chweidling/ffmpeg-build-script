#!/bin/bash

set -e

docker build -t ffmpeg .

mkdir -p build
img_id=$(docker create ffmpeg)

docker cp $img_id:/usr/bin/ffmpeg ./build/
docker cp $img_id:/usr/bin/ffprobe ./build/
docker cp $img_id:/usr/bin/ffplay ./build/

docker rm $img_id

echo "FFmpeg binaries copied to ./build/"
echo "Build completed successfully."

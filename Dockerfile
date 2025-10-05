FROM ubuntu:25.10 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends install build-essential curl ca-certificates libva-dev \
        python3 python-is-python3 ninja-build meson git curl autotools-dev automake autoconf libtool cmake yasm pkg-config libtool \
    && apt-get install -y g++-15 gcc-15 \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && update-ca-certificates

RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/x86_64-linux-gnu-g++-15 10 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/x86_64-linux-gnu-gcc-15 10


WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg

RUN --mount=type=cache,target=/app/workspace --mount=type=cache,target=/app/packages SKIPINSTALL=yes /app/build-ffmpeg --build --enable-gpl-and-non-free --latest --full-static && \
    mkdir /output && \
    cp /app/workspace/bin/ffmpeg /output/ffmpeg && \
    cp /app/workspace/bin/ffprobe /output/ffprobe && \
    cp /app/workspace/bin/ffplay /output/ffplay

FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive

# install va-driver
RUN apt-get update \
    && apt-get -y install libva-drm2 \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Copy ffmpeg
COPY --from=build /output/ffmpeg /usr/bin/ffmpeg
COPY --from=build /output/ffprobe /usr/bin/ffprobe
COPY --from=build /output/ffplay /usr/bin/ffplay

# Check shared library
#RUN ldd /usr/bin/ffmpeg
#RUN ldd /usr/bin/ffprobe
#RUN ldd /usr/bin/ffplay

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]

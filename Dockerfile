############################################
# FFmpeg build stage
############################################
FROM alpine:3.22.2 AS build

ARG FFMPEG_VERSION=7.1.1
ARG PREFIX=/opt/ffmpeg
ARG LD_LIBRARY_PATH=/opt/ffmpeg/lib
ARG MAKEFLAGS="-j4"

# Build stage labels
LABEL org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-ffmpeg" \
      org.opencontainers.image.licenses="MIT"

# Install build dependencies
RUN apk add --no-cache --update \
    build-base \
    cmake \
    coreutils \
    freetype-dev \
    g++ \
    gcc \
    git \
    lame-dev \
    libogg-dev \
    libass \
    libass-dev \
    libtheora-dev \
    libvorbis-dev \
    libvpx-dev \
    libwebp-dev \
    nasm \
    openssl \
    openssl-dev \
    opus-dev \
    perl \
    pkgconf \
    pkgconfig \
    rtmpdump-dev \
    wget \
    x264-dev \
    x265-dev \
    yasm \
    zlib-dev

# Get fdk-aac from community repository
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    apk add --no-cache --update fdk-aac-dev

# Download FFmpeg source
RUN cd /tmp && \
    wget -O ffmpeg.tar.gz https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    tar -xzf ffmpeg.tar.gz && \
    rm ffmpeg.tar.gz

# Configure and compile FFmpeg
RUN cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
    ./configure \
    --prefix=${PREFIX} \
    --enable-version3 \
    --enable-gpl \
    --enable-nonfree \
    --enable-small \
    --enable-libmp3lame \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libopus \
    --enable-libfdk-aac \
    --enable-libass \
    --enable-libwebp \
    --enable-libfreetype \
    --enable-librtmp \
    --enable-postproc \
    --enable-openssl \
    --disable-debug \
    --disable-doc \
    --disable-ffplay \
    --extra-libs="-lpthread -lm" && \
    make && \
    make install && \
    make distclean

# Strip binaries for smaller size
RUN cd ${PREFIX}/bin && \
    for f in *; do \
        strip $f || true; \
    done

############################################
# Runtime stage
############################################
FROM alpine:3.22.2

ARG PREFIX=/opt/ffmpeg
ARG BUILD_DATE
ARG VERSION

# OCI-compliant labels
LABEL org.opencontainers.image.title="FFmpeg on Alpine Linux" \
      org.opencontainers.image.description="Lightweight FFmpeg Docker image with comprehensive codec support built on Alpine Linux" \
      org.opencontainers.image.vendor="ragedunicorn" \
      org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-ffmpeg" \
      org.opencontainers.image.documentation="https://github.com/RagedUnicorn/docker-ffmpeg/blob/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.base.name="docker.io/library/alpine:3.22.1"

# Install runtime dependencies only
RUN apk add --no-cache --update \
    ca-certificates \
    openssl \
    lame-libs \
    libogg \
    libvpx \
    libvorbis \
    libtheora \
    opus \
    rtmpdump \
    x264-libs \
    x265-libs \
    libass \
    libwebp \
    libwebpmux \
    libwebpdemux \
    freetype \
    libxcb \
    xcb-util \
    xcb-util-image \
    xcb-util-keysyms \
    xcb-util-renderutil \
    xcb-util-wm

# Get fdk-aac runtime library from community repository
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    apk add --no-cache --update fdk-aac

# Create non-root user for running FFmpeg
RUN adduser -D -H -s /sbin/nologin ffmpeg

# Copy FFmpeg binaries from build stage
COPY --from=build ${PREFIX}/bin/* /usr/local/bin/

# Create working directory for input/output files
WORKDIR /tmp/workdir

RUN chown -R ffmpeg:ffmpeg /tmp/workdir

USER ffmpeg

# Set the entrypoint to ffmpeg binary
ENTRYPOINT ["ffmpeg"]

# Default to showing help if no arguments provided
CMD ["-help"]

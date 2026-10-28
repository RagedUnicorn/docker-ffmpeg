############################################
# FFmpeg build stage
############################################
FROM alpine:3.24.3 AS build

ARG FFMPEG_VERSION=7.1.5
ARG FFMPEG_GPG_FINGERPRINT=FCF986EA15E6E293A5644F10B4322F04D67658D8
ARG PREFIX=/opt/ffmpeg
ARG LD_LIBRARY_PATH=/opt/ffmpeg/lib
ARG MAKEFLAGS="-j4"

# Build stage labels
LABEL org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-ffmpeg" \
      org.opencontainers.image.licenses="MIT"

# Install build dependencies. The AV1 libraries (aom, svt-av1, dav1d) need
# FFmpeg >= 7.1.4: older 7.1.x releases do not compile against SVT-AV1 3.x/4.x.
# libxcb-dev and linux-headers are what configure autodetects the x11grab and
# v4l2 capture devices from. Other -dev packages pull both in today, but they are
# listed explicitly so the capture devices do not vanish silently with them
RUN apk add --no-cache --update \
    aom-dev \
    build-base \
    cmake \
    coreutils \
    dav1d-dev \
    fontconfig-dev \
    freetype-dev \
    g++ \
    gcc \
    git \
    gnupg \
    harfbuzz-dev \
    lame-dev \
    libogg-dev \
    libass \
    libass-dev \
    libtheora-dev \
    libvorbis-dev \
    libvpx-dev \
    libwebp-dev \
    libxcb-dev \
    linux-headers \
    nasm \
    openssl \
    openssl-dev \
    opus-dev \
    perl \
    pkgconf \
    pkgconfig \
    rtmpdump-dev \
    svt-av1-dev \
    wget \
    x264-dev \
    x265-dev \
    yasm \
    zlib-dev

# Download the FFmpeg source and verify its GPG signature before extracting.
# The release key is fetched from ffmpeg.org (the same host as the tarball), so
# the signature is only accepted if it was made by the pinned key fingerprint
RUN cd /tmp && \
    wget -O ffmpeg.tar.gz https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    wget -O ffmpeg.tar.gz.asc https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz.asc && \
    wget -O ffmpeg-devel.asc https://ffmpeg.org/ffmpeg-devel.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --import ffmpeg-devel.asc && \
    gpg --batch --status-fd 1 --verify ffmpeg.tar.gz.asc ffmpeg.tar.gz \
        | grep -q "^\[GNUPG:\] VALIDSIG .* ${FFMPEG_GPG_FINGERPRINT}$" && \
    rm -rf "${GNUPGHOME}" ffmpeg.tar.gz.asc ffmpeg-devel.asc && \
    tar -xzf ffmpeg.tar.gz && \
    rm ffmpeg.tar.gz

# Configure and compile FFmpeg. No --enable-nonfree: a GPL build linked against
# non-free libraries (such as libfdk-aac) may not be redistributed, and this
# image is published. The native "aac" encoder covers AAC output instead
RUN cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
    ./configure \
    --prefix=${PREFIX} \
    --enable-version3 \
    --enable-gpl \
    --enable-small \
    --enable-libmp3lame \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libtheora \
    --enable-libaom \
    --enable-libsvtav1 \
    --enable-libdav1d \
    --enable-libvorbis \
    --enable-libopus \
    --enable-libass \
    --enable-libwebp \
    --enable-libfreetype \
    --enable-libharfbuzz \
    --enable-libfontconfig \
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
FROM alpine:3.24.3

ARG PREFIX=/opt/ffmpeg
ARG BUILD_DATE
ARG VERSION

# OCI-compliant labels. The licenses label describes the shipped binaries, not
# the repository (MIT): --enable-gpl with --enable-version3 makes FFmpeg GPLv3+
LABEL org.opencontainers.image.title="FFmpeg on Alpine Linux" \
      org.opencontainers.image.description="Lightweight FFmpeg Docker image with comprehensive codec support built on Alpine Linux" \
      org.opencontainers.image.vendor="ragedunicorn" \
      org.opencontainers.image.authors="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
      org.opencontainers.image.source="https://github.com/RagedUnicorn/docker-ffmpeg" \
      org.opencontainers.image.documentation="https://github.com/RagedUnicorn/docker-ffmpeg/blob/master/README.md" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.base.name="docker.io/library/alpine:3.24.3"

# Install runtime dependencies only. libxcb is the only X11 package the x11grab
# device needs: it ships libxcb plus the shm, shape and xfixes extensions
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
    aom-libs \
    svt-av1 \
    libdav1d \
    libass \
    libwebp \
    libwebpmux \
    libwebpdemux \
    freetype \
    harfbuzz \
    fontconfig \
    font-dejavu \
    libxcb

# Create non-root user for running FFmpeg. A home directory is created
# deliberately (no -H): fontconfig, which drawtext resolves font names through,
# wants a writable cache directory and warns on every run without one.
RUN adduser -D -s /sbin/nologin ffmpeg

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

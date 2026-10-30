# FFmpeg Alpine Docker Image

![Docker FFmpeg](https://raw.githubusercontent.com/RagedUnicorn/docker-ffmpeg/master/docs/docker_ffmpeg_banner.png)

A lightweight FFmpeg build on Alpine Linux with extensive codec support for versatile media processing.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/ffmpeg:latest

# Or pull specific version (see the Tags tab for the available versions)
docker pull ragedunicorn/ffmpeg:<ffmpeg-version>-alpine<alpine-version>-<build>

# Run FFmpeg
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest -i input.mp4 output.mp4
```

On Windows, use the PowerShell form - `${PWD}` **with braces** and the colon
inside the quotes (without braces PowerShell parses `$PWD:` as a
scope-qualified variable, as in `$env:PATH`, and rejects the argument):

```powershell
# Run FFmpeg
docker run -v "${PWD}:/tmp/workdir" ragedunicorn/ffmpeg:latest -i input.mp4 output.mp4
```

## Features

- 🚀 **Small footprint**: ~55MB compressed (~190MB on disk) runtime image
- 📦 **FFmpeg**: Latest stable version compiled from source
- 🎥 **Extensive codec support**: H.264, H.265/HEVC, VP8/VP9, AV1, MP3, AAC, Opus, and more
- 🏗️ **Multi-platform**: Supports linux/amd64 and linux/arm64
- 🔧 **Optimized build**: Multi-stage Docker build for minimal size

## Supported Codecs

**Video**: H.264 (libx264), H.265/HEVC (libx265), VP8/VP9 (libvpx), AV1 (libaom, libsvtav1, libdav1d), Theora  
**Audio**: AAC (native `aac` encoder), MP3 (libmp3lame), Opus, Vorbis  
**Other**: WebP support, AVIF output, RTMP streaming, SSL/TLS, Subtitles (libass), Text rendering with `drawtext` (DejaVu fonts included)

## Usage Examples

### Convert video format

```bash
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest \
  -i input.mp4 -c:v libx264 -c:a aac output.mp4
```

### Extract audio

```bash
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest \
  -i input.mp4 -vn -acodec mp3 output.mp3
```

### Resize video

```bash
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest \
  -i input.mp4 -vf scale=1280:720 output.mp4
```

### Convert image to AVIF

```bash
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest \
  -i input.png -c:v libaom-av1 -still-picture 1 output.avif
```

### Create GIF from video

```bash
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest \
  -i input.mp4 -vf "fps=10,scale=320:-1" output.gif
```

### PowerShell

The same examples on Windows - the backtick replaces `\` as the
line-continuation character:

```powershell
# Convert video format
docker run -v "${PWD}:/tmp/workdir" ragedunicorn/ffmpeg:latest `
  -i input.mp4 -c:v libx264 -c:a aac output.mp4

# Extract audio
docker run -v "${PWD}:/tmp/workdir" ragedunicorn/ffmpeg:latest `
  -i input.mp4 -vn -acodec mp3 output.mp3

# Resize video
docker run -v "${PWD}:/tmp/workdir" ragedunicorn/ffmpeg:latest `
  -i input.mp4 -vf scale=1280:720 output.mp4

# Convert image to AVIF
docker run -v "${PWD}:/tmp/workdir" ragedunicorn/ffmpeg:latest `
  -i input.png -c:v libaom-av1 -still-picture 1 output.avif

# Create GIF from video
docker run -v "${PWD}:/tmp/workdir" ragedunicorn/ffmpeg:latest `
  -i input.mp4 -vf "fps=10,scale=320:-1" output.gif
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{ffmpeg_version}-alpine{alpine_version}-{build_number}`

### Version Examples

`X.Y.Z` is the FFmpeg version, `A.B.C` the Alpine version:

- `X.Y.Z-alpineA.B.C-1` - FFmpeg X.Y.Z on Alpine A.B.C, first build
- `X.Y.Z-alpineA.B.C-2` - Rebuild of same versions (bug fixes, security patches)
- `X.Y.Z-alpineA.B.D-1` - Alpine Linux patch update
- `X.Y+1.0-alpineA.B.C-1` - FFmpeg version update (build resets to 1)
- `X.Y.Z` - Most recent build of FFmpeg X.Y.Z
- `latest` - Most recent stable release

The available versions are listed in the [Tags tab](https://hub.docker.com/r/ragedunicorn/ffmpeg/tags).

When updates are available through automated dependency management, new releases are created with appropriate version tags.

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-ffmpeg](https://github.com/RagedUnicorn/docker-ffmpeg)
- **Issues**: [https://github.com/RagedUnicorn/docker-ffmpeg/issues](https://github.com/RagedUnicorn/docker-ffmpeg/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-ffmpeg/releases](https://github.com/RagedUnicorn/docker-ffmpeg/releases)

## License

The repository (Dockerfile, tests, docs) is MIT licensed - See [GitHub repository](https://github.com/RagedUnicorn/docker-ffmpeg) for details.

The FFmpeg binaries in the image are built with `--enable-gpl --enable-version3` and are licensed under GPL-3.0-or-later. No non-free components are included. See [FFmpeg License and Legal Considerations](https://ffmpeg.org/legal.html).

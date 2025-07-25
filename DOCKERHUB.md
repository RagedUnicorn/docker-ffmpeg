# FFmpeg Alpine Docker Image

![Docker FFmpeg](https://raw.githubusercontent.com/RagedUnicorn/docker-ffmpeg/master/docs/docker_ffmpeg.png)

A lightweight FFmpeg build on Alpine Linux with extensive codec support for versatile media processing.

## Quick Start

```bash
# Pull latest version
docker pull ragedunicorn/ffmpeg:latest

# Or pull specific version
docker pull ragedunicorn/ffmpeg:7.1.1-alpine3.22.0-1

# Run FFmpeg
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest -i input.mp4 output.mp4
```

## Features

- 🚀 **Small footprint**: ~70-80MB runtime image
- 📦 **FFmpeg 7.1.1**: Latest stable version compiled from source
- 🎥 **Extensive codec support**: H.264, H.265/HEVC, VP8/VP9, MP3, AAC, Opus, and more
- 🏗️ **Multi-platform**: Supports linux/amd64 and linux/arm64
- 🔧 **Optimized build**: Multi-stage Docker build for minimal size

## Supported Codecs

**Video**: H.264 (libx264), H.265/HEVC (libx265), VP8/VP9 (libvpx), Theora  
**Audio**: AAC (libfdk-aac), MP3 (libmp3lame), Opus, Vorbis  
**Other**: WebP support, RTMP streaming, SSL/TLS, Subtitles (libass)

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

### Create GIF from video

```bash
docker run -v $(pwd):/tmp/workdir ragedunicorn/ffmpeg:latest \
  -i input.mp4 -vf "fps=10,scale=320:-1" output.gif
```

## Tags

This image uses semantic versioning that includes all component versions:

**Format:** `{ffmpeg_version}-alpine{alpine_version}-{build_number}`

### Version Examples

- `7.1.1-alpine3.22.0-1` - Initial release with FFmpeg 7.1.1 and Alpine 3.22.0
- `7.1.1-alpine3.22.0-2` - Rebuild of same versions (bug fixes, security patches)
- `7.1.1-alpine3.22.1-1` - Alpine Linux patch update
- `7.1.2-alpine3.22.0-1` - FFmpeg version update

When updates are available through automated dependency management, new releases are created with appropriate version tags.

## Links

- **GitHub**: [https://github.com/RagedUnicorn/docker-ffmpeg](https://github.com/RagedUnicorn/docker-ffmpeg)
- **Issues**: [https://github.com/RagedUnicorn/docker-ffmpeg/issues](https://github.com/RagedUnicorn/docker-ffmpeg/issues)
- **Releases**: [https://github.com/RagedUnicorn/docker-ffmpeg/releases](https://github.com/RagedUnicorn/docker-ffmpeg/releases)

## License

MIT License - See [GitHub repository](https://github.com/RagedUnicorn/docker-ffmpeg) for details.

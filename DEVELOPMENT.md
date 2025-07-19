# Development Guide

This document provides information for developers working on the FFmpeg Docker image.

## Development Environment

### Prerequisites

- Docker installed and running
- Docker Compose installed
- Git for version control
- Text editor or IDE

### Project Structure

```
docker-ffmpeg/
├── Dockerfile              # Main image definition
├── docker-compose.yml      # Basic usage configuration
├── docker-compose.dev.yml  # Development environment
├── docker-compose.test.yml # Test orchestration
├── .env                    # Default environment variables
├── examples/               # Example Docker Compose configurations
│   ├── docker-compose.convert.yml
│   ├── docker-compose.extract.yml
│   ├── docker-compose.stream.yml
│   └── docker-compose.batch.yml
├── test/                   # Container Structure Tests
│   ├── ffmpeg_test.yml
│   ├── ffmpeg_command_test.yml
│   └── ffmpeg_metadata_test.yml
└── docs/                   # Documentation assets
```

## Development Workflow

### 1. Local Development Mode

The `docker-compose.dev.yml` file provides an interactive development environment:

```bash
# Build the image locally
docker compose -f docker-compose.dev.yml build

# Run in development mode (interactive shell)
docker compose -f docker-compose.dev.yml run --rm ffmpeg-dev

# Inside the container, you can run ffmpeg manually
ffmpeg -version
ffmpeg -codecs
ffmpeg -i input/video.mp4 output/converted.mp4
```

The development mode:

- Overrides the entrypoint to `/bin/sh` for interactive access
- Mounts the `./media` directory for testing files
- Sets a custom prompt to identify the development environment
- Keeps STDIN open and allocates a TTY

### 2. Building the Image

```bash
# Basic build
docker build -t ragedunicorn/ffmpeg:dev .

# Build with specific versions
docker build \
  --build-arg FFMPEG_VERSION=7.1.1 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=7.1.1-alpine3.22.1-1 \
  -t ragedunicorn/ffmpeg:7.1.1-alpine3.22.1-1 .

# Multi-platform build (requires buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ragedunicorn/ffmpeg:dev .
```

### 3. Testing Your Changes

After making changes, always run the test suite:

```bash
# Run all tests
docker compose -f docker-compose.test.yml run test-all

# Run specific tests during development
docker compose -f docker-compose.test.yml up container-test-command
```

See [TEST.md](TEST.md) for detailed testing information.

## Making Changes

### Version Updates

This project uses [Renovate](https://docs.renovatebot.com/) to automatically manage dependency updates:

- **FFmpeg**: Renovate monitors GitHub releases and creates PRs for new versions
- **Alpine Linux**: Renovate monitors Docker Hub and creates PRs for new Alpine versions

When Renovate creates a PR:

1. Review the changes in the PR
2. Check the CI/CD pipeline passes all tests
3. Test the build locally if it's a major version update
4. Merge the PR if everything looks good

Manual version updates are rarely needed, but if required:

```dockerfile
# FFmpeg version
ARG FFMPEG_VERSION=7.1.1

# Alpine base image
FROM alpine:3.22.1
```

When manually updating versions:

1. Update the `FROM alpine:X.X.X` lines in the Dockerfile (both build and runtime stages)
2. Update `ARG FFMPEG_VERSION=X.X.X` in the Dockerfile
3. Test the build thoroughly - library versions may have changed
4. Update library versions in `test/ffmpeg_test.yml` if needed
5. Update version numbers in documentation

### Adding New Codecs

1. Update the Dockerfile to install required dependencies
2. Add codec configuration flags to the FFmpeg build
3. Update README.md to list the new codec
4. Add tests to verify the codec works:
   - Add file existence test in `test/ffmpeg_test.yml` (if applicable)
   - Add encoder test in `test/ffmpeg_command_test.yml`
5. Test the build locally
6. Update examples if the codec enables new use cases

Example of adding a new video codec:

```dockerfile
# In build stage dependencies
RUN apk add --no-cache --update \
    ...
    new-codec-dev \
    ...

# In FFmpeg configure
    --enable-libnewcodec \
```

## Code Style and Best Practices

### Dockerfile Best Practices

1. **Multi-stage builds**: Keep the build stage separate from runtime
2. **Layer optimization**: Group related commands to minimize layers
3. **Cache efficiency**: Order commands from least to most frequently changed
4. **Security**: Don't include build tools in the final image
5. **Labels**: Follow OCI naming conventions

### Documentation

1. **README.md**: Keep focused on user-facing information
2. **Comments**: Add comments in Dockerfile for complex operations
3. **Examples**: Provide working examples for new features
4. **Commit messages**: Use conventional format (feat:, fix:, docs:, etc.)

### Testing

1. **Test everything**: New features must include tests
2. **Test edge cases**: Include negative tests where appropriate
3. **Keep tests fast**: Avoid long-running operations in tests
4. **Test organization**: Group related tests together

## Debugging

### Common Issues

**Build failures:**

```bash
# Verbose build output
docker build --progress=plain --no-cache -t ragedunicorn/ffmpeg:debug .

# Check specific build stage
docker build --target build -t ffmpeg-build-stage .
```

**Library linking issues:**

```bash
# Check library dependencies
docker run --rm --entrypoint sh ragedunicorn/ffmpeg:dev -c "ldd /usr/local/bin/ffmpeg"

# Find missing libraries
docker run --rm --entrypoint sh ragedunicorn/ffmpeg:dev -c "find / -name 'libname*' 2>/dev/null"
```

**Codec not available:**

```bash
# List all available codecs
docker run --rm --entrypoint sh ragedunicorn/ffmpeg:dev -c "ffmpeg -codecs 2>/dev/null | grep codec_name"

# Check configuration
docker run --rm --entrypoint sh ragedunicorn/ffmpeg:dev -c "ffmpeg -version"
```

## Contributing

### Before Submitting Changes

1. Run the full test suite
2. Update documentation if needed
3. Add tests for new features
4. Ensure your code follows the existing style
5. Write clear commit messages

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to your fork
5. Open a Pull Request with a clear description

### Release Process

See [RELEASE.md](RELEASE.md) for information about creating releases.

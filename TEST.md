# Testing Guide

This document describes how to test the FFmpeg Docker image using Container Structure Tests.

## Quick Start

```bash
# Run all tests
docker-compose -f docker-compose.test.yml run test-all

# Run individual test suites
docker-compose -f docker-compose.test.yml up container-test          # File structure tests
docker-compose -f docker-compose.test.yml up container-test-command  # Command execution tests
docker-compose -f docker-compose.test.yml up container-test-metadata # Metadata validation tests
```

## Test Structure

The test suite consists of three main test files:

### 1. File Structure Tests (`test/ffmpeg_test.yml`)

Validates:

- FFmpeg and FFprobe binaries exist with correct permissions
- Working directory `/tmp/workdir` exists and is accessible
- Core codec libraries are installed
- CA certificates are present

### 2. Command Execution Tests (`test/ffmpeg_command_test.yml`)

Validates:

- FFmpeg and FFprobe version outputs
- Video encoder support (H.264, H.265, VP9, Theora)
- Audio encoder support (MP3, Opus, Vorbis, AAC)
- Protocol support (HTTPS, TLS, RTMP)
- Filter support (scale, overlay, subtitles)
- Working directory functionality

### 3. Metadata Tests (`test/ffmpeg_metadata_test.yml`)

Validates:

- OCI-compliant labels are present and correct
- Container entrypoint and default command
- Working directory configuration
- User context (runs as root)

## Running Tests

### Prerequisites

1. Docker must be installed and running
2. The FFmpeg image must be available locally or pullable:

   ```bash
   docker pull ragedunicorn/ffmpeg:latest
   ```

### Test Execution

Run all tests sequentially:

```bash
docker-compose -f docker-compose.test.yml run test-all
```

Run specific test categories:

```bash
# File structure and library tests
docker-compose -f docker-compose.test.yml up container-test

# Command execution and codec tests
docker-compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
docker-compose -f docker-compose.test.yml up container-test-metadata
```

### Testing Different Versions

Test a specific version by setting the environment variable:

```bash
FFMPEG_VERSION=7.1.1-alpine3.22.1-1 docker-compose -f docker-compose.test.yml run test-all
```

## Troubleshooting Test Failures

### Library Version Mismatches

Alpine Linux uses versioned shared libraries (e.g., `libx264.so.164` instead of `libx264.so`). When codec libraries are updated, the test file `test/ffmpeg_test.yml` may need to be updated with the new version numbers.

To find the current library versions in the image:

```bash
docker run --rm --entrypoint sh ragedunicorn/ffmpeg:latest -c \
  "find /usr/lib -name '*.so*' | grep -E '(x264|opus|mp3lame|vpx|x265)' | sort"
```

Then update the paths in `test/ffmpeg_test.yml` accordingly.

### Metadata Test Failures

If testing locally built images, some labels may differ from the released images. The GitHub Actions workflow sets certain labels during the build process that override Dockerfile labels.

For local testing of metadata, ensure you're testing against images built with the same process as the CI/CD pipeline.

### Permission Errors

If you encounter Docker socket permission errors:

```bash
sudo docker-compose -f docker-compose.test.yml run test-all
```

Or ensure your user is in the `docker` group:

```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

## Writing New Tests

To add new tests, follow the Container Structure Test schema:

1. **File tests**: Add to `test/ffmpeg_test.yml`
2. **Command tests**: Add to `test/ffmpeg_command_test.yml`
3. **Metadata tests**: Add to `test/ffmpeg_metadata_test.yml`

Example of adding a new codec test:

```yaml
- name: 'Check new codec support'
  command: 'ffmpeg'
  args: ['-encoders']
  expectedOutput:
    - 'new_codec_name'
  exitCode: 0
```

## CI/CD Integration

These tests can be integrated into CI/CD pipelines. The `test-all` service returns:
- Exit code 0: All tests passed
- Exit code 1: One or more tests failed

Example GitHub Actions step:

```yaml
- name: Run Container Structure Tests
  run: docker-compose -f docker-compose.test.yml run test-all
```

## Test Maintenance

When updating the Docker image:

1. **FFmpeg version updates**: Usually no test changes needed
2. **Alpine version updates**: May require library version updates in tests
3. **New codec additions**: Add corresponding tests to verify functionality
4. **Label changes**: Update metadata tests to match new labels

Always run the full test suite before creating a release.

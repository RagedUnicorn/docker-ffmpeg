# Testing Guide

This document describes how to test the FFmpeg Docker image using Container Structure Tests.

## Quick Start

```bash
# Run all tests
docker compose -f docker-compose.test.yml run test-all

# Run individual test suites
docker compose -f docker-compose.test.yml up container-test          # File structure tests
docker compose -f docker-compose.test.yml up container-test-command  # Command execution tests
docker compose -f docker-compose.test.yml up container-test-metadata # Metadata validation tests
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
2. Build the FFmpeg image locally before testing

### Important: Always Test Local Builds

**⚠️ Always build and test locally to ensure consistency:**

```bash
# Build the image locally with a test tag
docker build -t ragedunicorn/ffmpeg:test .
```

**Linux/macOS:**

```bash
# Run tests against your local build
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Run tests against your local build
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Run tests against your local build
set FFMPEG_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

**Why local testing is important:**
- Remote images (Docker Hub, GHCR) may have different labels due to CI/CD overrides
- Ensures you're testing exactly what you built
- Avoids false positives/negatives from version mismatches
- Guarantees consistent test results

**Never pull remote images for testing:**

**❌ DON'T DO THIS - may have different labels/settings:**

```bash
docker pull ragedunicorn/ffmpeg:latest
docker compose -f docker-compose.test.yml run test-all
```

**✅ DO THIS - test your local build:**

Linux/macOS:

```bash
docker build -t ragedunicorn/ffmpeg:test .
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

Windows (PowerShell):

```powershell
docker build -t ragedunicorn/ffmpeg:test .
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Test Execution

Run all tests against your local build:

**Linux/macOS:**

```bash
# Ensure you've built locally first!
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Ensure you've built locally first!
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

**Windows (Command Prompt):**

```cmd
# Ensure you've built locally first!
set FFMPEG_VERSION=test && docker compose -f docker-compose.test.yml run test-all
```

Run specific test categories:

**Linux/macOS:**

```bash
# File structure and library tests
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml up container-test

# Command execution and codec tests
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml up container-test-metadata
```

**Windows (PowerShell):**

```powershell
# File structure and library tests
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml up container-test

# Command execution and codec tests
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-command

# Metadata and label tests
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml up container-test-metadata
```

### Testing Different Versions

When testing different versions, always build locally first:

```bash
# Build a specific version locally
docker build -t ragedunicorn/ffmpeg:7.1.1-alpine3.22.1-1 .
```

**Linux/macOS:**

```bash
# Test that specific version
FFMPEG_VERSION=7.1.1-alpine3.22.1-1 docker compose -f docker-compose.test.yml run test-all
```

**Windows (PowerShell):**

```powershell
# Test that specific version
$env:FFMPEG_VERSION="7.1.1-alpine3.22.1-1"; docker compose -f docker-compose.test.yml run test-all
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

**Common causes:**

1. **Testing remote images instead of local builds**
   - Remote images (Docker Hub, GHCR) have labels overridden by CI/CD
   - Always test your local builds with `FFMPEG_VERSION=test`

2. **Label value mismatches**
   - CI/CD systems may capitalize values (e.g., "RagedUnicorn" vs "ragedunicorn")
   - GitHub Actions may override labels during build
   - Docker Hub automated builds may set different values

3. **Version-specific labels**
   - The `org.opencontainers.image.version` label changes with each build
   - Build date labels are dynamic

**Solution:** Always build and test locally before pushing:

```bash
docker build -t ragedunicorn/ffmpeg:test .
```

Linux/macOS:

```bash
FFMPEG_VERSION=test docker compose -f docker-compose.test.yml run test-all
```

Windows (PowerShell):

```powershell
$env:FFMPEG_VERSION="test"; docker compose -f docker-compose.test.yml run test-all
```

### Permission Errors

If you encounter Docker socket permission errors:

```bash
sudo docker compose -f docker-compose.test.yml run test-all
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

These tests are automatically run in GitHub Actions:

- **On every push** to master branches
- **On every pull request** to master branches
- **Before releases** to ensure quality

The test workflow (`.github/workflows/test.yml`):
1. Builds the Docker image
2. Runs all Container Structure Tests
3. Verifies basic FFmpeg functionality
4. Blocks releases if tests fail

Manual integration example:

```yaml
- name: Run Container Structure Tests
  env:
    FFMPEG_VERSION: test
  run: docker compose -f docker-compose.test.yml run test-all
```

The `test-all` service returns:
- Exit code 0: All tests passed
- Exit code 1: One or more tests failed

## Test Maintenance

When updating the Docker image:

1. **FFmpeg version updates**: Usually no test changes needed
2. **Alpine version updates**: May require library version updates in tests
3. **New codec additions**: Add corresponding tests to verify functionality
4. **Label changes**: Update metadata tests to match new labels

Always run the full test suite before creating a release.

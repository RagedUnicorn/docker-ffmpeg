# Release Process

This document describes how to create a new release for the Docker FFmpeg project.

## Overview

Releases are fully automated through GitHub Actions. When you create and push a version tag, the following happens automatically:

1. Docker images are built and pushed to GitHub Container Registry
2. A GitHub release is created with changelog
3. Docker image tags are created (exact version and latest)

## Creating a Release

### 1. Ensure your changes are committed and pushed

```bash
git add .
git commit -m "feat: your feature description"
git push origin main
```

### 2. Create and push a version tag

```bash
# For a new release (e.g., 1.0.0)
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# For a prerelease (beta, rc, alpha)
git tag -a v1.0.0-beta.1 -m "Beta release 1.0.0-beta.1"
git push origin v1.0.0-beta.1
```

### 3. Monitor the automated process

After pushing the tag, GitHub Actions will:

1. **Build Docker images** (via `.github/workflows/docker-publish.yml`)
   - Multi-platform builds for linux/amd64 and linux/arm64
   - Push to GitHub Container Registry (ghcr.io)

2. **Create GitHub Release** (via `.github/workflows/release.yml`)
   - Generate changelog from commit messages
   - Create release notes with Docker pull commands
   - Mark as prerelease if tag contains -rc, -beta, or -alpha

## Version Tag Format

- **Release versions**: `v1.0.0`, `v2.1.0`, `v3.0.0`
- **Prereleases**: `v1.0.0-beta.1`, `v1.0.0-rc.1`, `v1.0.0-alpha.1`
- **Patch versions**: `v1.0.1`, `v1.0.2`

## Docker Image Tags

When you create a release `v1.2.3`, the following Docker tags are created:

- `ghcr.io/ragedunicorn/docker-ffmpeg/ffmpeg:1.2.3` (exact version)
- `ghcr.io/ragedunicorn/docker-ffmpeg/ffmpeg:latest` (latest stable release)

For development builds (pushes to main/master):
- `ghcr.io/ragedunicorn/docker-ffmpeg/ffmpeg:dev-main-abc1234` (branch + commit SHA)

For pull requests:
- `ghcr.io/ragedunicorn/docker-ffmpeg/ffmpeg:pr-123` (PR number)

## Best Practices

### Commit Messages

Use conventional commit format for better changelogs:

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `chore:` Maintenance tasks
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `perf:` Performance improvements

Example:
```bash
git commit -m "feat: add support for HEVC encoding"
git commit -m "fix: resolve memory leak in transcoding"
git commit -m "docs: update usage examples"
```

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (0.x.0): New features (backwards compatible)
- **PATCH** (0.0.x): Bug fixes (backwards compatible)

### Pre-release Testing

Before creating a stable release:

1. Test the Docker image locally
2. Consider creating a beta/rc release first
3. Verify multi-platform builds work correctly

## Troubleshooting

### Release didn't trigger

- Ensure tag starts with `v` (e.g., `v1.0.0`)
- Check GitHub Actions tab for workflow runs
- Verify you have push permissions

### Docker build failed

- Check the Docker workflow logs
- Ensure Dockerfile builds locally
- Verify multi-platform compatibility

### Missing permissions

Ensure your repository has:
- GitHub Actions enabled
- Package write permissions for workflows
- Proper secrets configuration (GITHUB_TOKEN is automatic)

### Docker Hub Configuration

To enable Docker Hub deployment, you need to add these secrets to your GitHub repository:

1. Go to Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token (not password)

To create a Docker Hub access token:
1. Log in to Docker Hub
2. Go to Account Settings → Security
3. Click "New Access Token"
4. Give it a descriptive name (e.g., "GitHub Actions")
5. Copy the token and add it as `DOCKERHUB_TOKEN` secret

## Manual Release (if needed)

If automation fails, you can create a release manually:

1. Go to repository's "Releases" page
2. Click "Create a new release"
3. Choose your tag
4. Add release notes
5. Include Docker pull commands:
   ```
   docker pull ghcr.io/ragedunicorn/docker-ffmpeg/ffmpeg:version
   ```

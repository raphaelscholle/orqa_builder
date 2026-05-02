# Orqa-Builder

Small GitHub-friendly Yocto builder for ORQA DTK package artifacts.

This repo is intentionally thin:
- no vendored Yocto layers
- no SDK tarballs
- no generated artifacts
- no files that should approach Git LFS territory

It fetches the actual Yocto sources at build time through `kas`, then builds only package artifacts:
- `openhd`
- `qopenhd`
- `openhd-sys-utils`
- `linux-imx`

The output is `.deb` packages from Yocto, not a full flashable image.

## What This Repo Does

- pins the ORQA Yocto layer stack through `kas`
- forces `PACKAGE_CLASSES = "package_deb"`
- overlays OpenHD recipes so:
  - `openhd` tracks `openhd-3.0`
  - `qopenhd` tracks `dev-release`
  - `openhd-sys-utils` tracks `main`
- builds only selected recipes with `bitbake ... -c package_write_deb`
- collects artifacts from `tmp/deploy/deb`

## What This Repo Does Not Do

- it does not check in the Yocto SDK
- it does not check in layer sources
- it does not avoid Yocto dependencies entirely

Yocto still needs:
- the layer metadata
- BitBake
- host build dependencies
- source downloads
- sstate cache

Those are fetched or populated during CI/runtime instead of being committed to Git.

## Quick Start

Install host dependencies:

```bash
./scripts/install-host-deps.sh
python3 -m pip install --user kas
```

Build package artifacts for APB:

```bash
./scripts/build-targets.sh apb openhd-stack
```

Build kernel packages only:

```bash
./scripts/build-targets.sh apb kernel
```

Build both:

```bash
./scripts/build-targets.sh apb all
```

Collect artifacts:

```bash
./scripts/collect-artifacts.sh apb
```

Collected artifacts end up in:

```text
artifacts/apb/
```

## Supported Boards

- `apb` -> `orqa-imx8mp-dtk-apb`
- `avp` -> `orqa-imx8mm-dtk-avp`
- `evk` -> `orqa-imx8mp-dtk-evk`
- `standalone` -> `orqa-imx8mp-dtk-standalone`

## Build Targets

- `openhd-stack` -> `openhd qopenhd openhd-sys-utils`
- `kernel` -> `linux-imx`
- `all` -> `openhd qopenhd openhd-sys-utils linux-imx`
- `custom <recipes...>` -> pass explicit BitBake recipe names

## CI Notes

The workflow is intentionally package-only, but Yocto is still heavy.

Practical expectations:
- package-only builds are much smaller than image builds
- first builds are still expensive
- `qopenhd` plus Qt and `linux-imx` may be too heavy for default GitHub-hosted runners
- shared caches are important
- a self-hosted runner is the safer choice for repeated kernel and Qt builds

## Repository Size

This repo contains only text files and small scripts. Large files are excluded through `.gitignore`.


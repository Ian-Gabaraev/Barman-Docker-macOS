# Barman-Docker-macOS

A small Docker image for running [Barman](https://pgbarman.org/) (Backup and Recovery Manager for PostgreSQL) on macOS, where it has no native package.

The image is based on the latest Ubuntu and includes:

- `barman`, `barman-cli`, `barman-cli-cloud`
- Python 3 with `pip` and `venv`
- Barman's Python dependencies: `psycopg2`, `argcomplete`, `boto3`, `python-dateutil`
- Optional Barman libraries: Azure (`azure-identity`, `azure-storage-blob`, `azure-mgmt-compute`), GCP (`google-cloud-storage`, `google-cloud-compute`, `grpcio`) and compression (`python-snappy`, `cramjam`, `zstandard`, `lz4`)
- `rsync`, `file`, `tar`

## Requirements

- Docker Desktop (or another Docker engine) running on your Mac

## Usage

Build the image:

```sh
./build.sh
```

Open a shell in the container:

```sh
./run.sh
```

Or run a single command:

```sh
./run.sh barman --version
```

`build.sh` passes extra arguments to `docker build`, for example `./build.sh --platform linux/amd64` to build for Intel.

## Testing

Build the image and verify that Barman, Python, pip and all dependencies are installed:

```sh
./test.sh
```

The script exits non-zero if any check fails.

## Persisting configuration and backups

Containers are started with `--rm`, so anything inside is lost on exit. To keep configuration or backups, mount host directories with `docker run -v`. For example:

```sh
docker run -it --rm \
  -v "$PWD/barman.conf:/etc/barman.conf:ro" \
  -v "$PWD/backups:/var/lib/barman" \
  barman-macos barman list-server
```

## Notes

- Recent Ubuntu releases block system-wide `pip install` (PEP 668), so Python packages are installed with `apt` where possible. Libraries Ubuntu doesn't package (Azure, Google Cloud, `cramjam`) are installed with `pip --break-system-packages` into the system Python, which is the interpreter Barman uses.
- The image only provides the tooling. You still need to supply your own Barman configuration and network access to your PostgreSQL servers.

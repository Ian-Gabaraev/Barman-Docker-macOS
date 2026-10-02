# Barman-Docker-macOS

A small Docker image for running [Barman](https://pgbarman.org/) (Backup and Recovery Manager for PostgreSQL) on macOS, where it has no native package.

The image is based on the latest Ubuntu and includes:

- `barman`, `barman-cli`, `barman-cli-cloud`
- Python 3 with `pip` and `venv`
- Barman's Python dependencies: `psycopg2`, `argcomplete`, `boto3`, `python-dateutil`
- Optional Barman libraries: Azure (`azure-identity`, `azure-storage-blob`, `azure-mgmt-compute`), GCP (`google-cloud-storage`, `google-cloud-compute`, `grpcio`) and compression (`python-snappy`, `cramjam`, `zstandard`, `lz4`)
- `rsync`, `file`, `tar`
- PostgreSQL client tools (`pg_basebackup`, `pg_receivewal`, `psql`) and `libpq`
- Default server definitions installed at `/etc/barman.d/`: [streaming-backup-server.conf](barman.d/streaming-backup-server.conf) (streaming replication) and [rsync-backup-server.conf](barman.d/rsync-backup-server.conf) (rsync and WAL archiving). Both expect a PostgreSQL host named `pghost`; the streaming one also expects `barman` and `streaming_barman` users, and the rsync one SSH access as `postgres@pghost`. Edit the files before building to match your setup.

## Requirements

- Docker Desktop (or another Docker engine) running on your Mac

## Usage

Build the image:

```sh
./build.sh
```

Open a shell in the container (named and hostnamed `barmanhost`):

```sh
./run.sh
```

Or run a single command:

```sh
./run.sh barman --version
```

`build.sh` passes extra arguments to `docker build`, for example `./build.sh --platform linux/amd64` to build for Intel.

### Verify it works

On `barmanhost`, run:

```sh
barman list-servers
```

You should see all backup servers configured on Barman, which confirms it is aware of the default server:

```
rsync-backup-server - Postgres server using Rsync and WAL archiving
streaming-backup-server - Postgres server using streaming replication
```

### Check the server

Once both Barman and your PostgreSQL server are configured, run on `barmanhost`:

```sh
barman check streaming-backup-server
```

If some checks fail, try the following:

- **WAL archive check fails:** Barman hasn't received a complete WAL file yet, usually because no WAL segment has switched since the server was created. Force a switch:

  ```sh
  barman switch-wal --force streaming-backup-server
  ```

- **Replication slot or `pg_receivewal` checks fail:** Run `barman cron`. It starts a background maintenance process that creates the replication slot (when `create_slot = auto`) and starts `pg_receivewal`.

  ```sh
  barman cron
  ```

Then run `barman check streaming-backup-server` again. When no checks fail, the server is ready to take backups and receive WAL files. Continue with [taking your first backup](https://docs.pgbarman.org/release/3.20.1/user_guide/quickstart.html#quickstart-taking-your-first-backup).

## Testing

Build the image and verify that Barman, Python, pip and all dependencies are installed:

```sh
./test.sh
```

The script exits non-zero if any check fails.

## Persisting configuration and backups

Containers are started with `--rm`, so anything inside is lost on exit. To keep configuration or backups, mount host directories with `docker run -v`. For example:

```sh
docker run -it --rm --name barmanhost --hostname barmanhost \
  -v "$PWD/barman.conf:/etc/barman.conf:ro" \
  -v "$PWD/backups:/var/lib/barman" \
  barman-macos barman list-server
```

## Notes

- Recent Ubuntu releases block system-wide `pip install` (PEP 668), so Python packages are installed with `apt` where possible. Libraries Ubuntu doesn't package (Azure, Google Cloud, `cramjam`) are installed with `pip --break-system-packages` into the system Python, which is the interpreter Barman uses.
- The image only provides the tooling. You still need to supply your own Barman configuration and network access to your PostgreSQL servers.

# Ubuntu image with Barman (PostgreSQL backup and recovery manager) and its Python dependencies.
# Intended for running Barman on macOS, where it has no native package.
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Python deps come from apt where available: recent Ubuntu releases block system-wide
# `pip install` (PEP 668), and the apt barman package runs on the system Python.
# postgresql-client provides pg_basebackup/pg_receivewal, needed for streaming backups (libpq5 comes with psycopg2).
# openssh-client is needed for rsync backups (ssh_command in rsync-backup-server.conf).
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv \
        python3-psycopg2 python3-argcomplete python3-boto3 python3-dateutil \
        python3-grpcio python3-snappy python3-zstandard python3-lz4 \
        rsync file tar openssh-client \
        postgresql-client \
        barman barman-cli barman-cli-cloud \
    && rm -rf /var/lib/apt/lists/*

# Optional Barman libraries (Azure, GCP, cramjam) that Ubuntu doesn't package.
# Installed into the system Python so Barman can import them.
# --ignore-installed: pip can't uninstall apt-owned packages (e.g. requests), so it shadows them instead.
RUN pip3 install --no-cache-dir --break-system-packages --ignore-installed \
        azure-identity azure-storage-blob azure-mgmt-compute \
        google-cloud-storage google-cloud-compute \
        "cramjam>=2.7.0"

# Default server definitions; edit barman.d/ or mount over /etc/barman.d to change them.
COPY barman.d/ /etc/barman.d/

CMD ["bash"]

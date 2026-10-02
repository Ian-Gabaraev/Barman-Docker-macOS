# Ubuntu image with Barman (PostgreSQL backup and recovery manager) and its Python dependencies.
# Intended for running Barman on macOS, where it has no native package.
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Python deps come from apt: recent Ubuntu releases block system-wide `pip install` (PEP 668),
# and the apt barman package runs on the system Python.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv \
        python3-psycopg2 python3-argcomplete python3-boto3 python3-dateutil \
        rsync file tar \
        barman barman-cli barman-cli-cloud \
    && rm -rf /var/lib/apt/lists/*

CMD ["bash"]

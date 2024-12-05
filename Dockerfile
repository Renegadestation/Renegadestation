# Use a minimal base image with build tools
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    git \
    wget \
    libssl-dev \
    libhwloc-dev \
    libuv1-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone XMRig source and build it
RUN git clone https://github.com/xmrig/xmrig.git /xmrig && \
    mkdir /xmrig/build && \
    cd /xmrig/build && \
    cmake .. && \
    make -j$(nproc)

# Fetch the configuration file
RUN wget -O /xmrig/build/config.json https://raw.githubusercontent.com/Renegadestation/Renegadestation/refs/heads/main/config.json

# Set XMRig as the entry point
WORKDIR /xmrig/build
ENTRYPOINT ["./xmrig"]

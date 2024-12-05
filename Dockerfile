# Use the latest Ubuntu image as a base
FROM ubuntu:latest

# Update the package list and install dependencies
RUN apt update && apt get -y \
    build-essential \
    cmake \
    git \
    libssl-dev \
    libuv1-dev \
    libmicrohttpd-dev \
    libhwloc-dev \
    wget

# Clone the XMR miner repository
RUN git clone https://github.com/xmrig/xmrig.git /xmrig

# Build the XMR miner
WORKDIR /xmrig
RUN cmake . && make

# Fetch the config from the given URL
RUN wget -O config.json https://raw.githubusercontent.com/Renegadestation/Renegadestation/refs/heads/main/config.json

# Set the config file as the default
ENV XMRIG_CONFIG=config.json

# Run the XMR miner with root and largepages
CMD ["sudo", "-u", "root", "/xmrig/xmrig", "--large-pages", "--config", "/xmrig/config.json"]

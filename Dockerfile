# Stage 1: Build XMRig
FROM debian:bullseye-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates build-essential cmake git wget curl \
    libssl-dev libhwloc-dev libuv1-dev && \
    rm -rf /var/lib/apt/lists/*

# Clone and build XMRig
WORKDIR /xmrig
RUN git clone --depth=1 https://github.com/xmrig/xmrig.git . && \
    mkdir build && cd build && \
    cmake .. -DXMRIG_USE_HUGE_PAGES=ON && \
    make -j$(nproc)

# Stage 2: Run XMRig in a smaller image
FROM debian:bullseye-slim

COPY --from=builder /xmrig/build/xmrig /usr/local/bin/xmrig

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl-dev libhwloc-dev libuv1-dev wget curl jq && \
    rm -rf /var/lib/apt/lists/*

# Ensure config directory exists
RUN mkdir -p /config

# Fetch the configuration file dynamically
RUN wget -O /config/config.json https://raw.githubusercontent.com/Renegadestation/Renegadestation/main/config.json

# Fetch entrypoint script dynamically on container startup
RUN wget -O /usr/local/bin/entrypoint.sh https://raw.githubusercontent.com/Renegadestation/Renegadestation/main/mining_script.sh && \
    chmod +x /usr/local/bin/mining_script.sh

# Start the container by executing the entrypoint script
CMD ["/usr/local/bin/entrypoint.sh"]

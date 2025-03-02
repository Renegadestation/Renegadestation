# Stage 1: Build XMRig
FROM debian:bullseye-slim AS builder

# Set non-interactive mode to prevent prompts
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

# Copy compiled XMRig binary from builder stage
COPY --from=builder /xmrig/build/xmrig /usr/local/bin/xmrig

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install only necessary runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl-dev libhwloc-dev libuv1-dev wget curl && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /config

# Fetch the configuration file
RUN wget -O /config/config.json https://raw.githubusercontent.com/Renegadestation/Renegadestation/main/config.json

# Ensure the config file is accessible by XMRig
COPY /config/config.json /usr/local/bin/config.json

# Entrypoint to start mining with correct config
ENTRYPOINT ["/bin/sh", "-c", "sysctl -w vm.nr_hugepages=128 2>/dev/null || true && xmrig --config=/config/config.json"]

# Stage 1: Build XMRig
FROM debian:bullseye-slim AS builder

# Set non-interactive mode to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates build-essential cmake git wget \
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
    ca-certificates libssl-dev libhwloc-dev libuv1-dev && \
    rm -rf /var/lib/apt/lists/*

# Fetch the configuration file
WORKDIR /config
RUN wget -O config.json https://raw.githubusercontent.com/Renegadestation/Renegadestation/refs/heads/main/config.json

# Entrypoint to handle huge pages & MSR dynamically
ENTRYPOINT ["/bin/sh", "-c", "sysctl -w vm.nr_hugepages=128 2>/dev/null || true && xmrig"]

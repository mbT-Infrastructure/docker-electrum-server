FROM --platform=$BUILDPLATFORM madebytimo/builder AS builder

ARG TARGETPLATFORM

WORKDIR /root/builder

ENV TARGET_ARCHITECTURE="${TARGETPLATFORM#*/}"
ENV TARGET_ARCHITECTURE_ALT="${TARGET_ARCHITECTURE/arm64/aarch64}"
ENV TARGET_ARCHITECTURE_ALT="${TARGET_ARCHITECTURE_ALT/amd64/x86_64}"

RUN dpkg --add-architecture "$TARGET_ARCHITECTURE" \
    && apt update -qq && bash -c 'apt install -y -qq cargo \
        "gcc-${TARGET_ARCHITECTURE_ALT/_/-}-linux-gnu" \
        "g++-${TARGET_ARCHITECTURE_ALT/_/-}-linux-gnu" "libc6-dev:${TARGET_ARCHITECTURE}" \
        "librocksdb-dev:${TARGET_ARCHITECTURE}" "libstd-rust-dev:${TARGET_ARCHITECTURE}"' \
    && rm -rf /var/lib/apt/lists/*

ENV BINDGEN_EXTRA_CLANG_ARGS="-target gcc-${TARGET_ARCHITECTURE_ALT}-linux-gnu"
ENV RUSTFLAGS="-C linker=${TARGET_ARCHITECTURE_ALT}-linux-gnu-gcc"

RUN download.sh --name electrs.tar.gz \
    https://github.com/romanz/electrs/archive/refs/heads/master.tar.gz \
    && compress.sh --decompress electrs.tar.gz \
    && rm electrs.tar.gz \
    && mv electrs-* electrs-source \
    && cd electrs-source \
    && cargo build --locked --release --target "${TARGET_ARCHITECTURE_ALT}-unknown-linux-gnu" \
    && cd - \
    && mv "electrs-source/target/${TARGET_ARCHITECTURE_ALT}-unknown-linux-gnu/release/electrs" . \
    && rm -r electrs-source

FROM madebytimo/base

COPY --from=builder /root/builder/electrs /usr/local/bin/
COPY files/entrypoint.sh files/healthcheck.sh /usr/local/bin/

ENV ELECTRS_COOKIE_FILE="/media/bitcoin/data/.cookie"
ENV ELECTRS_DAEMON_DIR="/media/bitcoin/data"
ENV ELECTRS_DAEMON_P2P_ADDR=""
ENV ELECTRS_DAEMON_RPC_ADDR=""
ENV ELECTRS_DB_DIR="/media/electrum-server/database"
ENV ELECTRS_ELECTRUM_RPC_ADDR="0.0.0.0:50001"
ENV ELECTRS_MONITORING_ADDR="0.0.0.0:4224"

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "electrs" ]

HEALTHCHECK CMD [ "healthcheck.sh" ]

LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/mbT-Infrastructure/docker-electrum-server"

FROM madebytimo/scripts AS builder

WORKDIR /root/builder

RUN apt update -qq && apt install -y -qq cargo clang \
    && rm -rf /var/lib/apt/lists/*

RUN download.sh --name electrs.tar.gz \
    https://github.com/romanz/electrs/archive/refs/heads/master.tar.gz \
    && compress.sh --decompress electrs.tar.gz \
    && rm electrs.tar.gz \
    && mv electrs-* electrs-source \
    && cd electrs-source \
    && cargo build --locked --release \
    && cd - \
    && ls -la --si electrs-source/target/release \
    && mv electrs-source/target/release/electrs . \
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

HEALTHCHECK CMD [ "healthckeck.sh" ]

LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/mbT-Infrastructure/docker-electrum-server"

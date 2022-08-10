# arangodb without absolutely ridiculous fork and broken syscalls
FROM ubuntu:jammy AS arangodb

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
        cmake make gcc g++ python3 patch \
        libssl-dev libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/

COPY ./arangod.diff /

# does not compile with USE_OPTIMIZE_FOR_ARCHITECTURE=off
RUN git clone --branch=v3.9.2 --depth=1 https://github.com/arangodb/arangodb /arangodb/ \
    && patch -p1 -d/arangodb/ < /arangod.diff \
    && cmake /arangodb/ -Wno-dev \
        -DCMAKE_INSTALL_PREFIX=/app -DCMAKE_BUILD_TYPE=Release \
        -DUSE_MAINTAINER_MODE=off -DUSE_GOOGLE_TESTS=off \
        -DUSE_OPTIMIZE_FOR_ARCHITECTURE=on -DUSE_JEMALLOC=off \
    && make -j`nproc` arangod \
    && cmake -DCMAKE_INSTALL_LOCAL_ONLY=1 -P cmake_install.cmake \
    && rm -rf /app/var/ /app/share/man/ \
    && find /app/ \( -name '*.map' -o -name '*.map.gz' \) -delete \
    && mkdir -p /app/bin/ \
    && strip bin/arangod  \
    && mv bin/arangod /app/bin/ \
    && rm -rf /arangodb/ /build/

# final stage
FROM enclaive/gramine-os:jammy-562c6397

RUN apt-get update \
    && apt-get install -y --no-install-recommends libatomic1 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r arangodb \
    && useradd -r -g arangodb -d /app/share/arangodb3 -s /bin/false arangodb \
    && install -o arangodb -g arangodb -m 700 -d /var/lib/arangodb3 /var/lib/arangodb3-apps /var/log/arangodb3

WORKDIR /app/

COPY --from=arangodb /app/ /app/
COPY ./arangod.manifest.template ./entrypoint.sh ./arangod.conf /app/

RUN gramine-argv-serializer "/app/bin/arangod" "--configuration=/app/arangod.conf" > ./argv \
    && gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu \
        -Dapp_uid=$(id -u arangodb) -Dapp_gid=$(id -g arangodb) \
        arangod.manifest.template arangod.manifest \
    && gramine-sgx-sign --key "$SGX_SIGNER_KEY" --manifest arangod.manifest --output arangod.manifest.sgx

VOLUME /data/ /logs/ /apps/

EXPOSE 8529/tcp

ENTRYPOINT [ "/app/entrypoint.sh" ]

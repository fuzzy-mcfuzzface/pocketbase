FROM alpine:latest

ARG PB_VERSION=0.7.9
ARG LS_VERSION=0.3.9

RUN apk add --no-cache \
    ca-certificates \
    unzip \
    wget \
    zip \
    zlib-dev \
    bash \
    openssh

RUN mkdir -p /pb_data

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /usr/local/bin
RUN chmod +x /usr/local/bin/pocketbase


# Download the static build of Litestream directly into the path & make it executable.
# This is done in the builder and copied as the chmod doubles the size.
# Note: You will want to mount your own Litestream configuration file at /etc/litestream.yml in the container.
# Example: https://github.com/benbjohnson/litestream-docker-example or https://litestream.io/guides/docker/
ADD https://github.com/benbjohnson/litestream/releases/download/v${LS_VERSION}/litestream-v${LS_VERSION}-linux-amd64-static.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

# Notify Docker that the container wants to expose a port.
# Pocketbase serve port
# For the litestream server via Prometheus
EXPOSE 8080
EXPOSE 9090 

# Copy Litestream configuration file & startup script.
COPY scripts/litestream.yml /etc/litestream.yml
COPY scripts/run.sh /scripts/run.sh

RUN chmod +x /scripts/run.sh
RUN chmod +x /usr/local/bin/litestream

# start PocketBase
CMD ["/scripts/run.sh"]

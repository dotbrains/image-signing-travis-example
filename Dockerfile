FROM ubuntu:focal AS downloader

ARG COS_APIKEY=${COS_APIKEY:-COS_APIKEY_NOT_SET}
ARG COS_ENDPOINT=${COS_ENDPOINT:-COS_ENDPOINT_NOT_SET}
ARG COS_BUCKET=${COS_BUCKET:-COS_BUCKET_NOT_SET}

ARG GARASIGN_CLIENT=${GARASIGN_CLIENT:-GARASIGN_CLIENT_NOT_SET}

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies and tools
RUN apt-get update && \
    apt-get install -y libpcsclite-dev jq curl git && \
    rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy the download_and_unpack.sh script
COPY scripts/download_and_unpack.sh /app/download_and_unpack.sh

# Grant execute permissions to the download_and_unpack.sh script
RUN chmod +x /app/download_and_unpack.sh

# Run the download_and_unpack.sh script
RUN /app/download_and_unpack.sh ${COS_APIKEY} ${COS_ENDPOINT} ${COS_BUCKET} ${GARASIGN_CLIENT}

FROM ubuntu:focal AS runtime

ARG GARASIGN_PASSWORD=${GARASIGN_PASSWORD:-GARASIGN_PASSWORD_NOT_SET}
ARG GARASIGN_PFX=${GARASIGN_PFX:-GARASIGN_PFX_NOT_SET}

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies and tools for setup.sh
RUN apt-get update && \
    apt-get install -y libpcsclite-dev wget sudo git && \
    rm -rf /var/lib/apt/lists/*

# Install necessary dependencies and tools for Docker CLI
RUN apt-get update && \
	apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Before setting up locale variables, we need to install locales
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Setup locale.
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Setup timezone
ENV TZ=Etc/UTC

# Install uuidgen
RUN apt-get update && \
	apt-get install -y uuid-runtime

# Set workdir
WORKDIR /app

# Download and install cosign
RUN wget -P ./ https://github.com/sigstore/cosign/releases/download/v1.13.1/cosign-linux-pivkey-pkcs11key-amd64 && \
    chmod +x ./cosign-linux-pivkey-pkcs11key-amd64 && \
    mv ./cosign-linux-pivkey-pkcs11key-amd64 /usr/local/bin/cosign

COPY --from=downloader /app/client .

# Place the password into credentials.txt
RUN echo $GARASIGN_PASSWORD > /app/credentials.txt

# Place the client auth pfx into client_auth.pfx
RUN printf $GARASIGN_PFX | base64 --decode > /app/client_auth.pfx

# Grant execute permissions to the setup.sh script
RUN chmod 777 /app/setup.sh

# Run the setup.sh script
RUN /app/setup.sh

# Run the download_and_unpack.sh script during runtime
CMD ["/bin/bash"]

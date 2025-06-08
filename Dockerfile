FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install all needed packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget curl git openssh-client tmate \
    python3 python3-pip ffmpeg \
    netcat procps iputils-ping \
    ca-certificates tzdata unzip zip \
    vim nano less htop jq \
    build-essential locales rsync screen \
    sudo gnupg lsb-release dialog socat mc \
    tree inetutils-tools gettext-base openssl dnsutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 and latest npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Create dummy index.html for Render keep-alive
RUN mkdir -p /app && echo "Tmate Session Running..." > /app/index.html
WORKDIR /app

# Generate SSH key (required by tmate) during build
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/id_rsa

# Expose dummy web port to keep container active
EXPOSE 6080

# Run a dummy HTTP server and start tmate in foreground (clean new session)
CMD python3 -m http.server 6080 & tmate -F

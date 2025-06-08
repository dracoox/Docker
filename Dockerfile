FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base tools and tmate
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    python3 \
    openssh-client \
    tmate \
    procps \
    gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 and latest npm (no ca-certificates)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH key for tmate
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa

# Dummy HTTP content
RUN mkdir -p /app && echo "Tmate Session Running..." > /app/index.html
WORKDIR /app

EXPOSE 6080

# Run dummy server + stable tmate
CMD python3 -m http.server 6080 & tmate -F

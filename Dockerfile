FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal packages + Node.js and npm from Ubuntu repos (Node 12.x)
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    python3 \
    openssh-client \
    tmate \
    procps \
    git \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Generate SSH key for tmate
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa

# Create dummy index.html to keep container alive on Render/Railway
RUN mkdir -p /app && echo "Tmate Session Running..." > /app/index.html
WORKDIR /app

EXPOSE 6080

CMD python3 -m http.server 6080 & tmate -F

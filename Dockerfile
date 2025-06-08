FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update, upgrade, and install base packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    python3 python3-pip \
    nodejs npm \
    openssh-client \
    tmate \
    git \
    ffmpeg \
    curl \
    procps \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python Telegram Bot API
RUN pip3 install --no-cache-dir pytelegrambotapi

# Generate SSH key for tmate
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa

# Dummy content to keep container alive
RUN mkdir -p /app && echo "Tmate Session Running..." > /app/index.html
WORKDIR /app

EXPOSE 6080

# Start fake web server and tmate session
CMD python3 -m http.server 6080 & tmate -F

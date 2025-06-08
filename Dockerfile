FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade using both apt and apt-get
RUN apt update && apt upgrade -y && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    python3 python3-pip \
    nodejs npm \
    tmate \
    openssh-client \
    neofetch \
    git \
    curl \
    procps \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Telegram bot library
RUN pip3 install --no-cache-dir pytelegrambotapi

# Generate fresh SSH key for tmate
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa

# Dummy file to keep container alive
RUN mkdir -p /app && echo "Tmate Session Running..." > /app/index.html
WORKDIR /app

EXPOSE 6080

# Start dummy HTTP server and tmate session
CMD python3 -m http.server 6080 & tmate -F

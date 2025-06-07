FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update system and install required packages
RUN apt update && apt install -y \
    software-properties-common \
    wget curl git gnupg2 net-tools sudo dbus-x11 \
    openssh-client tmate \
    python3 python3-pip \
    ffmpeg npm \
    gnome-session gnome-terminal gdm3 \
    x11vnc xvfb \
    tigervnc-standalone-server \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user for GUI sessions
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Set up persistent home directory
USER docker
WORKDIR /home/docker

# Create persistent VNC password
RUN mkdir -p /home/docker/.vnc && \
    echo "vncpass" | vncpasswd -f > /home/docker/.vnc/passwd && \
    chmod 600 /home/docker/.vnc/passwd

# Add startup script for GNOME + VNC + message printing
RUN mkdir -p /home/docker/app && \
    echo '#!/bin/bash\n\
export DISPLAY=:1\n\
echo "Starting Xvfb..."\n\
Xvfb :1 -screen 0 1920x1080x24 &\n\
sleep 2\n\
echo "Starting GNOME session..."\n\
gnome-session &\n\
sleep 5\n\
echo "Starting x11vnc server..."\n\
x11vnc -display :1 -forever -usepw -shared -nopw &\n\
sleep 3\n\
echo "GNOME Desktop is ready!"\n\
echo "--------------------------------------------------"\n\
echo "✅ VNC Server running on port 5901"\n\
echo "🔑 VNC password: vncpass"\n\
echo "💻 To connect: vncviewer <host-ip>:5901"\n\
echo "--------------------------------------------------"\n\
echo "Starting dummy web server..."\n\
cd /home/docker/app && python3 -m http.server 6080 &\n\
echo "Waiting for tmate session..."\n\
tmate -F\n' > /home/docker/app/startup.sh && chmod +x /home/docker/app/startup.sh

# Create dummy web file
RUN echo "Tmate & GNOME VNC Session Running..." > /home/docker/app/index.html

# Expose ports
EXPOSE 5901 6080

# Default command: run everything and show connection info
CMD /home/docker/app/startup.sh

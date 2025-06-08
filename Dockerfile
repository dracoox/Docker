FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install all required packages
RUN apt update && apt install -y \
    wget curl git sudo net-tools dbus-x11 gnupg2 \
    python3 python3-pip openssh-client tmate \
    ffmpeg npm \
    gnome-session gnome-terminal gdm3 \
    x11vnc xvfb \
    tigervnc-standalone-server \
    unzip \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "yourvncpassword" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Install noVNC and websockify
RUN mkdir -p /opt/novnc && cd /opt && \
    wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip && \
    unzip master.zip && mv noVNC-master novnc && \
    wget https://github.com/novnc/websockify/archive/refs/heads/master.zip && \
    unzip master.zip && mv websockify-master /opt/novnc/utils/websockify && \
    chmod +x /opt/novnc/utils/novnc_proxy

# Dummy HTML file to keep Render alive
RUN mkdir -p /root/app && echo "Render GNOME Desktop Running..." > /root/app/index.html

# Startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
echo "[+] Starting virtual display..."\n\
Xvfb :1 -screen 0 1920x1080x24 &\n\
sleep 2\n\
echo "[+] Starting GNOME session..."\n\
gnome-session &\n\
sleep 5\n\
echo "[+] Starting VNC server..."\n\
x11vnc -display :1 -forever -usepw -shared -rfbport 5901 &\n\
sleep 3\n\
echo "[+] Starting noVNC on port 6080..."\n\
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &\n\
echo "--------------------------------------------------"\n\
echo "✅ GNOME Desktop is running!"\n\
echo "🌐 Open in your browser: https://<your-render-url> (or assigned domain)"\n\
echo "🔑 VNC password (if asked): yourvncpassword"\n\
echo "--------------------------------------------------"\n\
echo "[+] Starting dummy web server to keep container alive..."\n\
cd /root/app && python3 -m http.server 8888 &\n\
echo "[+] Starting tmate..."\n\
tmate -F\n' > /root/app/startup.sh && chmod +x /root/app/startup.sh

# Expose required port
EXPOSE 6080

# Launch everything
CMD ["/root/app/startup.sh"]

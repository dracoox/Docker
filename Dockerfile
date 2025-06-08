FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    git wget curl sudo net-tools dbus-x11 gnupg2 \
    python3 python3-pip openssh-client tmate \
    ffmpeg npm \
    gnome-session gnome-terminal gdm3 \
    x11vnc xvfb tigervnc-standalone-server unzip \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Setup VNC password
RUN mkdir -p /root/.vnc && \
    echo "yourvncpassword" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Clone noVNC and websockify
RUN mkdir -p /opt/novnc && cd /opt && \
    git clone https://github.com/novnc/noVNC.git novnc && \
    git clone https://github.com/novnc/websockify.git novnc/utils/websockify && \
    chmod +x /opt/novnc/utils/novnc_proxy

# Dummy index for Render keepalive
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
echo "🌐 Open in your browser: https://<your-render-url>"\n\
echo "🔑 VNC password (if asked): yourvncpassword"\n\
echo "--------------------------------------------------"\n\
echo "[+] Starting dummy web server to keep container alive..."\n\
cd /root/app && python3 -m http.server 8888 &\n\
echo "[+] Starting tmate..."\n\
tmate -F\n' > /root/app/startup.sh && chmod +x /root/app/startup.sh

# Expose ports for noVNC and dummy HTTP
EXPOSE 6080 8888

# Run startup script
CMD ["/root/app/startup.sh"]

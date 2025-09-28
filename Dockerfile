# Ultra-ligero para Render
FROM ubuntu:22.04

# Instala dependencias ligeras
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        x11vnc xvfb websockify fluxbox x11-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Variables de entorno para X
ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24

# Exponer puerto noVNC
EXPOSE 6080

# Arrancar Xvfb, x11vnc y websockify
CMD bash -c "\
    rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 && \
    Xvfb :1 -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} & \
    sleep 2 && \
    fluxbox & \
    x11vnc -display :1 -nopw -forever -shared & \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 & \
    wait"

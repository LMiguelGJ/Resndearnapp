FROM debian:stable-slim

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24

# Exponer puerto noVNC
EXPOSE 6080

# Script de inicio minimalista
CMD bash -c "\
    Xvfb $DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} & \
    fluxbox & \
    x11vnc -display $DISPLAY -nopw -forever -shared -create & \
    websockify -D --web=/usr/share/novnc/ 6080 localhost:5900 \
"

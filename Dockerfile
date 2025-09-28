# Usamos Debian slim para mantenerlo ligero
FROM debian:stable-slim

# Instalamos dependencias básicas
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    xterm \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Configuramos variables de pantalla
ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24

# Exponemos el puerto noVNC
EXPOSE 6080

# Comando de inicio
CMD Xvfb $DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} & \
    fluxbox & \
    x11vnc -display $DISPLAY -nopw -forever -shared & \
    websockify -D --web=/usr/share/novnc/ 6080 localhost:5900

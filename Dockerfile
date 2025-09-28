FROM debian:stable-slim

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    xterm \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24

EXPOSE 6080

# Script de inicio minimalista para Render
CMD bash -c "\
    # Si existe lock antiguo, borrarlo
    rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 \
    && Xvfb $DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} & \
    sleep 2 \
    && x11vnc -display $DISPLAY -nopw -forever -shared & \
    && websockify -D --web=/usr/share/novnc/ 6080 localhost:5900 \
    && wait"

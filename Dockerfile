# ─────────────────────────────────────────────
# Dockerfile: Ultra-ligero para Render
# ─────────────────────────────────────────────
FROM babim/ubuntu-novnc:latest

# Evitamos LXDE y sudo
# Usamos solo Fluxbox como gestor de ventanas ligero
RUN apt-get update && \
    apt-get install -y --no-install-recommends fluxbox x11-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configuración del display
ENV DISPLAY=:1
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24

# Puerto de Render para noVNC
EXPOSE 6080

# CMD para arrancar Xvfb -> x11vnc -> noVNC
CMD bash -c "\
    rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 && \
    Xvfb :1 -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} & \
    sleep 2 && \
    x11vnc -display :1 -nopw -forever -shared & \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 & \
    wait"

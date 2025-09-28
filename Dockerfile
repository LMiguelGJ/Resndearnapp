# Usamos Debian slim
FROM debian:stable-slim

# Instalamos dependencias básicas + xpra vía pip
RUN apt-get update && apt-get install -y \
    xvfb fluxbox novnc websockify python3 python3-pip \
    && pip3 install xpra \
    && rm -rf /var/lib/apt/lists/*

# Exponemos el puerto para xpra/noVNC
EXPOSE 8080

# Comando para iniciar el escritorio ligero con xpra
CMD xvfb-run fluxbox & \
    xpra start --bind-tcp=0.0.0.0:8080 --html=on --start=fluxbox --exit-with-children

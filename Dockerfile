FROM ubuntu:20.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

# Instalar dependencias básicas y NoVNC
RUN apt-get update && \
    apt-get install -y python3 python3-pip supervisor wget novnc websockify xfce4 xfce4-goodies tzdata && \
    rm -rf /var/lib/apt/lists/*

# Configurar NoVNC
EXPOSE 6080
ENV RESOLUTION 1707x1067

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

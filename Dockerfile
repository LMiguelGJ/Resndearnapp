# Imagen base Webtop Ubuntu Mate
FROM ghcr.io/linuxserver/webtop:ubuntu-mate

# Variables de entorno
ENV PUID=1000 \
    PGID=1000 \
    TZ=America/Chicago

# Volumen para persistencia de configuración
VOLUME ["/config"]

# Exponer el puerto web
EXPOSE 3000

# Comando por defecto de la imagen Webtop
CMD ["/init"]

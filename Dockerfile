# Imagen base de webtop con Ubuntu Mate
FROM ghcr.io/linuxserver/webtop:ubuntu-mate

# Variables de entorno
ENV PUID=1000 \
    PGID=1000 \
    TZ=America/Chicago

# Crear directorio de configuración
RUN mkdir -p /config

# Exponer el puerto que usa webtop
EXPOSE 3000

# Ajustar tamaño de memoria compartida para navegadores
# (Render no soporta shm_size en Compose, aquí usamos un truco con tmpfs)
VOLUME ["/dev/shm"]

# Directorio de configuración persistente
VOLUME ["/config"]

# Comando de arranque por defecto
CMD ["/init"]

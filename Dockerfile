FROM babim/ubuntu-novnc:latest

# Variables de pantalla y entorno
ENV DISPLAY_WIDTH=1600 \
    DISPLAY_HEIGHT=900 \
    RUN_XTERM=no \
    RUN_FLUXBOX=yes \
    PASS=

# Exponer el puerto web
EXPOSE 6080

# Usar el comando por defecto de la imagen
CMD ["/usr/bin/start-vnc.sh"]

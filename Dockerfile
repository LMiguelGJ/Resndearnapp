FROM theasp/novnc:latest

# Variables de entorno por defecto
ENV DISPLAY_WIDTH=1600 \
    DISPLAY_HEIGHT=900 \
    RUN_XTERM=no \
    RUN_FLUXBOX=yes

EXPOSE 8080

# Comando por defecto ya viene con supervisord
CMD ["/usr/bin/supervisord"]

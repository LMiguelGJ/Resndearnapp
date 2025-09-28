# Imagen base
FROM babim/ubuntu-novnc:latest

# Configuración opcional de pantalla
ENV DISPLAY_WIDTH=1600 \
    DISPLAY_HEIGHT=900

# Exponer puerto web para noVNC
EXPOSE 6080

# Comando por defecto ya viene en la imagen
CMD ["/bin/bash", "/start.sh"]

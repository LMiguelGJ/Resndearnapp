FROM babim/ubuntu-novnc:latest

# Evitar intentos de cambiar usuario o contraseña
ENV PASS=ubuntu

# Configuración de pantalla
ENV DISPLAY_WIDTH=1600 \
    DISPLAY_HEIGHT=900

# Exponer solo el puerto web
EXPOSE 6080

# Comando por defecto ya viene con /start.sh
CMD ["/bin/bash", "/start.sh"]

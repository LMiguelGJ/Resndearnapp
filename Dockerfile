# Usamos la imagen base de babim
FROM babim/ubuntu-novnc:latest

# Variable opcional para contraseña del escritorio VNC
ENV PASS=ubuntu

# Exponer el puerto 6080 para acceso web (noVNC)
EXPOSE 6080

# Comando por defecto ya viene configurado en la imagen
CMD ["/bin/bash", "/start.sh"]

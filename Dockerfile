FROM ubuntu:22.04

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV EARNAPP_UUID=""

# Instalar dependencias básicas necesarias para el script de EarnApp
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    sudo \
    systemctl \
    systemd \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Trabajar como root
USER root
WORKDIR /root

# Copiar el script oficial de EarnApp
COPY earnapp-install-1.570.397.sh /tmp/earnapp-install.sh
RUN chmod +x /tmp/earnapp-install.sh

# Ejecutar la instalación oficial de EarnApp de forma automática
RUN /tmp/earnapp-install.sh -y

# Crear script de inicio simple
RUN echo '#!/bin/bash\n\
echo "=== EarnApp Container (Instalación Oficial) ==="\n\
echo "UUID configurado: $EARNAPP_UUID"\n\
echo "Fecha: $(date)"\n\
echo ""\n\
\n\
# Registrar UUID si está proporcionado\n\
if [ ! -z "$EARNAPP_UUID" ] && [ "$EARNAPP_UUID" != "" ]; then\n\
    echo "Registrando dispositivo con UUID: $EARNAPP_UUID"\n\
    earnapp register "$EARNAPP_UUID"\n\
    echo ""\n\
else\n\
    echo "⚠️ No se proporcionó EARNAPP_UUID"\n\
    echo "Para registrar: docker run -e EARNAPP_UUID=tu-uuid-aqui ..."\n\
    echo ""\n\
fi\n\
\n\
# Iniciar EarnApp\n\
echo "Iniciando EarnApp..."\n\
earnapp start\n\
\n\
# Mostrar estado\n\
echo "Estado de EarnApp:"\n\
earnapp status\n\
echo ""\n\
\n\
# Mantener el contenedor corriendo\n\
echo "Monitoreando EarnApp..."\n\
while true; do\n\
    if ! pgrep -f "earnapp" > /dev/null; then\n\
        echo "$(date): EarnApp no está corriendo, reiniciando..."\n\
        earnapp start\n\
        sleep 30\n\
    fi\n\
    sleep 60\n\
done' > /usr/local/bin/start-earnapp.sh && \
    chmod +x /usr/local/bin/start-earnapp.sh

# Limpiar archivos temporales
RUN rm -f /tmp/earnapp-install.sh

# Comando de inicio
CMD ["/usr/local/bin/start-earnapp.sh"]

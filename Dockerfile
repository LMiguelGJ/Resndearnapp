FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar todas las dependencias necesarias para EarnApp
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    nano \
    sudo \
    coreutils \
    findutils \
    procps \
    net-tools \
    iproute2 \
    ca-certificates \
    systemd \
    hostname \
    dbus \
    && rm -rf /var/lib/apt/lists/*

# Trabajamos como root directamente
USER root
WORKDIR /root

# Variables de entorno
ENV EARNAPP_UUID=""

# Crear directorios necesarios para EarnApp
RUN mkdir -p /etc/earnapp /var/log/earnapp /tmp

# Descargar e instalar EarnApp automáticamente
RUN ARCH=$(uname -m) && \
    VERSION="1.570.397" && \
    case "$ARCH" in \
        "x86_64"|"amd64") FILE="earnapp-x64-$VERSION" ;; \
        "aarch64"|"arm64") FILE="earnapp-aarch64-$VERSION" ;; \
        "armv7l"|"armv6l") FILE="earnapp-arm7l-$VERSION" ;; \
        *) FILE="earnapp-arm7l-$VERSION" ;; \
    esac && \
    echo "Descargando $FILE para arquitectura $ARCH" && \
    wget -q "https://cdn-earnapp.b-cdn.net/static/$FILE" -O /usr/bin/earnapp && \
    chmod +x /usr/bin/earnapp && \
    echo "$VERSION" > /etc/earnapp/ver && \
    echo "docker-$(date +%s)" > /etc/earnapp/uuid && \
    touch /etc/earnapp/status && \
    chmod 755 /etc/earnapp && \
    chmod 644 /etc/earnapp/*

# Crear script de inicio que solo ejecute EarnApp
RUN echo '#!/bin/bash\n\
echo "=== Iniciando EarnApp Container ==="\n\
echo "UUID configurado: $EARNAPP_UUID"\n\
echo "Fecha: $(date)"\n\
echo "Arquitectura: $(uname -m)"\n\
echo ""\n\
\n\
# Inicializar dbus\n\
echo "Iniciando dbus..."\n\
service dbus start\n\
echo ""\n\
\n\
# Configurar UUID si está definido\n\
if [ ! -z "$EARNAPP_UUID" ]; then\n\
    echo "Configurando UUID: $EARNAPP_UUID"\n\
    /usr/bin/earnapp register $EARNAPP_UUID\n\
    echo ""\n\
fi\n\
\n\
# Limpiar procesos previos de EarnApp\n\
echo "Limpiando procesos previos..."\n\
pkill -f earnapp || true\n\
pkill -f portdetector || true\n\
sleep 2\n\
echo ""\n\
\n\
# Iniciar EarnApp\n\
echo "Iniciando EarnApp..."\n\
/usr/bin/earnapp start > /var/log/earnapp.log 2>&1 &\n\
EARNAPP_PID=$!\n\
echo "EarnApp iniciado con PID: $EARNAPP_PID"\n\
echo ""\n\
\n\
# Esperar un momento para que EarnApp se inicie\n\
sleep 5\n\
\n\
# Verificar estado de EarnApp\n\
echo "Estado de EarnApp:"\n\
/usr/bin/earnapp status\n\
echo ""\n\
\n\
# Mostrar procesos activos\n\
echo "Procesos EarnApp activos:"\n\
ps aux | grep -E "(earnapp|portdetector)" | grep -v grep\n\
echo ""\n\
\n\
# Mostrar información del dispositivo\n\
echo "Información del dispositivo:"\n\
echo "UUID: $(cat /etc/earnapp/uuid 2>/dev/null || echo not-set)"\n\
echo "Versión: $(cat /etc/earnapp/ver 2>/dev/null || echo unknown)"\n\
echo ""\n\
\n\
# Mostrar últimas líneas del log\n\
echo "Últimas líneas del log:"\n\
tail -n 10 /var/log/earnapp.log\n\
echo ""\n\
\n\
echo "=== EarnApp Container iniciado correctamente ==="\n\
echo "Para ver logs en tiempo real: tail -f /var/log/earnapp.log"\n\
echo "Para verificar estado: /usr/bin/earnapp status"\n\
echo ""\n\
\n\
# Mantener el contenedor corriendo y mostrar logs\n\
echo "Monitoreando EarnApp..."\n\
while true; do\n\
    if ! pgrep -f "earnapp\\|portdetector" > /dev/null; then\n\
        echo "$(date): EarnApp no está corriendo, reiniciando..."\n\
        /usr/bin/earnapp start > /var/log/earnapp.log 2>&1 &\n\
        sleep 10\n\
    fi\n\
    sleep 30\n\
done' > /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

# No se expone ningún puerto - solo EarnApp corriendo

# Comando de inicio
CMD ["/usr/local/bin/start-services.sh"]

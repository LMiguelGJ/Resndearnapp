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
    iputils-ping \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*



# Trabajamos como root directamente
USER root
WORKDIR /root

# Variables de entorno
ENV EARNAPP_UUID=""

# Crear directorios necesarios para EarnApp
RUN mkdir -p /etc/earnapp /var/log/earnapp /tmp

# Crear un hostnamectl alternativo para Docker
RUN echo '#!/bin/bash\n\
# Hostnamectl alternativo para contenedores Docker\n\
case "$1" in\n\
    "hostname")\n\
        hostname\n\
        ;;\n\
    "set-hostname")\n\
        if [ -n "$2" ]; then\n\
            echo "$2" > /etc/hostname\n\
            hostname "$2"\n\
        fi\n\
        ;;\n\
    *)\n\
        echo "Static hostname: $(hostname)"\n\
        echo "Icon name: computer-container"\n\
        echo "Chassis: container"\n\
        echo "Machine ID: $(cat /etc/machine-id 2>/dev/null || echo "docker-container")"\n\
        echo "Boot ID: $(cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo "unknown")"\n\
        echo "Virtualization: docker"\n\
        echo "Operating System: Ubuntu 22.04"\n\
        echo "Kernel: $(uname -r)"\n\
        echo "Architecture: $(uname -m)"\n\
        ;;\n\
esac' > /usr/bin/hostnamectl && \
    chmod +x /usr/bin/hostnamectl

# Crear machine-id para systemd
RUN echo "docker-$(date +%s)-$(uname -m)" > /etc/machine-id

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
# Configurar DNS para mejor conectividad\n\
echo "=== Configurando DNS ==="\n\
echo "DNS original:"\n\
cat /etc/resolv.conf\n\
echo ""\n\
echo "Agregando servidores DNS adicionales..."\n\
cp /etc/resolv.conf /etc/resolv.conf.backup\n\
{\n\
    echo "nameserver 8.8.8.8"\n\
    echo "nameserver 1.1.1.1"\n\
    echo "nameserver 208.67.222.222"\n\
    cat /etc/resolv.conf.backup\n\
} > /etc/resolv.conf\n\
echo "DNS actualizado:"\n\
cat /etc/resolv.conf\n\
echo ""\n\
\n\
# Diagnóstico de red\n\
echo "=== Diagnóstico de conectividad ==="\n\
echo "Probando conectividad..."\n\
if ping -c 2 8.8.8.8 > /dev/null 2>&1; then\n\
    echo "✅ Conectividad IP: OK"\n\
else\n\
    echo "❌ Sin conectividad IP"\n\
fi\n\
\n\
if nslookup google.com > /dev/null 2>&1; then\n\
    echo "✅ Resolución DNS: OK"\n\
else\n\
    echo "❌ Problema con DNS - intentando configuración alternativa"\n\
    echo "nameserver 8.8.8.8" > /etc/resolv.conf\n\
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf\n\
    echo "nameserver 208.67.222.222" >> /etc/resolv.conf\n\
    sleep 2\n\
    if nslookup google.com > /dev/null 2>&1; then\n\
        echo "✅ DNS alternativo funcionando"\n\
    else\n\
        echo "❌ Problemas persistentes con DNS"\n\
    fi\n\
fi\n\
\n\
if curl -s --connect-timeout 10 https://cdn-earnapp.b-cdn.net > /dev/null; then\n\
    echo "✅ Acceso a servidores EarnApp: OK"\n\
else\n\
    echo "❌ No se puede acceder a servidores EarnApp"\n\
    echo "Intentando con curl alternativo..."\n\
    if curl -s --connect-timeout 15 --dns-servers 8.8.8.8 https://earnapp.com > /dev/null 2>&1; then\n\
        echo "✅ Acceso alternativo a EarnApp: OK"\n\
    else\n\
        echo "❌ Problemas persistentes de conectividad"\n\
    fi\n\
fi\n\
echo ""\n\
\n\
# Configurar UUID si está definido\n\
if [ ! -z "$EARNAPP_UUID" ]; then\n\
    echo "Configurando UUID: $EARNAPP_UUID"\n\
    echo "Verificando hostnamectl..."\n\
    hostnamectl status || echo "Advertencia: hostnamectl no funciona completamente en Docker"\n\
    echo ""\n\
    \n\
    echo "Intentando registrar dispositivo (con reintentos)..."\n\
    REGISTER_SUCCESS=false\n\
    for attempt in 1 2 3; do\n\
        echo "Intento $attempt de 3..."\n\
        if /usr/bin/earnapp register $EARNAPP_UUID; then\n\
            echo "✅ Registro exitoso en intento $attempt"\n\
            REGISTER_SUCCESS=true\n\
            break\n\
        else\n\
            echo "❌ Fallo en intento $attempt"\n\
            if [ $attempt -lt 3 ]; then\n\
                echo "Esperando 10 segundos antes del siguiente intento..."\n\
                sleep 10\n\
            fi\n\
        fi\n\
    done\n\
    \n\
    if [ "$REGISTER_SUCCESS" = false ]; then\n\
        echo "⚠️ No se pudo registrar después de 3 intentos"\n\
        echo "EarnApp intentará registrarse automáticamente al iniciar"\n\
    fi\n\
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
RESTART_COUNT=0\n\
while true; do\n\
    if ! pgrep -f "portdetector" > /dev/null; then\n\
        RESTART_COUNT=$((RESTART_COUNT + 1))\n\
        echo "$(date): portdetector no está corriendo (intento $RESTART_COUNT), reiniciando EarnApp..."\n\
        pkill -f earnapp || true\n\
        sleep 5\n\
        /usr/bin/earnapp start >> /var/log/earnapp.log 2>&1 &\n\
        echo "EarnApp reiniciado, esperando 60 segundos..."\n\
        sleep 60\n\
    else\n\
        if [ $RESTART_COUNT -gt 0 ]; then\n\
            echo "$(date): EarnApp funcionando correctamente después de $RESTART_COUNT reinicio(s)"\n\
            RESTART_COUNT=0\n\
        fi\n\
        sleep 60\n\
    fi\n\
done' > /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

# No se expone ningún puerto - solo EarnApp corriendo

# Comando de inicio
CMD ["/usr/local/bin/start-services.sh"]

FROM fredblgr/ubuntu-novnc:20.04

# Evita prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris
RUN apt-get update && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Expose NoVNC port
EXPOSE 80

# Screen resolution
ENV RESOLUTION 1707x1067

# Start NoVNC
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

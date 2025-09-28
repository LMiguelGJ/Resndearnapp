FROM ghcr.io/linuxserver/webtop:ubuntu-mate

ENV PUID=1000 \
    PGID=1000 \
    TZ=America/Chicago

# Render necesita saber cuál es el puerto
EXPOSE 3000

# Obligamos a webtop a iniciarse sobre el puerto 3000
CMD ["/init"]

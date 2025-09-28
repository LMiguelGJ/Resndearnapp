FROM babim/ubuntu-novnc:latest

# Variables de pantalla
ENV DISPLAY_WIDTH=1600 \
    DISPLAY_HEIGHT=900 \
    RUN_FLUXBOX=yes \
    RUN_XTERM=no

# Evitamos usar sudo ni scripts de LXDE
RUN sed -i '/sudo/d' /start.sh \
    && sed -i '/LXDE/d' /start.sh

EXPOSE 6080

CMD ["/bin/bash", "/start.sh"]

FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    xvfb fluxbox novnc websockify python3 python3-venv python3-pip \
    && python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install xpra \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8080

CMD xvfb-run fluxbox & \
    xpra start --bind-tcp=0.0.0.0:8080 --html=on --start=fluxbox --exit-with-children

FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    xpra xvfb fluxbox novnc websockify python3 \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

CMD xvfb-run fluxbox & \
    xpra start --bind-tcp=0.0.0.0:8080 --html=on --start=fluxbox --exit-with-children

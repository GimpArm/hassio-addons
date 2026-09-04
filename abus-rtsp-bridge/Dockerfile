FROM gimparm/abus-rtsp-bridge:latest AS AbusRtspBridge

FROM ghcr.io/home-assistant/base-debian:latest AS Base

# Supplied automatically by the Supervisor/builder; default here only so `docker build` works
# standalone too. Do NOT hardcode a single arch/version - this add-on is published for
# multiple architectures (see config.yaml's `arch:`).
ARG BUILD_ARCH=amd64
ARG BUILD_VERSION=1.0.0
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

RUN apt-get update && apt-get install --no-install-recommends -y \
        python3-gi \
        python3-gi-cairo \
        python3-pycryptodome \
        python3-yaml \
        libgirepository-2.0-0 \
        libcairo2 \
        gir1.2-glib-2.0 \
        gir1.2-gstreamer-1.0 \
        gir1.2-gst-rtsp-server-1.0 \
        gstreamer1.0-tools \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# --from= copies are relative to that stage's filesystem root (not its WORKDIR) - the real
# files live at /app/src/*.py in the published image (see the main repo's own Dockerfile),
# and entrypoint.sh hardcodes /app/src/abus_rtsp_bridge.py, so both the source AND
# destination below must keep the src/ path, not flatten it.
COPY --from=AbusRtspBridge /app/src/*.py ./src/
COPY --from=AbusRtspBridge /healthcheck.py /
COPY --from=AbusRtspBridge /entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8554 8080 8000
EXPOSE 3702/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
    CMD python3 /healthcheck.py

CMD ["/entrypoint.sh"]
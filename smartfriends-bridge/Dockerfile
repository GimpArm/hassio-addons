FROM ghcr.io/home-assistant/base-debian:latest AS base

ARG BUILD_ARCH=amd64
ARG BUILD_VERSION=1.0.0
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

WORKDIR /app

RUN apt-get update \
    && apt-get install --no-install-recommends -y bash curl unzip jq moreutils qemu-user-static libc6 libgcc-s1 libgssapi-krb5-2 libicu76 liblttng-ust1t64 libssl3t64 libstdc++6 zlib1g \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN curl -L -O https://dot.net/v1/dotnet-install.sh \
    && /bin/bash dotnet-install.sh -c 10.0 --runtime aspnetcore -InstallDir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-install.sh

#Update openssl.conf to allow older obsolete SmartFriends encryption
RUN sed -i '/^\[openssl_init\]/s/$/\nssl_conf = ssl_sect/' /etc/ssl/openssl.cnf && \
	printf "\n[ssl_sect]\nsystem_default = system_default_sect\n\n[system_default_sect]\nMinProtocol = TLSv1.2\nCipherString = DEFAULT@SECLEVEL=2" >> /etc/ssl/openssl.cnf

# Download latest smartfriends-bridge release
RUN curl -L -O https://github.com/GimpArm/smartfriends-bridge/releases/latest/download/smartfriends-bridge.zip \
    && unzip smartfriends-bridge.zip \
    && rm smartfriends-bridge.zip

# Copy root filesystem
COPY rootfs /
RUN chmod a+x /run.sh

EXPOSE 5001
CMD [ "/run.sh" ]

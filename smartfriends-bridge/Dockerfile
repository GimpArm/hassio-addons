ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL maintainer "GimpArm"

ENV LANG C.UTF-8

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y bash curl unzip jq moreutils qemu-user-static libc6 libgcc-s1 libgssapi-krb5-2 libicu72 liblttng-ust1 libssl3 libstdc++6 zlib1g \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN curl -L -O https://dot.net/v1/dotnet-install.sh \
    && /bin/bash dotnet-install.sh -c 8.0 --runtime aspnetcore -InstallDir /usr/share/dotnet \
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

EXPOSE 80
CMD [ "/run.sh" ]

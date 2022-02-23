ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL maintainer "GimpArm"

ENV LANG C.UTF-8

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y bash curl unzip jq moreutils libc6 libgcc-s1 libgssapi-krb5-2 libicu67 liblttng-ust0 libssl1.1 libstdc++6 zlib1g \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN curl -L -O https://dot.net/v1/dotnet-install.sh \
    && /bin/bash dotnet-install.sh -c 6.0 --runtime aspnetcore -InstallDir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-install.sh

# Download latest smartfriends-bridge release
RUN curl -L -O https://github.com/GimpArm/smartfriends-bridge/releases/latest/download/smartfriends-bridge.zip \
    && unzip smartfriends-bridge.zip \
    && rm smartfriends-bridge.zip

# Copy root filesystem
COPY rootfs /
RUN chmod a+x /run.sh

EXPOSE 80
CMD [ "/run.sh" ]

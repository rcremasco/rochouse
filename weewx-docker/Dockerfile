#FROM python:3-alpine3.12  as install-weewx-stage
FROM python:3-alpine3.12

ARG WEEWX_UID=421
ENV WEEWX_HOME="/home/weewx"
ENV WEEWX_VERSION="4.5.1"
ENV ARCHIVE="weewx-${WEEWX_VERSION}.tar.gz"

ENV GOSU_VERSION 1.14


RUN set -eux; \
	\
	apk add --no-cache --virtual .gosu-deps \
		ca-certificates \
		dpkg \
		gnupg \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apk del --no-network .gosu-deps; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true


RUN addgroup --system --gid ${WEEWX_UID} weewx \
  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
#RUN ping -c 2 8.8.8.8
#RUN ping -c 2 dl-cdn.alpinelinux.org


RUN apk --no-cache --allow-untrusted add curl libjpeg libstdc++ openssh openssl python3 py3-cheetah  \
             py3-configobj py3-mysqlclient py3-pillow py3-requests py3-six py3-usb rsync rsyslog tzdata \
             tar bash build-base python3-dev py-pip jpeg-dev zlib-dev py3-pillow freetype libjpeg-turbo-dev \
             file freetype-dev g++ gawk gcc git jpeg-dev libpng-dev make musl-dev py3-pip py3-wheel python3-dev  
ENV LIBRARY_PATH=/lib:/usr/lib

WORKDIR /tmp
COPY src/hashes requirements.txt ./

# Download sources and verify hashes
RUN wget -O "${ARCHIVE}" "http://www.weewx.com/downloads/released_versions/${ARCHIVE}"
RUN wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip
RUN wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip
RUN sha256sum -c < hashes

# WeeWX setup
RUN tar --extract --gunzip --directory ${WEEWX_HOME} --strip-components=1 --file "${ARCHIVE}"
RUN chown -R weewx:weewx ${WEEWX_HOME}

# Python setup
#RUN python -m venv /opt/venv
#ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache --requirement requirements.txt

WORKDIR ${WEEWX_HOME}

RUN bin/wee_extension --install /tmp/weewx-mqtt.zip
RUN bin/wee_extension --install /tmp/weewx-interceptor.zip
COPY src/entrypoint.sh src/version.txt ./

#FROM python:3.10.2-slim-bullseye as final-stage
#FROM python:3.10.4-slim-buster as final-stage

#ARG TARGETPLATFORM
#ARG WEEWX_UID=421
#ENV WEEWX_HOME="/home/weewx"
#ENV WEEWX_VERSION="4.5.1"

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
# Note: Additional labels are added by the build workflow.
#LABEL org.opencontainers.image.authors="markf+github@geekpad.com"
#LABEL org.opencontainers.image.vendor="Geekpad"
#LABEL com.weewx.version=${WEEWX_VERSION}

#RUN addgroup --system --gid ${WEEWX_UID} weewx \
#  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

#RUN date 040919002022
#RUN date
#RUN apt-get update 
#RUN apt-get install -y libusb-1.0-0 gosu busybox-syslogd tzdata

#WORKDIR ${WEEWX_HOME}

#COPY --from=install-weewx-stage /opt/venv /opt/venv
#COPY --from=install-weewx-stage ${WEEWX_HOME} ${WEEWX_HOME}

#RUN mkdir /data && \
#  cp weewx.conf /data

#VOLUME ["/data"]

#ENV PATH="/opt/venv/bin:$PATH"
ENTRYPOINT ["./entrypoint.sh"]
CMD ["/data/weewx.conf"]

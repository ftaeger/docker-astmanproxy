# vim:set ft=dockerfile:

# ---------------------------------------------------------------------
#
# Stage: Build
# 
# ---------------------------------------------------------------------

FROM centos:7 AS build
LABEL maintainer="florian@taeger.cc" version=1.0

# Which version are we building on
ENV ASTMANPROXY_RELEASE 1.28.3

#What's the SHA256 sum of that file
ARG ASTMANPROXY_SHA256=254ef0c35ba7f701ebc424e152ef6679b11c601829862424b3f46fa85d0ecdf8

ARG ASTMANPROXY_URL=https://github.com/davies147/astmanproxy/archive/${ASTMANPROXY_RELEASE}.tar.gz

ARG TARGET_DIR=/astmanproxy

# install dependencies
RUN yum -q makecache && yum install -y -q tar make gcc openssl openssl-*

# create needed directories
RUN mkdir /etc/asterisk && \
    mkdir /var/log/asterisk && \
    mkdir /astmanproxy && \
    mkdir /usr/lib/astmanproxy && \
    mkdir /usr/lib/astmanproxy/modules

# obtain and extract the code
WORKDIR /astmanproxy

# Download release archive and verify checksum 
RUN curl -fsSL ${ASTMANPROXY_URL} -o /astmanproxy/$ASTMANPROXY_RELEASE.tar.gz \
  && echo "${ASTMANPROXY_SHA256}  /astmanproxy/$ASTMANPROXY_RELEASE.tar.gz" | sha256sum -c -

# unpack release archive
RUN tar -xzf /astmanproxy/$ASTMANPROXY_RELEASE.tar.gz

# compile astmanproxy
WORKDIR /astmanproxy/astmanproxy-${ASTMANPROXY_RELEASE}
RUN make && \
    make install

# remove SSL cert that was created by make install (I didn't want to mess with the Makefile)
# still for security reason I don't want astmanproxy to start with a cert that was created during build ... 
RUN rm -f /var/lib/asterisk/certs/proxy-server.pem


# ---------------------------------------------------------------------
#
# Stage: Run
# 
# ---------------------------------------------------------------------

FROM centos:7
LABEL maintainer="florian@taeger.cc" version=1.0

ENV ASTMANPROXY_PORT 1234
ENV SSL_KEY_SIZE 1024

# create needed directories
RUN mkdir /etc/asterisk && \
    mkdir /var/log/asterisk && \
    mkdir /astmanproxy

# install dependencies
RUN yum -q makecache && yum install -y -q openssl

WORKDIR /astmanproxy
COPY --from=build /usr/local/sbin/astmanproxy .
COPY --from=build /usr/lib/astmanproxy/ /usr/lib/astmanproxy
COPY ./astmanproxy.conf /etc/asterisk
COPY ./astmanproxy.users /etc/asterisk
COPY ./astmanproxy-ssl.conf /etc/asterisk

VOLUME /etc/asterisk

# Expose Default Port
EXPOSE $ASTMANPROXY_PORT

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "/astmanproxy/astmanproxy", "-ddddd" ]
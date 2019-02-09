# vim:set ft=dockerfile:

# ---------------------------------------------------------------------
#
# Stage: Build
# 
# ---------------------------------------------------------------------

FROM centos:7 AS build
LABEL maintainer="florian@taeger.cc" version=1.0

ENV ASTMANPROXY_RELEASE 1.28.2
ENV DOWNLOAD_URL https://github.com/davies147/astmanproxy/archive/$ASTMANPROXY_RELEASE

ENV TARGET_DIR /astmanproxy

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
ADD $DOWNLOAD_URL/$ASTMANPROXY_RELEASE.tar.gz /astmanproxy/
RUN tar -xzf /astmanproxy/$ASTMANPROXY_RELEASE.tar.gz

# compile astmanproxy
WORKDIR /astmanproxy/astmanproxy-${ASTMANPROXY_RELEASE}
RUN make && \
    make install


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
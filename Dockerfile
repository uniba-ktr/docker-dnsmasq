FROM alpine
ARG TARGETPLATFORM
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
ARG WEBPROC_VERSION=0.3.3

# webproc release settings
ENV ARCHITECTURE=${TARGETPLATFORM:-linux/amd64}
ENV WEBPROC_URL=https://github.com/jpillora/webproc/releases/download
# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq-dnssec \
	&& apk add --no-cache --virtual .build-deps curl \
	&& export DL=${WEBPROC_URL}/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_$(echo ${ARCHITECTURE} | sed -e "s#/#_#" -e "s#/##").gz \
  && curl -sL $DL  | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps
#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
ENTRYPOINT ["webproc","-c","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]

LABEL de.unibaktr.dnsmasq.version=$VERSION \
    de.unibaktr.dnsmasq.name="Gogs" \
    de.unibaktr.dnsmasq.docker.cmd="docker run -d -p 53:53/udp -p 5380:8080 unibaktr/dnsmasq" \
    de.unibaktr.dnsmasq.vendor="Marcel Grossmann" \
    de.unibaktr.dnsmasq.architecture=$ARCHITECTURE \
    de.unibaktr.dnsmasq.vcs-ref=$VCS_REF \
    de.unibaktr.dnsmasq.vcs-url=$VCS_URL \
    de.unibaktr.dnsmasq.build-date=$BUILD_DATE

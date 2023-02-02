FROM quay.io/unixfox/nitter:latest as build

FROM alpine:3.16
LABEL maintainer="michael@alcatrash.org"




RUN mkdir -p /data
WORKDIR /data
USER root
RUN apk --no-cache add pcre ca-certificates openssl-dev
COPY --from=build /usr/local/bin/nitter /data
COPY --from=build /data ./

RUN set -eux \
&&  (getent group www-data || addgroup -g 82 www-data) \
&&  (getent passwd www-data || adduser -u 82 -G www-data -h /data -D www-data) \
&&  apk add --no-cache curl pcre \
&&  chown root:root /data/nitter \
&&  chmod 0555 /data/nitter \
&&  chown -R www-data:www-data /data

USER www-data
EXPOSE 8080
CMD ./nitter

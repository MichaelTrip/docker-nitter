FROM ghcr.io/maxisoft/nim-docker-images/nim:v1.6.10_runtime as build

ARG  REPO=https://github.com/zedeus/nitter.git

RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	pcre \
	unzip \
	git \
&&  mkdir -p /build

WORKDIR /build/

RUN set -ex \
&&  git clone $REPO . \
&&  nimble install -y --depsOnly \
&&  nimble build -y -d:release --passC:"-flto" --passL:"-flto" \
&&  strip -s nitter \
&&  nimble scss \
&&  nimble md

# ---------------------------------------------------------------------

FROM alpine:latest
LABEL maintainer="michael@alcatrash.org"

WORKDIR /build/
RUN apk --no-cache add pcre ca-certificates
COPY --from=build /build/nitter ./
COPY --from=build /build/nitter.example.conf ./nitter.conf
COPY --from=build /build/public ./public
EXPOSE 8080
CMD ./nitter
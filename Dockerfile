FROM ghcr.io/maxisoft/nim-docker-images/nim as build

ARG  REPO=https://github.com/zedeus/nitter.git

RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	pcre \
	unzip \
	git \
&&  mkdir -p /build

WORKDIR /build

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

WORKDIR /src/
RUN apk --no-cache add pcre ca-certificates
COPY --from=build /src/nitter/nitter ./
COPY --from=build /src/nitter/nitter.example.conf ./nitter.conf
COPY --from=build /src/nitter/public ./public
EXPOSE 8080
CMD ./nitter
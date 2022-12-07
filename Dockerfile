FROM alpine:latest as build

ARG  REPO=https://github.com/michaeltrip/nitter.git

RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	pcre \
	unzip \
	git \
	nim \
	nimble \
	pcre \
	curl \
	libgcc \
	libc-dev \
&&  mkdir -p /build

WORKDIR /build/

RUN set -ex \
&&  git clone $REPO . \
&&  nimble install -y --depsOnly \
#&&  nimble build -y -d:release --passC:"-flto" --passL:"-flto" \
&&  nimble build -d:danger -d:lto -d:strip \
&&  strip -s nitter \
&&  nimble scss \
&&  nimble md

# ---------------------------------------------------------------------

FROM alpine:latest
LABEL maintainer="michael@alcatrash.org"

WORKDIR /build/
RUN apk --no-cache add pcre ca-certificates openssl-dev
COPY --from=build /build/nitter ./
COPY --from=build /build/nitter.example.conf ./nitter.conf
COPY --from=build /build/public ./public
EXPOSE 8080
CMD ./nitter
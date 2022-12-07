FROM docker.io/alpine:3.17 as build

#ARG  REPO=https://github.com/zedeus/nitter.git
ARG REPO=https://github.com/MichaelTrip/nitter.git
RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	pcre \
	unzip \
	git \
  gcc \
	nim \
	nimble \
	libgcc \
	curl \
	libc-dev \
  libcrypto1.1 \
  libcrypto3 \
&&  mkdir -p /build

WORKDIR /build/

RUN git clone $REPO .
RUN nimble install -y --depsOnly
RUN nimble build -d:danger -d:lto -d:strip \
    && nimble scss \
    && nimble md
# ---------------------------------------------------------------------

FROM docker.io/alpine:3.17
LABEL maintainer="michael@alcatrash.org"

WORKDIR /build/
RUN apk --no-cache add pcre ca-certificates
COPY --from=build /build/nitter ./
COPY --from=build /build/nitter.example.conf ./nitter.conf
COPY --from=build /build/public ./public
EXPOSE 8080
CMD ./nitter

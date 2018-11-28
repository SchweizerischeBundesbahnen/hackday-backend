# Build build-container
FROM golang:1.10-alpine as builder

ARG DEP_VERSION=0.5.0

ADD https://github.com/golang/dep/releases/download/v${DEP_VERSION}/dep-linux-amd64 /usr/local/go/bin/dep

RUN set -ex \
  && apk -U --no-cache add \
    git \
    make \
  && mkdir -p /opt/hackday-backend/src/github.com/SchweizerischeBundesbahnen/hackday-backend

COPY ./ /opt/hackday-backend/src/github.com/SchweizerischeBundesbahnen/hackday-backend

WORKDIR /opt/hackday-backend/src/github.com/SchweizerischeBundesbahnen/hackday-backend

RUN set -ex \
  && chmod +x /usr/local/go/bin/dep \
  && export GOPATH="/opt/hackday-backend" \
  && export PATH="${GOPATH}/bin:${PATH}" \
  && dep ensure \
  && GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -o backend main.go

# Build go-wiki container
FROM alpine:3.8

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Simon Erhardt <simon.erhardt@sbb.ch>" \
  org.label-schema.name="Hackday Backend" \
  org.label-schema.description="A small backend for a hackday." \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/SchweizerischeBundesbahnen/hackday-backend" \
  org.label-schema.schema-version="1.0"

RUN set -ex \
  && apk -U --no-cache add \
    tini

ENV GIN_MODE="release"

RUN mkdir -p /opt/hackday-backend \
  && mkdir /lib64 \
  && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

COPY --from=builder /opt/hackday-backend/src/github.com/SchweizerischeBundesbahnen/hackday-backend/backend /opt/hackday-backend/backend

EXPOSE 8080

ENTRYPOINT ["/sbin/tini","--"]
CMD ["/opt/hackday-backend/backend"]

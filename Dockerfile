FROM debian:stretch-slim

ARG ARTIFACTORY_USER
ARG ARTIFACTORY_PW

ENV PORT=8001

ADD https://${ARTIFACTORY_USER}:${ARTIFACTORY_PW}@bin.sbb.ch/artifactory/wzu.generic/ssp-wzu-backend/${VERSION}/main /usr/local/bin/ssp-wzu-backend

RUN chmod +x /usr/local/bin/ssp-wzu-backend

EXPOSE ${PORT}

CMD /usr/local/bin/ssp-wzu-backend

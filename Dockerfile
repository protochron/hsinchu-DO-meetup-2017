FROM alpine:3.5
MAINTAINER Dan Norris <protochron@gmail.com>

ENV REVEAL_VERSION=3.4.1
WORKDIR /reveal

RUN apk add --no-cache nodejs ca-certificates openssl tar python build-base make && \
      update-ca-certificates && \
      npm install -g grunt-cli && \
      wget https://github.com/hakimel/reveal.js/archive/${REVEAL_VERSION}.tar.gz && \
      tar -xzf ${REVEAL_VERSION}.tar.gz && \
      mv reveal.js-${REVEAL_VERSION}/* /reveal && \
      npm install && \
      rm ${REVEAL_VERSION}.tar.gz && \
      apk del build-base make python

ADD index.html /reveal
ADD assets /reveal/assets
ADD do.scss /reveal/css/theme/source
ADD contents.md /reveal
RUN mv /reveal/assets/solarized-light.css /reveal/lib/css
RUN grunt css-themes
EXPOSE 8000

CMD npm start

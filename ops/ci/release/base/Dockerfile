ARG RUBY_JEMALLOC_VERSION=${RUBY_JEMALLOC_VERSION:-2.4.1-bundler-2.2.28}
FROM build.synbioz.com/synbioz/docker-images/ruby_jemalloc/app:${RUBY_JEMALLOC_VERSION}

ARG BUNDLE_GEMS__ITG__FR
ARG NODE_VERSION
ENV NODE_VERSION=${NODE_VERSION:-12}
ENV PATH /root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH


RUN apt-get update -q \
    && apt-get install -qqy apt-transport-https \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev \
    gnupg \
    shared-mime-info \
    libmagic-dev \
    postgresql-client \
    && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -qqy nodejs \
    && apt-get autoremove --assume-yes \
    && rm -rf /tmp/* /var/tmp/*

WORKDIR /app
COPY Gemfile* /app/
ADD vendor/ /app/vendor/
RUN bundle install --jobs 2

CMD [ "irb" ]

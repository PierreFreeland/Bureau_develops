ARG BASE_IMAGE_TAG=latest
FROM build.synbioz.com/itg/itg-hub-applicatif/base:${BASE_IMAGE_TAG}
ENV BUNDLE_WITHOUT=test:development \
    BUNDLE_WITH=production \
    RAILS_ENV=production

ARG BUNDLE_GEMS__ITG__FR

WORKDIR /app

COPY Gemfile* /app/
RUN bundle install --jobs 2

ADD . /app/

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0

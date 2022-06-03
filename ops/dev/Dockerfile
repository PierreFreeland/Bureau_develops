ARG BASE_IMAGE_TAG=latest
FROM build.synbioz.com/itg/itg-hub-applicatif/base:${BASE_IMAGE_TAG}
ARG BUNDLE_GEMS__ITG__FR

WORKDIR /app
COPY Gemfile* /app/
ADD vendor/ /app/vendor/
RUN bundle install

CMD rm -f /app/tmp/pids/server.pid && rails s -b 0.0.0.0

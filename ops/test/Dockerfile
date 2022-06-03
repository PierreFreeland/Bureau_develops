ARG BASE_IMAGE_TAG=latest
FROM build.synbioz.com/itg/itg-hub-applicatif/base:${BASE_IMAGE_TAG}
ENV BUNDLE_WITHOUT=production \
    BUNDLE_WITH=development:test
ARG BUNDLE_GEMS__ITG__FR

WORKDIR /app
COPY Gemfile* /app/
ADD vendor/ /app/vendor/
RUN bundle install

CMD rake test ALL=yes BACKTRACE=yes

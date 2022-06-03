FROM ubuntu:18.04

MAINTAINER fabien@jakimowi.cz

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&       \
    apt-get install -y      \
        build-essential     \
        cron                \
        git                 \
        libncurses5-dev     \
        libmagic-dev        \
        libpq-dev           \
        libreadline6-dev    \
        libssl1.0-dev       \
        libxrender1         \
        libyaml-dev         \
        ncftp               \
        nodejs              \
        npm                 \
        tzdata              \
        wkhtmltopdf         \
        wget                \
        zlib1g-dev          \
        zip &&              \
    apt-get clean

# configure timezone
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# install rbenv and ruby-build
COPY .ruby-version /root/ruby-versions.txt
ENV PATH /root/.rbenv/shims:/root/.rbenv/bin:$PATH
RUN xargs -L 1 echo "installing rbenv for ruby version" < /root/ruby-versions.txt && \
    git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    /root/.rbenv/plugins/ruby-build/install.sh && \
    echo 'eval "$(rbenv init -)"' | tee -a /etc/profile.d/rbenv.sh | tee -a /root/.bashrc

# configure ruby
ENV CONFIGURE_OPTS --disable-install-doc
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

# install the current ruby version and bundler
RUN xargs -L 1 rbenv install < /root/ruby-versions.txt && \
    xargs -L 1 rbenv global < /root/ruby-versions.txt && \
    gem install bundler

# install node packages
RUN npm install -g bower

# environment and application setting
ENV RAILS_ROOT='/app'
ENV RAILS_ENV='production'
ENV RACK_ENV='production'
ENV RAILS_LOG_TO_STDOUT='1'
ENV RAILS_SERVE_STATIC_FILES='1'

WORKDIR /app

# setup private gem repo access
ARG BUNDLE_GEMS_KEY
ENV BUNDLE_GEMS__ITG__FR=$BUNDLE_GEMS_KEY

# configure bundler
RUN bundle config set --local path vendor/bundle
RUN bundle config set --local without 'development test'

# Configure cron
COPY config/crontab /etc/cron.d/hub-cron
RUN chmod 0644 /etc/cron.d/hub-cron
RUN crontab /etc/cron.d/hub-cron
RUN touch /var/log/cron.log

# copy the application
RUN mkdir -p shared/pids shared/sockets tmp/pids tmp/cache
COPY . .

# install gems
RUN bundle install --jobs 20 --retry 5

# Remove apt packages required for build only
RUN apt-get remove --purge -y   \
        build-essential         \
        git                     \
        &&                      \
    apt-get clean &&            \
    apt autoremove -y

# change configuration files for production ones
COPY config/database.yml.production config/database.yml
COPY config/puma.rb.production config/puma.rb
COPY config/sidekiq.yml.production config/sidekiq.yml

# run application
ENTRYPOINT ["bash", "-c"]
CMD ["bundle exec puma -C config/puma.rb"]

# network and accessibility
EXPOSE 3000/tcp

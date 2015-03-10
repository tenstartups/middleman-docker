#
# Middleman static website baseimage docker image
#
# http://github.com/tenstartups/middleman-docker
#

FROM ruby:latest

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment.
ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color

# Install base packages.
RUN apt-get update && apt-get -y install \
  curl \
  git \
  imagemagick \
  libffi-dev \
  nano \
  wget

# Install nodejs from official source.
RUN \
  curl -sL https://deb.nodesource.com/setup | bash - && \
  apt-get install -y nodejs

# Install ruby gems.
RUN gem install \
  awesome_print \
  bundler \
  middleman \
  middleman-livereload \
  rubygems-update \
  --no-ri --no-rdoc

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define working directory.
WORKDIR /opt/middleman

# Add files.
ADD . /opt/middleman

# Copy scripts and configuration into place.
RUN \
  mv ./entrypoint /usr/local/bin/docker-entrypoint && \
  find ./script -regextype posix-extended -regex '^.+\.(rb|sh)\s*$' -exec bash -c 'f=`basename "{}"`; mv -v "{}" "/usr/local/bin/${f%.*}"' \; && \
  rm -rf ./script

# Define working directory.
WORKDIR /usr/src/web

# Define mountable directories.
VOLUME ["/var/www/website"]

# Define the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

# Expose ports.
EXPOSE 4567

# Copy the Gemfile into place and bundle.
ONBUILD ADD Gemfile /usr/src/web/Gemfile
ONBUILD ADD Gemfile.lock /usr/src/web/Gemfile.lock
ONBUILD RUN echo "gem: --no-ri --no-rdoc" > .gemrc
ONBUILD RUN rm -rf .bundle && bundle install --retry 10 --deployment

# Copy the rest of the application into place.
ONBUILD ADD . /usr/src/web

# Build the static website.
ONBUILD RUN bundle exec middleman build

# Dump out the git revision.
ONBUILD RUN \
  mkdir -p ./.git/objects && \
  echo "$(git rev-parse HEAD)" > ./build-info.txt && \
  rm -rf ./.git

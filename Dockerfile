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
  TERM=xterm-color \
  HOME=/home/middleman

# Install base packages.
RUN apt-get update && apt-get -y install \
  curl \
  graphviz \
  imagemagick \
  nano \
  rsync \
  wget

# Install nodejs from official source.
RUN \
  curl -sL https://deb.nodesource.com/setup | bash - && \
  apt-get install -y nodejs

# Install ruby gems.
RUN gem install --no-ri --no-rdoc \
  bundler \
  middleman \
  middleman-livereload

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define working directory.
WORKDIR /home/middleman

# Add files.
COPY entrypoint.rb /docker-entrypoint
COPY bundle-delete.sh /usr/local/bin/bundle-delete

# Define working directory.
WORKDIR /usr/src/web

# Define the entrypoint
ENTRYPOINT ["/docker-entrypoint"]

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
ONBUILD COPY .git/HEAD .git/HEAD
ONBUILD COPY .git/refs/heads .git/refs/heads
ONBUILD RUN \
  cat ".git/$(cat .git/HEAD 2>/dev/null | sed -E 's/ref: (.+)/\1/')" 2>/dev/null > ./REVISION && \
  rm -rf ./.git

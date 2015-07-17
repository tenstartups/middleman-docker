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
  git \
  imagemagick \
  graphviz \
  imagemagick \
  nano \
  wget

# Install nodejs from official source.
RUN \
  curl -sL https://deb.nodesource.com/setup | bash - && \
  apt-get install -y nodejs

# Install ruby gems.
RUN gem install --no-ri --no-rdoc \
  awesome_print \
  bundler \
  middleman \
  middleman-livereload \
  ruby-graphviz \
  rubygems-update

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define working directory.
WORKDIR /home/middleman

# Add files.
ADD . /home/middleman

# Copy scripts and configuration into place.
RUN \
  cp ./entrypoint /usr/local/bin/docker-entrypoint && \
  find ./script -type f -name '*.sh' | while read f; do echo 'n' | cp -iv "$f" "/usr/local/bin/`basename ${f%.sh}`" 2>/dev/null; done && \
  find ./script -type f -name '*.rb' | while read f; do echo 'n' | cp -iv "$f" "/usr/local/bin/`basename ${f%.rb}`" 2>/dev/null; done && \
  rm -rf ./script

# Define working directory.
WORKDIR /usr/src/web

# Define the entrypoint
ENTRYPOINT ["/home/middleman/entrypoint"]

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
  echo "$(git rev-parse HEAD)" > ./REVISION && \
  rm -rf ./.git

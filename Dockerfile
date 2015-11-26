#
# Middleman static website baseimage docker image
#
# http://github.com/tenstartups/middleman-docker
#

FROM tenstartups/alpine-ruby:latest

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment.
ENV \
  TERM=xterm-color \
  HOME=/home/middleman

# Install base packages.
RUN \
  apk --update add graphviz imagemagick libffi-dev libxml2-dev libxslt-dev nodejs rsync && \
  rm -rf /var/cache/apk/*

# Define working directory.
WORKDIR ${HOME}

# Install ruby gems.
RUN \
  echo "gem: --no-ri --no-rdoc" > ${HOME}/.gemrc && \
  gem install nokogiri -- --use-system-libraries && \
  gem install bundler json middleman middleman-livereload minitest

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
ONBUILD RUN \
  rm -rf .bundle && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle install --retry 10 --deployment

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

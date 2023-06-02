FROM ruby:3.2.2

WORKDIR /var/app
RUN mkdir -p tmp/pids 
# pids are for daemonize. you dont daemonize in docker
# You shouldnt need this

RUN gem update --system

RUN set -eux; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  postgresql-client \
  curl \
  libgirepository1.0-dev \
  libpoppler-glib-dev \
  npm \
  ; \
  echo 'Acquire::https::deb.nodesource.com::Verify-Peer "false";' >> /etc/apt/apt.conf.d/99nodecrap; \
  curl -sSL https://deb.nodesource.com/setup_14.x | bash -; \
  curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  nodejs \
  poppler-utils \
  yarn \
  ; \
  rm -rf /var/lib/apt/lists/*;


ENV BUNDLE_DEPLOYMENT=true BUNDLE_FROZEN=true BUNDLE_WITHOUT="development:test" RAILS_ENV=production RACK_ENV=production SECRET_KEY_BASE=foofoooofoo BUNDLE_IGNORE_MESSAGES=true
ENV PATH=$PATH:/var/app/bin:/var/app/node_modules/bin

COPY Gemfile Gemfile.lock /var/app/
RUN bundle install -j$(nproc)

COPY package.json yarn.lock /var/app/
RUN yarn install

COPY . /var/app

RUN bundle exec rails assets:clobber assets:precompile

CMD ["/bin/bash"]

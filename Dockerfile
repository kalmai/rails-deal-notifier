# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.4.1
ARG RAILS_ENV
ARG RAILS_MASTER_KEY

FROM registry.docker.com/library/ruby:$RUBY_VERSION-bookworm as base

# Rails app lives here
WORKDIR /rails

# Set environment
ENV RAILS_ENV=$RAILS_ENV \
    BUNDLE_DEPLOYMENT="1" \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config libpq-dev nodejs && \
    npm install -g yarn && \
    yarn add tailwindcss-animate

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 1 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Uncomment this to make MacOS work...?
# RUN mkdir -p /tmp/pids/ && chown -R rails:rails /tmp/pids/

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000

CMD ["./bin/rails", "server", "-p", "3000"]

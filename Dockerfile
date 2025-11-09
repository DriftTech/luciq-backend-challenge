# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.7
FROM ruby:$RUBY_VERSION-slim AS base

# App lives here
WORKDIR /app

# Install OS dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-libmysqlclient-dev \
    git \
    libvips \
    libyaml-dev \
    pkg-config \
    curl && \
    rm -rf /var/lib/apt/lists/*


# Environment variables
ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test"

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .



# Default command (can be overridden in docker-compose)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

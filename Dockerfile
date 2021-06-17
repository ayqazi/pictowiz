# syntax=docker/dockerfile:experimental
FROM ruby:2.7.1-alpine3.12

ARG bundle_jobs=4

RUN apk add --no-cache build-base \
                       openssl \
                       graphicsmagick \
                       shared-mime-info

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN --mount=type=ssh \
    mkdir -p -m 0700 ~/.ssh && \
    echo 'StrictHostKeyChecking no' > ~/.ssh/config && \
    bundle config frozen 1 && \
    bundle config set system 'true' && \
    bundle install --jobs "${bundle_jobs}"

COPY . .

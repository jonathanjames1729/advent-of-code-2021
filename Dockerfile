FROM ruby:2.7.5-bullseye

RUN apt-get update && \
    apt-get install --yes \
                    --no-install-recommends \
                    emacs && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/sources
WORKDIR /root/sources

FROM ruby:2.7.5-bullseye

RUN apt-get update && \
    apt-get install --yes \
                    --no-install-recommends \
                    emacs && \
    rm -rf /var/lib/apt/lists/*

COPY init.el /root/.emacs.el
RUN mkdir -p /root/sources /root/.emacs.d && \
    chmod 777 /root/sources /root/.emacs.d /root/.emacs.el

ENV TERM=xterm-256color

WORKDIR /root/sources

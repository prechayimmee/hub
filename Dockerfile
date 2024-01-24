FROM ruby:3.0

RUN apt-get update \
	&& apt-get install -y sudo golang --no-install-recommends
RUN apt-get purge --auto-remove -y curl \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -r app && useradd -r -g app -G sudo app \
	&& mkdir -p /home/app && chown -R app:app /home/app
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER app

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /home/app/workdir

COPY Gemfile Gemfile.lock ./
RUN /opt/hostedtoolcache/Ruby/3.0/x64/bin/bundle install

ENV LANG C.UTF-8
ENV USER app

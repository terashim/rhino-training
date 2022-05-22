ARG R_VERSION="4.2.0"
FROM rocker/r-ver:${R_VERSION} AS base

# install apt packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
  && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    ssh \
    libxt-dev \
    libxml2-dev \
    libgit2-dev

# install renv
ARG RENV_VERSION="0.15.4"
COPY docker/install-renv.R /install-renv.R
RUN Rscript /install-renv.R $RENV_VERSION

FROM base AS builder

WORKDIR /workspace

# install apt packages
RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get update \
  && apt-get -y install --no-install-recommends yarn nodejs

# install R packages using renv
COPY renv.lock /workspace/renv.lock
RUN \
  --mount=type=cache,target=/root/.cache \
  Rscript -e "renv::restore(library = '/usr/local/lib/R/site-library')"

# build Sass and JS
COPY config.yml rhino.yml /workspace/
COPY app/styles /workspace/app/styles
RUN \
  --mount=type=cache,target=/usr/local/share/.cache \
  Rscript -e "rhino::build_sass()"
COPY app/js /workspace/app/js
RUN \
  --mount=type=cache,target=/usr/local/share/.cache \
  Rscript -e "rhino::build_js()"

FROM base

WORKDIR /rhino
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=builder /workspace/app/static /rhino/app/static
COPY app.R config.yml rhino.yml /rhino/
COPY app/view /rhino/app/view
COPY app/logic /rhino/app/logic
COPY app/main.R /rhino/app/main.R
RUN echo 'options(box.path = "/rhino", shiny.port = 3838, shiny.host="0.0.0.0")' >> /usr/local/lib/R/etc/Rprofile.site
CMD ["Rscript", "app.R"]
EXPOSE 3838

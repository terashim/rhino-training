ARG R_VERSION="4.2.0"
FROM rocker/r-ver:${R_VERSION} AS base

# install apt packages
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
RUN \
  --mount=type=bind,source=docker/install-renv.R,target=/install-renv.R \
  Rscript /install-renv.R $RENV_VERSION

# install R packages using renv
RUN mkdir /rhino
WORKDIR /rhino
RUN \
  --mount=type=bind,source=renv.lock,target=/rhino/renv.lock \
  --mount=type=cache,target=/root/.cache \
  Rscript -e "renv::restore()"

FROM base AS builder

# install Node.js and yarn
RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    fonts-ipaexfont \
    curl \
    gnupg2 \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get update \
  && apt-get -y install --no-install-recommends yarn nodejs

# build Sass and JS
COPY config.yml rhino.yml /rhino/

COPY app/styles /rhino/app/styles
RUN \
  --mount=type=cache,target=/usr/local/share/.cache \
  --mount=type=cache,target=/rhino/.rhino \
  Rscript -e "rhino::build_sass()"

COPY app/js /rhino/app/js
RUN \
  --mount=type=cache,target=/usr/local/share/.cache \
  --mount=type=cache,target=/rhino/.rhino \
  Rscript -e "rhino::build_js()"

FROM base

COPY --from=builder /rhino/app/static /rhino/app/static
COPY app.R config.yml rhino.yml /rhino/
COPY app/view /rhino/app/view
COPY app/logic /rhino/app/logic
COPY app/main.R /rhino/app/main.R
RUN echo 'options(box.path = "/rhino", shiny.port = 3838, shiny.host="0.0.0.0")' >> /usr/local/lib/R/etc/Rprofile.site
CMD ["Rscript", "app.R"]
EXPOSE 3838

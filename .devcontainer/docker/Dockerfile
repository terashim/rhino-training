ARG R_VERSION="4.2.0"
FROM rocker/rstudio:${R_VERSION}

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ssh \
    libxt-dev \
    libxml2-dev \
    libgit2-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# renv をインストール
ARG RENV_VERSION="0.15.4"
COPY install-renv.R /install-renv.R
RUN Rscript /install-renv.R $RENV_VERSION \
  && su -c 'mkdir -p /home/rstudio/{.local/share/renv/cache,.renv/library}' rstudio
COPY --chown=rstudio:rstudio .Renviron /home/rstudio/.Renviron

# 追加インストール
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    fonts-ipaexfont \
    curl \
    gnupg2 \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get update \
  && apt-get -y install --no-install-recommends yarn nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

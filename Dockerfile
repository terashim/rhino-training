ARG R_VERSION="4.2.0"
FROM rocker/r-ver:${R_VERSION}

# install Node.js and yarn
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

# install apt packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ssh \
    libxt-dev \
    libxml2-dev \
    libgit2-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install renv
ARG RENV_VERSION="0.15.4"
COPY ./docker/install-renv.R /install-renv.R
RUN Rscript /install-renv.R $RENV_VERSION

# install R packages using renv
RUN mkdir /rhino
WORKDIR /rhino
COPY renv.lock /rhino/renv.lock
RUN Rscript -e "renv::restore()"

# build Sass and JS
COPY config.yml /rhino/config.yml
COPY rhino.yml /rhino/rhino.yml

COPY app/styles /rhino/app/styles
RUN Rscript -e "rhino::build_sass()"

COPY app/js /rhino/app/js
RUN Rscript -e "rhino::build_js()"

# Shiny app settings
RUN echo 'options(box.path = "/rhino", shiny.port = 3838, shiny.host="0.0.0.0")' >> /usr/local/lib/R/etc/Rprofile.site
COPY . /rhino
CMD ["Rscript", "app.R"]
EXPOSE 3838

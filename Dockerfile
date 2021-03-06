FROM ubuntu:20.04 AS buildOpenCpu

ENV BRANCH 2.2

ENV DEBIAN_FRONTEND noninteractive

# Install.
RUN \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y software-properties-common gnupg 

RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9  && \
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' 
  
RUN  \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:opencpu/opencpu-2.2 && \
  apt-get update && \
  apt-get install -y wget make devscripts apache2-dev apache2 libapreq2-dev r-base r-base-dev libapparmor-dev libcurl4-openssl-dev libprotobuf-dev protobuf-compiler libcairo2-dev xvfb xauth xfonts-base curl libssl-dev libxml2-dev libicu-dev pkg-config libssh2-1-dev locales apt-utils && \
  useradd -ms /bin/bash builder

# Different from debian
RUN apt-get install -y language-pack-en-base

USER builder

# Build opencpu-server
RUN \
  cd ~ && \
  wget --quiet https://github.com/opencpu/opencpu-server/archive/v${BRANCH}.tar.gz && \
  tar xzf v${BRANCH}.tar.gz && \
  cd opencpu-server-${BRANCH} && \
  dpkg-buildpackage -us -uc > /dev/null

# Build R packages used by Snippet Service
USER root
RUN R -e 'install.packages(c("ProjectManagement","tidyverse", "flextable", "here", "kableExtra", "caTools", "bitops"))' > /dev/null

FROM ubuntu:20.04 AS deployOpenCpu

ENV RSTUDIO 1.4.1103

USER root

ENV DEBIAN_FRONTEND noninteractive
COPY --from=buildOpenCpu /home/builder/opencpu-lib_*.deb /home/builder/opencpu-lib_*.deb
COPY --from=buildOpenCpu /home/builder/opencpu-server_*.deb /home/builder/opencpu-server_*.deb


RUN \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y software-properties-common gnupg 

RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9  && \
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' 

RUN \
  apt-get update && \
  apt-get -y dist-upgrade 
 
 RUN \
  apt-get install -y libapache2-mod-r-base libssl-dev r-base r-base-core r-recommended r-base-dev apache2 ssl-cert locales wget

RUN \  
  dpkg -i /home/builder/opencpu-lib_*.deb  && \
  dpkg -i /home/builder/opencpu-server_*.deb
 

USER opencpu
COPY --from=buildOpenCpu /usr/local/lib/R/site-library /usr/local/lib/R/site-library

USER root

RUN \
  apt-get install -y gdebi-core git sudo && \
  wget --quiet https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO}-amd64.deb && \
  gdebi --non-interactive rstudio-server-${RSTUDIO}-amd64.deb && \
  rm -f rstudio-server-${RSTUDIO}-amd64.deb && \
  echo "server-app-armor-enabled=0" >> /etc/rstudio/rserver.conf

# Prints apache logs to stdout
RUN \
  ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
  ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
  ln -sf /proc/self/fd/1 /var/log/opencpu/apache_access.log && \
  ln -sf /proc/self/fd/1 /var/log/opencpu/apache_error.log

# Set opencpu password so that we can login
RUN \
  echo "opencpu:opencpu" | chpasswd


# Apache ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004

# SNIPPET LIBRARIES START
USER root
COPY snippet_0.1.7.tar.gz snippet_0.1.7.tar.gz
RUN R CMD INSTALL snippet_0.1.7.tar.gz --library=/usr/local/lib/R/site-library

RUN sudo apt-get install -y pandoc
RUN sudo apt-get install -y texlive-base
# SNIPPET LIBRARIES END

# Start non-daemonized webserver
USER root
CMD /usr/lib/rstudio-server/bin/rserver && apachectl -DFOREGROUND



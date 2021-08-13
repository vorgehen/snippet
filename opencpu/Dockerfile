FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

# Install.
RUN \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y software-properties-common
  
RUN \ 
  add-apt-repository -y ppa:opencpu/opencpu-2.2 && \
  apt-get update && \
  apt-get upgrade && \
RUN \ 
  apt-get install -y opencpu-server && \
  apt-get install -y rstudio-server && \
  apt-get install -y pandoc && \
  apt-get install -y texlive-base

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
USER opencpu
RUN R -e 'install.packages(c("ProjectManagement","tidyverse", "flextable", "here", "kableExtra", "caTools", "bitops"))'

USER root
COPY snippet_0.1.7.tar.gz snippet_0.1.7.tar.gz
RUN R CMD INSTALL snippet_0.1.7.tar.gz --library=/usr/local/lib/R/site-library
# SNIPPET LIBRARIES END

# Start non-daemonized webserver
USER root
CMD /usr/lib/rstudio-server/bin/rserver && apachectl -DFOREGROUND

FROM rocker/shiny

RUN rm -rf /srv/shiny-server/*

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libxml2-dev 

RUN install2.r --error \
    TTR    

RUN install2.r --error \
    httr \
    dplyr \
    tidyr \
    jsonlite \
    ggplot2 \
    ggthemes \
    shinythemes

COPY gdax-explorer /srv/shiny-server

CMD ["/usr/bin/shiny-server.sh"]
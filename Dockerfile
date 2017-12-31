FROM alpine:3.5

ARG BRANCH=development
ARG REPOSITORY=https://github.com/PirateBox-Dev/PirateBoxScripts_Webserver.git

RUN apk add --update  python2 lighttpd perl php5 php5-cgi openrc git make

# Get development version
RUN git clone $REPOSITORY && \
    cd PirateBoxScripts_Webserver && \
    git checkout origin/$BRANCH && \
    make package

# Deploy & Adjust config
# Also remove redirect with hostname included. That won't work.
RUN mkdir /opt && \
   cp PirateBoxScripts_Webserver/piratebox-ws*.tar.gz . &&\
   tarfile=$( ls -1 piratebox-ws*.tar.gz ) &&\
   tar xzf "${tarfile}"  && \
   cp -rv piratebox/piratebox /opt && \
    sed -i -e 's/^DO_IFCONFIG="yes"/DO_IFCONFIG="no"/' \
           -e 's/^USE_APN="yes"/USE_APN="no"/' \
           -e 's/^USE_DNSMASQ="yes"/USE_DNSMASQ="no"/' \
           /opt/piratebox/conf/piratebox.conf  && \
    sed -i -e 's/^FIREWALL_FETCH_DNS="yes"/FIREWALL_FETCH_DNS="no"/' \
          /opt/piratebox/conf/firewall.conf && \
    sed -i -e 's|http://piratebox.lan||' /opt/piratebox/www/index.html

# Do PirateBox init
RUN /opt/piratebox/bin/install_piratebox.sh part2 ; \
    /opt/piratebox/bin/install_piratebox.sh imageboard

COPY start_piratebox.sh /

## Cleanup
RUN apk del git make && \
    rm -rv PirateBoxScripts_Webserver

# Lighttpd Port
EXPOSE 80
# Droopy Port  (soon absolete)
EXPOSE 8080

#Share space
VOLUME ["/opt/piratebox/share"]


CMD [ "/start_piratebox.sh" ]


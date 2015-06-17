FROM ubuntu:14.04

MAINTAINER Peter Dai lavadiablo@gmail.com

#Update
RUN apt-get update
RUN apt-get -y upgrade

#Tool
RUN apt-get -y --force-yes install wget
RUN apt-get -y --force-yes install unzip

#Tomcat
RUN apt-get -y --force-yes install tomcat7
RUN cd /usr/share/tomcat7 && ln -s /etc/tomcat7 conf
RUN ln -s /var/lib/tomcat7/webapps/ /usr/share/tomcat7/webapps
VOLUME /usr/share/tomcat7/logs

#PostgerSQL JDBC
RUN wget http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc4.jar -P /var/lib/tomcat7/webapps/xwiki/WEB-INF/lib/

#Download WAR from xwiki
RUN apt-get -y --force-yes install curl
RUN curl -o xwikiDownloadPage.html http://download.forge.ow2.org/xwiki/
ADD versionPicker.py .
RUN apt-get -y --force-yes install python
RUN python versionPicker.py >> downloader.sh
RUN chmod +x downloader.sh
RUN sh downloader.sh

#Install LibreOffice
RUN apt-get -y --force-yes install libreoffice 

#Config
RUN perl -i -p0e "s/# environment.permanentDirectory/  environment.permanentDirectory/smg" /var/lib/tomcat7/webapps/xwiki/WEB-INF/xwiki.properties
RUN perl -i -p0e "s/# xwiki.authentication.ldap=1/  xwiki.authentication.ldap=1/smg" /var/lib/tomcat7/webapps/xwiki/WEB-INF/xwiki.cfg
COPY ./conf/hibernate.cfg.xml /var/lib/tomcat7/webapps/xwiki/WEB-INF/hibernate.cfg.xml
ENV JAVA_OPTS  -Djava.awt.headless=true

#Start
CMD /usr/share/tomcat7/bin/catalina.sh run

#Port
EXPOSE 8080

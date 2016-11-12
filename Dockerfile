FROM dadez/jre:latest
MAINTAINER dadez <dadez@protonmail.com>

ADD ./configureWebXMLforDocker.groovy /tmp/
ADD ./configureServerXMLforDocker.groovy /tmp/

ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

ENV TIMEZONE Europe/Zurich
ENV LANG=en_US.UTF-8
ENV LC_ALL=

#override proxy settings
ENV http_proxy=""
ENV https_proxy=""

RUN apk add --no-cache gnupg

ARG TOMCAT_MAJOR
ENV TOMCAT_MAJOR ${TOMCAT_MAJOR:-8}
ARG TOMCAT_VERSION
ENV TOMCAT_VERSION ${TOMCAT_VERSION:-8.5.8}

ENV TOMCAT_TGZ_URL http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
ENV TOMCAT_ASC_URL http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.asc

RUN apk add --no-cache --virtual .fetch-deps \
	ca-certificates \
	tar \
	openssl

RUN apk add --update \
	unzip \
	bash \
	curl \
	tzdata

#install tomcat
RUN set -x \
	&& echo $TIMEZONE > /etc/timezone \
		&&  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \

	&& wget -O tomcat.tar.gz "$TOMCAT_TGZ_URL" \
#	&& wget -O tomcat.tar.gz.asc "$TOMCAT_ASC_URL" \
#	&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

#configure tomcat
#remove unneeded webapps
RUN rm -rf $CATALINA_HOME/webapps/docs \
    $CATALINA_HOME/webapps/examples \
    $CATALINA_HOME/webapps/host-manager \
    $CATALINA_HOME/webapps/manager \

    #remove unneeded files
    && rm -f $CATALINA_HOME/LICENSE \
    $CATALINA_HOME/NOTICE \
    $CATALINA_HOME/RELEASE-NOTES \
    $CATALINA_HOME/RUNNING.txt \

    #Overwrite Server Version
    && mkdir -p $CATALINA_HOME/lib/org/apache/catalina/util \

	#empty ROOT webapp
    && rm -rf $CATALINA_HOME/webapps/ROOT/*

#workaround for allow groovy to run
RUN ln -sf /bin/bash /bin/sh
#install groovy
WORKDIR /opt/
ENV GROOVY_HOME /opt/groovy
ENV PATH ${PATH}:${JAVA_HOME}/bin:${GROOVY_HOME}/bin
ENV GROOVY_VERSION=2.4.7
RUN curl -sLo /opt/groovy.zip https://bintray.com/artifact/download/groovy/maven/apache-groovy-binary-${GROOVY_VERSION}.zip \
        && unzip /opt/groovy.zip \
        && rm -f /opt/groovy.zip \
        && ln -sf /opt/groovy-${GROOVY_VERSION} /opt/groovy

#configure server.xml
RUN groovy /tmp/configureServerXMLforDocker.groovy -path $CATALINA_HOME/conf/server.xml \
    #configure web.xml
    && groovy /tmp/configureWebXMLforDocker.groovy -path $CATALINA_HOME/conf/web.xml \

    #restore default shell
    && ln -sf /bin/busybox /bin/sh

#overwrite some files
ADD ./conf/logging.properties $CATALINA_HOME/conf/
ADD ./conf/ServerInfo.properties $CATALINA_HOME/lib/org/apache/catalina/util/

ADD ./webapps/ROOT/index.html $CATALINA_HOME/webapps/ROOT/
ADD ./webapps/ROOT/error.jsp $CATALINA_HOME/webapps/ROOT/
ADD ./webapps/ROOT/MemoryInfo.jsp $CATALINA_HOME/webapps/ROOT/
ADD ./webapps/ROOT/SystemInfo.jsp $CATALINA_HOME/webapps/ROOT/

#cleanup
RUN apk del \
	bash \
	unzip \
	curl \
	tzdata \
	&& rm -rf /var/cache/apk/* /tmp/* /opt/groovy*

WORKDIR /opt/tomcat

ENV JAVA_OPTS -Duser.timezone=Europe/Zurich
ENV CATALINA_OPTS -Dfile.encoding=UTF-8

EXPOSE 8080
CMD ["catalina.sh", "run"]

[![](https://images.microbadger.com/badges/image/dadez/tomcat8:autobuild.svg)](https://microbadger.com/images/dadez/tomcat8:autobuild "Get your own image badge on microbadger.com")  [![](https://images.microbadger.com/badges/version/dadez/tomcat8:autobuild.svg)](https://microbadger.com/images/dadez/tomcat8:autobuild "Get your own version badge on microbadger.com")

# Description
Tomcat image following most of the security considerations from [owasp](https://www.owasp.org/index.php/Securing_tomcat).

Run in an oracle server-jre jvm, based on alpine-linux 3.4.

Timezone set to Europe/Zurich in JAVA_OPTS

File encoding set to UTF-8 in CATALINA_OPTS

There is only one webapp (ROOT) which servers a basic index.html page and information pages
- MemoryInfo.jsp
- SystemInfo.jsp

Consider to remove this pages in production.



##build
* build simple
```
docker build -t tomcat8 .
```

* build passing tomcat version as argument
```
docker build --build-arg TOMCAT_VERSION=8.5.8 -t tomcat8 .
```

* build behind a proxy
```
docker build --build-arg PROXY="http://myproxy:8080" -t tomcat8 .
```

##run

* run simple
```
docker run -it --rm -p 8080:8080 -name tomcat dadez/tomcat8
```

Tomcat logs are send to sysout excepted accesslog

* run & map accesslog to your host (without change logs ownership)
```
mkdir -p logs # create a folder for store files
docker run -it --rm -p 8080:8080 \
--name tomcat \
-v $(pwd -P)/logs:/opt/tomcat/logs \
dadez/tomcat8
```

The log files created are owned by the uid and gid 1000
you can 
* run passing your own uid and gid as follow
```
mkdir -p logs # create a folder for store files
docker run -it --rm -p 8080:8080 \
-v $(pwd -P)/logs:/opt/tomcat/logs \
-e UID=$(id -u $USER) \
-e GID=$(id -g $USER) \
--name tomcat \
dadez/tomcat8
```


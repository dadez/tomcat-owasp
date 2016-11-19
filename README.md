# tomcat
owaspized tomcat

##build
* build simple
`docker build -t tomcat8 .`

* build passing tomcat version as argument
`docker build --build-arg TOMCAT_VERSION=8.5.8 -t tomcat8 .`

##run

* run simple
```
docker run -it --rm -p 8080:8080 dadez/tomcat8
```

Tomcat logs are send to sysout excepted accesslog

* run & map accesslog to your host (without change logs ownership)
```
mkdir -p logs # create a folder for store files
docker run -it --rm -p 8080:8080 -v $(pwd -P)/logs:/opt/tomcat/logs dadez/tomcat8
```

The log files created are owned by the uid and gid 1000
you can pass your own uid and gid on run command as follow
```
mkdir -p logs # create a folder for store files
docker run -it --rm -p 8080:8080 -v $(pwd -P)/logs:/opt/tomcat/logs -e UID=$(id -u $USER) -e GID=$(id -g $USER) dadez/tomcat8
```


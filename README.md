# tomcat
owaspized tomcat

#build simple
docker build -t tomcat8 .

#build passing tomcat version as argument
docker build --build-arg TOMCAT_VERSION=8.5.8 -t tomcat8 .

#logs
all logs sending to sysout exepted accesslog

## how to map accesslog to your host
mkdir -p logs
docker run -it --rm -p 80:8080 -v $(pwd -P)/logs:/opt/tomcat/logs dadez/tomcat8


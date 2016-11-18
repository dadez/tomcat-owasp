# tomcat
owaspized tomcat

##build
* build simple
`docker build -t tomcat8 .`

* build passing tomcat version as argument
`docker build --build-arg TOMCAT_VERSION=8.5.8 -t tomcat8 .`

##run
In the following samples we map the tomcat container exposed port (8080) to the default http port for easy use

* run simple
`docker run -it --rm -p 8080:8080 dadez/tomcat8`

* run & map accesslog to your host
```
mkdir -p logs # create a folder for store files
docker run -it --rm -p 8080:8080 -v $(pwd -P)/logs:/opt/tomcat/logs dadez/tomcat8
```

#### the owner of file is root
-- see this [article](https://stackoverflow.com/questions/23544282/what-is-the-best-way-to-manage-permissions-for-docker-shared-volumes#27021154)
or run 
`chmod 2775 logs`
so the group will can read the files, but it isn't very nice

##logs
all logs sending to sysout exepted accesslog

#!/bin/sh
set -e

# based on https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
#
# Add local user tomcat
# Either use the UID / GID if passed in at runtime or
# fallback to uid and gid 1000

userID=${UID:-1000}
groupID=${GID:-1000}

userName=tomcat
groupName=tomcat

echo "Starting with UID: $userID and GID: $groupID"
if [[ ! $(grep ":$groupID:" /etc/group) ]]
 then
    addgroup -g ${groupID} ${groupName}
 else
    groupName=$(grep ":$groupID:" /etc/group | cut -f1 -d:)
fi


adduser -D -H -G ${groupName} -u ${userID} ${userName}
#tomcat files are owned by user tomcat
chown -R ${userName}:${groupName} .
#set config files readonly
chmod 400 conf/*
#set only write/execute to logs directory
#disabled now
#chmod 300 logs

exec su-exec ${userName} "$@"


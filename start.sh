#!/bin/bash

echo "nginx config test"
nginx -t
if [ -f /data/ext/service/$PACKAGE_NAME ];then
  echo "nginx start daemon"
  nginx
  echo "backend start: java -jar /data/ext/service/$PACKAGE_NAME"
  java -jar -Xms1536m -Xmx1536m -Dfile.encoding=UTF-8  /data/ext/service/$PACKAGE_NAME
else
  echo "nginx start daemon off"
  nginx -g 'daemon off;'
fi
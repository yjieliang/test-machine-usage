# 基础镜像
FROM bkci/extension:latest

# 扩展服务执行包路径变量(系统参数，请勿改动)
ARG filePath

# 扩展服务执行包名称变量(系统参数，请勿改动)
ARG packageName

# 设置环境变量
ENV PACKAGE_NAME=${packageName}

# 维护者信息
MAINTAINER lockiechen lockiechen@tencent.com

# 设置工作目录
WORKDIR /data/ext/service

# 把执行包文件拷贝到容器的目录
#ADD $filePath /data/ext/service/$PACKAGE_NAME

ADD ./devops_release/* /data/ext/service/
ADD start.sh /data/ext/service/start.sh

COPY ./frontend/dist /usr/share/nginx/static

# 设置ENTRYPOINT
ENTRYPOINT ["/bin/sh", "/data/ext/service/start.sh"]
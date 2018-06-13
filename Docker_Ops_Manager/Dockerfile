From centos
ENV OPSMANAGER_VERSION=3.6.7.47243.20180606T1452Z-1 \
    OPSMANAGER_CFG=/opt/mongodb/mms/conf/conf-mms.properties \
    OPSMANAGER_BACKUPCFG=/opt/mongodb/mms-backup-daemon/conf/conf-daemon.properties \
    OPSMANAGER_MONGO_APP=localhost:27017 \
    OPSMANAGER_CENTRALURL=localhost \
    OPSMANAGER_CENTRALURLPORT=8080 \
    OPSMANAGER_BACKUPURL=${OPSMANAGER_CENTRALURL} \
    OPSMANAGER_FROMEMAIL=nobody@nobody \
    OPSMANAGER_ADMINEMAIL=nobody@nobody \
    OPSMANAGER_REPLYTOEMAIL=nobody@nobody \
    OPSMANAGER_ADMINFROMEMAIL=nbody@nobody \
    OPSMANAGER_BOUNCEEMAIL=nobody@nobody \
    OPSMANAGER_APPLOG=/opt/mongodb/mms/logs \
    OPSMANAGER_BACKUPLOG=/opt/mongodb/mms-backup-daemon/logs \
    OPSMANAGER_BACKUPMONGO=localhost:27017 \
    OPSMANAGER_BACKUPPATH=/backup/ 

# download url: https://www.mongodb.com/subscription/downloads/ops-manager
# sample Ops manager download url: 
# https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-1.8.1.290-1.x86_64.rpm
# https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-2.0.2.337-1.x86_64.rpm
# backup : https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-backup-daemon-1.8.1.290-1.x86_64.rpm


# INSTALL MMS & MMS-BACKUP
RUN  curl -OL https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-${OPSMANAGER_VERSION}.x86_64.rpm \
    && rpm -ivh mongodb-mms-${OPSMANAGER_VERSION}.x86_64.rpm && rm -f mongodb-mms-${OPSMANAGER_VERSION}.x86_64.rpm

RUN echo '[mongodb-enterprise]' >> /etc/yum.repos.d/mongodb-enterprise.repo && \
echo 'name=MongoDB Enterprise Repository' >> /etc/yum.repos.d/mongodb-enterprise.repo && \
echo 'baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/3.6/$basearch/' >> /etc/yum.repos.d/mongodb-enterprise.repo && \
echo 'gpgcheck=1' >> /etc/yum.repos.d/mongodb-enterprise.repo && \
echo 'enabled=1'  >> /etc/yum.repos.d/mongodb-enterprise.repo && \
echo 'gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc'  >> /etc/yum.repos.d/mongodb-enterprise.repo && \
yum install -y mongodb-enterprise && yum clean all

# INSTALL few related package
RUN yum install -y python-setuptools \
                sudo \
                dstat \
                nmap \
                telnet \
                openssl \
                net-tools \
                postfix \
                htop \
    && easy_install supervisor \
    && yum clean all \
    && cat /etc/sudoers| grep -ivE requiretty > /tmp/sudoers && mv /tmp/sudoers /etc/sudoers \
    && ln -s /opt/mongodb/mms/logs /root/logs \
    && ln -s /data/appdb/mongodb.log /root/applog

EXPOSE ${OPSMANAGER_CENTRALURLPORT}/tcp
VOLUME [${OPSMANAGER_APPLOG}]

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
COPY startup.sh /startup.sh
RUN chmod 755 startup.sh

ENTRYPOINT ["/sbin/entrypoint.sh","app:start"]
#CMD ["app:start"]


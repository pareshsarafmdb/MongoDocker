#!/bin/bash -x
set +e


appStart () {

# detecting localhost mongo or not
#IP=`cat /etc/hosts | grep 172 | awk '{print $1}'`
IP=localhost
echo ${OPSMANAGER_MONGO_APP} | grep localhost > /dev/null
if [ $? -eq 0 ]; then
  nmap -Pn -p27017 $IP | grep open > /dev/null
  if [ $? -eq 0 ]; then
    echo 'local mongo is running'
  else
    mkdir -p /data/appdb; chown -R mongod:mongod /data/appdb; nohup sudo -u mongod mongod --port 27017 --dbpath /data/appdb --logpath /data/appdb/mongodb.log &
    until [ `nmap -Pn -p27017 $IP | grep open > /dev/null; echo $?` -eq 0 ]; do echo 'sleeping for 27017'; sleep 1; done
  fi
fi

# backup cfg and rehash configure file
cp -f ${OPSMANAGER_CFG} ${OPSMANAGER_CFG}.BAK \
    && cat ${OPSMANAGER_CFG} | sed -e "s;mms.centralUrl=$;mms.centralUrl=http://${OPSMANAGER_CENTRALURL}:${OPSMANAGER_CENTRALURLPORT};g" ${OPSMANAGER_CFG} \
     -e "s;mms.fromEmailAddr=$;mms.fromEmailAddr=${OPSMANAGER_FROMEMAIL};g" \
     -e "s;mms.adminEmailAddr=$;mms.adminEmailAddr=${OPSMANAGER_ADMINEMAIL};g" \
     -e "s;mms.replyToEmailAddr=$;mms.replyToEmailAddr=${OPSMANAGER_REPLYTOEMAIL};g" \
     -e "s;mms.adminFromEmailAddr=$;mms.adminFromEmailAddr=${OPSMANAGER_ADMINFROMEMAIL};g" \
     -e "s;mongo.mongoUri=mongodb://localhost:27017;mongo.mongoUri=mongodb://${OPSMANAGER_MONGO_APP};g" \
     -e "s;mongo.mongoUri=mongodb://127.0.0.1:27017;mongo.mongoUri=mongodb://${OPSMANAGER_MONGO_APP};g" \
     -e "s;mms.bounceEmailAddr=$;mms.bounceEmailAddr=${OPSMANAGER_BOUNCEEMAIL};g" > ${OPSMANAGER_CFG}.new && mv -f ${OPSMANAGER_CFG}.new ${OPSMANAGER_CFG}
}
case ${1} in
  app:start)
    appStart
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
#    time /etc/init.d/mongodb-mms start
#    time /etc/init.d/mongodb-mms-backup-daemon start

    ;;
  bash)
    echo 'starting bash'
    exec bash
    ;;
  *) echo 'quiting..' ;;
esac

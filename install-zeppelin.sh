#!/usr/bin/env bash
echo "Disable ipatbles"
sudo service iptables stop
sudo chkconfig iptables off

pushd /usr/local/

if [ ! -d zeppelin-0.7.2-bin-netinst ]; then

echo "Downloading Zeppelin..."
wget http://archive.apache.org/dist/zeppelin/zeppelin-0.7.2/zeppelin-0.7.2-bin-netinst.tgz
tar -xzf zeppelin-0.7.2-bin-netinst.tgz
rm -rf zeppelin-0.7.2-bin-netinst.tgz

fi

pushd zeppelin-0.7.2-bin-netinst
echo "List Interpreters..."
./bin/install-interpreter.sh  -l

REQUIRED_INTERPRETERS=file,hbase,md,shell,python,pig
echo "Install Interpreters: $REQUIRED_INTERPRETERS"
./bin/install-interpreter.sh  -n $REQUIRED_INTERPRETERS

echo "Update Interpreters..."
cat conf/zeppelin-site.xml.template > conf/zeppelin-site.xml
cat conf/zeppelin-env.sh.template > conf/zeppelin-env.sh
echo 'export ZEPPELIN_MEM=" -Xms2048m -Xmx2048m -XX:MaxPermSize=1024m "' >> conf/zeppelin-env.sh
echo 'export ZEPPELIN_INTP_MEM=" -Xms2048m -Xmx2048m -XX:MaxPermSize=1024m "' >> conf/zeppelin-env.sh

popd # /usr/local/

rm -rf zeppelin
ln -sf zeppelin-0.7.2-bin-netinst zeppelin
(! id -u zeppelin > /dev/null 2>&1 ) && adduser zeppelin
chown -R zeppelin:zeppelin zeppelin zeppelin-0.7.2-bin-netinst

popd # /

echo "Zeppelin is Ready Now!"
echo "Please use this command to start your service: "
echo "sudo -u zeppelin /usr/local/zeppelin/bin/zeppelin-daemon.sh start"
echo "Please use this command to stop your service: "
echo "sudo -u zeppelin /usr/local/zeppelin/bin/zeppelin-daemon.sh stop"
#!/usr/bin/env bash

set -e
set -o pipefail

echo "Disable ipatbles"
sudo service iptables stop
sudo chkconfig iptables off

pushd /usr/local/
  if [ ! -d zeppelin ]; then

    echo "Downloading Zeppelin..."
    wget http://archive.apache.org/dist/zeppelin/zeppelin-0.7.2/zeppelin-0.7.2-bin-netinst.tgz
    tar -xzf zeppelin-0.7.2-bin-netinst.tgz
    rm -rf zeppelin-0.7.2-bin-netinst.tgz
    mv zeppelin-0.7.2-bin-netinst zeppelin

    pushd zeppelin

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
      echo 'export JAVA_HOME="/usr/lib/jvm/java"' >> conf/zeppelin-env.sh
      echo 'export HADOOP_HOME=${HADOOP_HOME:-/usr/lib/hadoop}' >> conf/zeppelin-env.sh
      echo 'export HADOOP_CONF_DIR=$HADOOP_CONF_DIR:/etc/hadoop/conf' >> conf/zeppelin-env.sh
      echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> conf/zeppelin-env.sh
      echo 'export HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native"' >> conf/zeppelin-env.sh
      echo 'export HADOOP_CLASSPATH="$HADOOP_CLASSPATH:$(hadoop classpath)"' >> conf/zeppelin-env.sh
      echo 'export CLASSPATH=$CLASSPATH:$HADOOP_CLASSPATH' >> conf/zeppelin-env.sh
      echo 'export PIG_CLASSPATH=$PIG_CLASSPATH:$HADOOP_CONF_DIR:$HADOOP_CLASSPATH' >> conf/zeppelin-env.sh

    popd # /usr/local/

    (! id -u zeppelin > /dev/null 2>&1 ) && adduser zeppelin
    chown -R zeppelin:zeppelin zeppelin
    sudo -u hdfs hdfs dfs -mkdir -p /user/zeppelin
    sudo -u hdfs hdfs dfs -chown -R zeppelin:zeppelin /user/zeppelin

  fi

popd # /

echo "Zeppelin is Ready Now!"
echo "Please use this command to start your service: "
echo "sudo -u zeppelin /usr/local/zeppelin/bin/zeppelin-daemon.sh start"
echo "Please use this command to stop your service: "
echo "sudo -u zeppelin /usr/local/zeppelin/bin/zeppelin-daemon.sh stop"
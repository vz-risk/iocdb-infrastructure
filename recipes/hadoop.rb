include_recipe 'iocdb-infrastructure::iocdb'
include_recipe 'java'
include_recipe 'hadoop'
include_recipe 'hadoop::hadoop_hdfs_datanode'
include_recipe 'hadoop::hadoop_hdfs_namenode'

# partition, format, and mount
# hadoop['hadoop_env'] (export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_71)
# sudo -u hdfs hdfs namenode -format
# sudo -u hdfs hdfs dfs -mkdir /user
# sudo -u hdfs hdfs dfs -mkdir /user/iocdb

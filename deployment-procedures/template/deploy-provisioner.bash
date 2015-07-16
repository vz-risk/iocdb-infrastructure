#!/bin/bash

RUN_USER="iocdb_prov"
PROV_HOME="/opt/iocdb_provisioner"
INFRA_HOME="${PROV_HOME}/iocdb-infrastructure"
INFRA_BACKUP="/tmp/iocdb-infrastructure-$(date +%Y%m%d)"
LOG_HOME=${PROV_HOME}/log
LOG_FILE=${LOG_HOME}/deploy-provisioner-$(date +%Y%m%d_%H%M%S).log
DSTAMP="$(date +%Y%m%d)"
TSTAMP="$(date +%Y%m%d_%H%M%S)"
PKG_NAME="iocdb-infrastructure-<META_PACKAGE_VERSION_ID><META_PACKAGE_BUILD_ID>.tar.gz"
PKG_PATH="/staged-repos/${PKG_NAME}"

loginfo()
{
  echo "INFO  : $MSG" 
  if [ -f ${LOG_FILE} ]; then echo "[$(date +%Y-%m-%d_%H:%M:%S)] INFO  $MSG" >> ${LOG_FILE}; fi
}
logwarn() 
{
  echo "WARN  : $MSG" >&2
  if [ -f ${LOG_FILE} ]; then echo "[$(date +%Y-%m-%d_%H:%M:%S)] WARN  $MSG" >> ${LOG_FILE}; fi
}
logerr() 
{
  echo "ERROR : $MSG" >&2
  if [ -f ${LOG_FILE} ]; then echo "[$(date +%Y-%m-%d_%H:%M:%S)] ERROR $MSG" >> ${LOG_FILE}; fi
}
print_usage_and_exit()
{
  echo "Usage: $0 <options>"
  echo ""
  echo "    options:"
  echo "       -b | --bootstrap-chef : Bootstrap chef onto destination machines"
  echo ""
  echo "WARNING: Deployment was not performed"
  echo ""

  exit 1
}
create_log_file()
{
  # Create logs dir if it doesn't exist
  if [ ! -d "${LOG_HOME}" ]; then
    MSG="Creating logging directory ${LOG_HOME}"; loginfo

    sudo mkdir -p ${LOG_HOME}
    if [ "$?" -ne 0 ]; then MSG="failed to create dir ${LOG_HOME}"; logerr; exit 1; fi

    sudo chmod 755 ${LOG_HOME}
    if [ "$?" -ne 0 ]; then MSG="chmod failed on ${LOG_HOME}"; logerr; exit 1; fi

    sudo chown ${RUN_USER} ${LOG_HOME}
    if [ "$?" -ne 0 ]; then MSG="chown failed on ${LOG_HOME}"; logerr; exit 1; fi
  fi

  # Create logs file if it doesn't exist
  if [ ! -f "${LOG_FILE}" ]; then
    sudo touch ${LOG_FILE}
    if [ "$?" -ne 0 ]; then MSG="Failed to create ${LOG_FILE}"; logerr; exit 1; fi

    sudo chmod 644 ${LOG_FILE}
    if [ "$?" -ne 0 ]; then MSG="chmod failed on ${LOG_FILE}"; logerr; exit 1; fi

    sudo chown ${RUN_USER} ${LOG_FILE}
    if [ "$?" -ne 0 ]; then MSG="chown failed on ${LOG_FILE}"; logerr; exit 1; fi

    MSG="Log file $LOG_FILE created"; loginfo
  fi
}

archive_provisioner()
{
  # archive the old provisioner if it exists
  if [ -d ${INFRA_HOME} ]; then

    # delete old files from any prior backups today to prevent overlay
    if [ -d /tmp/iocdb-infrastructure-${DSTAMP} ]; then
      rm -fr /tmp/iocdb-infrastructure-${DSTAMP}
      if [ "$?" -ne 0 ]; then MSG="failed to delete /tmp/iocdb-infrastructure-${DSTAMP}"; logerr; exit 1; fi
    fi

    # archive the files
    sudo mv ${INFRA_HOME} /tmp/iocdb-infrastructure-${DSTAMP}
    if [ "$?" -ne 0 ]; then MSG="failed to create /tmp/iocdb-infrastructure-${DSTAMP}"; logerr; exit 1; fi

    sudo tar -czvf /tmp/iocdb-infrastructure-${TSTAMP}.tar.gz /tmp/iocdb-infrastructure-${DSTAMP}
    if [ "$?" -ne 0 ]; then MSG="failed to tar/gzip /tmp/iocdb-infrastructure-${DSTAMP}"; logerr; exit 1; fi

    # this has been saved to gzip so delete
    if [ -d /tmp/iocdb-infrastructure-${DSTAMP} ]; then
      rm -fr /tmp/iocdb-infrastructure-${DSTAMP}
      if [ "$?" -ne 0 ]; then MSG="failed to delete /tmp/iocdb-infrastructure-${DSTAMP}"; logerr; exit 1; fi
    fi
  fi
}

pre_install()
{
  MSG=""; loginfo
  MSG="validating user ..."; loginfo

  # Validate user
  if [ "`whoami`" != "${RUN_USER}" ]; then
    MSG="Must be run as user ${RUN_USER}, exiting"; logerr
    exit 1
  fi

  MSG="creating logfile ..."; loginfo
  create_log_file

  MSG="archiving old provisioner ..."; loginfo
  archive_provisioner
}

install_provisioner() 
{
  MSG="installing new provisioner ${PKG_PATH} ..."; loginfo

  if [ -f ${PKG_PATH} ]; then
    cd ${PROV_HOME}/
    tar -xzvf ${PKG_PATH}
    if [ "$?" -ne 0 ]; then MSG="tar -xzvf ${PKG_PATH} failed"; logerr; exit 1; fi
  else
    MSG="Package ${PKG_PATH} not found"; logerr
    exit 1
  fi

  # updating repositories
  cd /staged-repos/cookbook-elasticsearch.git
  if [ "$?" -ne 0 ]; then MSG="cd /staged-repos/cookbook-elasticsearch.git failed"; logerr; exit 1; fi

  git fetch --all
  if [ "$?" -ne 0 ]; then MSG="git fetch for /staged-repos/cookbook-elasticsearch.git failed"; logerr; exit 1; fi

  echo "version      : <META_PACKAGE_VERSION_ID>" > ${INFRA_HOME}/version.txt
  echo "build        : <META_PACKAGE_BUILD_ID>" >> ${INFRA_HOME}/version.txt
  echo "package      : ${PKG_NAME}" >> ${INFRA_HOME}/version.txt
  echo "install-time : ${TSTAMP}" >> ${INFRA_HOME}/version.txt
}

#=====================================================
# Script start
#=====================================================


#-----------------------------------------------
# Parse command line args
#-----------------------------------------------
BOOTSTRAP_CHEF="false"
while [[ $# > 0 ]]
do
  curr_arg="$1"

  case $curr_arg in
    -b|--bootstrap-chef)
    BOOTSTRAP_CHEF="true"
    ;;

    *)
            # unknown option
    ;;
  esac

  shift # past argument or value
done

pre_install
install_provisioner

#=====================================================
# Script end
#=====================================================

#!/bin/bash

###############################################
# Variables
###############################################

lib_dir="/opt/sensu/embedded/lib/ruby/2.4.0/"
plugin_dir="/opt/sensu/plugins"
temp_dir="/var/tmp/sensu-plugins"

###############################################
# Checking library path
###############################################
if [[ ! -d ${lib_dir} ]]; then
  echo "${lib_dir} does not exists."
  echo "you need to install sensu first."
  exit 1
fi

###############################################
# Cloning repositories
###############################################

mkdir ${temp_dir}
cd ${temp_dir} || exit 1

git clone https://github.com/djberg96/sys-filesystem.git
git clone https://github.com/sensu-plugins/sensu-plugins-load-checks
git clone https://github.com/sensu-plugins/sensu-plugins-memory-checks.git
git clone https://github.com/sensu-plugins/sensu-plugins-filesystem-checks.git
git clone https://github.com/sensu-plugins/sensu-plugins-process-checks.git
git clone https://github.com/sensu-plugins/sensu-plugins-http.git
git clone https://github.com/sensu-plugins/sensu-plugins-logs
git clone https://github.com/sensu-plugins/sensu-plugins-disk-checks
git clone https://github.com/sensu-plugins/sensu-plugins-cpu-checks
git clone https://github.com/sensu-plugins/sensu-plugins-selinux
git clone https://github.com/sensu-plugins/sensu-plugins-execute
git clone https://github.com/sensu-plugins/sensu-plugins-network-checks
git clone https://github.com/sensu-plugins/sensu-plugins-chrony
git clone https://github.com/sensu-plugins/sensu-plugins-uptime-checks
git clone https://github.com/sensu-plugins/sensu-plugins-systemd
git clone https://github.com/sensu-plugins/sensu-plugins-lvm

###############################################
# Copying libraries
###############################################

ln -s ${lib_dir} /opt/sensu/lib

cd sys-filesystem/lib || exit 1
cp -Rv * ${lib_dir}; cd ${temp_dir}

cd sensu-plugins-load-checks/lib || exit 1
cp -Rv * ${lib_dir}; cd ${temp_dir}

###############################################
# Installing plugins
###############################################

mkdir -p ${plugin_dir}

for plugin in `ls -d sensu-plugins-*`; do
  cd ${plugin}/bin
  for rubyf in `ls *.rb`; do
    sed -i '1s|^.*$|#!/opt/sensu/embedded/bin/ruby|g' ${rubyf}
  done
  cp -v * ${plugin_dir}
  cd ${temp_dir}
done

exit 0


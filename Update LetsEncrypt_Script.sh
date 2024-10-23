#!/bin/bash

declare -a nodes

the_install_base=/opt
working_dir=$the_install_base/shibboleth-idp4-installer/repository

cd $working_dir || exit

ansible-playbook -i ansible_hosts site_v4_LetsEncrypt.yml --force-handlers --extra-var="install_base=$the_install_base"

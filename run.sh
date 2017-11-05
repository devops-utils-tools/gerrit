#!/bin/bash
#docker_gerrtit by:liuwei mail:al6008@163.com
source /etc/profile

#gerrit
export GERRIT_IP=${GERRIT_IP:-'127.0.0.1'}
export GERRIT_PORT=${GERRIT_PORT:-'8443'}
#gitlab
export GITLAB_IP=${GITLAB_IP:-'127.0.0.1'}
export GITLAB_SSH_PORT=${GITLAB_SSH_PORT:-'10022'}

#ldap
export LDAP_URL=${LDAP_URL:-"ldaps://172.16.110.14"}
export LDAP_SEARCH_DN=${LDAP_SEARCH_DN:-"cn=search,dc=wl166,dc=com"}
export LDAP_SEARCH_PASS=${LDAP_SEARCH_PASS:-"Arxan_liuwei"}
export LDAP_USERS=${LDAP_USERS:-"ou=people,dc=wl166,dc=com"}
export LDAP_GROUPS=${LDAP_GROUPS:-"ou=group,dc=wl166,dc=com"}


#配置gerrit
if [ ! -e "/data/gerrit/gerrit_data/etc/gerrit.config.init" ];then
	tar xf /tmp/gerrit_data.tar.gz -C /
	#gerrit 
	sed -i "s@127.0.0.1@${GERRIT_IP}@g" /data/gerrit/gerrit_data/etc/gerrit.config
	sed -i "s@8443@${GERRIT_PORT}@g" /data/gerrit/gerrit_data/etc/gerrit.config
	#gitlab
	sed -i "s@172.16.110.201@${GITLAB_IP}@g" /data/gerrit/gerrit_data/etc/replication.config
	sed -i "s@172.16.110.201@${GITLAB_IP}@g" /data/gerrit/.ssh/config
	sed -i "s@10022@${GITLAB_SSH_PORT}@g" /data/gerrit/.ssh/config
	#LDAP配置
	sed -i "s@ldaps://172.16.110.14@${LDAP_URL}@g" /data/gerrit/gerrit_data/etc/gerrit.config
	sed -i "s@cn=search,dc=wl166,dc=com@${LDAP_SEARCH_DN}@g" /data/gerrit/gerrit_data/etc/gerrit.config
	sed -i "s#Arxan_liuwei#${LDAP_SEARCH_PASS}#g" /data/gerrit/gerrit_data/etc/secure.config
	sed -i "s@ou=people,dc=wl166,dc=com@${LDAP_USERS}@g" /data/gerrit/gerrit_data/etc/gerrit.config
	sed -i "s@ou=group,dc=wl166,dc=com@${LDAP_GROUPS}@g" /data/gerrit/gerrit_data/etc/gerrit.config
	#初始化gerrit
	su -l gerrit -c 'java -jar /data/gerrit/gerrit_data/bin/gerrit.war init -d /data/gerrit/gerrit_data/ --install-all-plugins --batch --no-auto-start'
	echo 'gerrit init done by:liuwei mail:al6008@163.com' > "/data/gerrit/gerrit_data/etc/gerrit.config.init"
fi

#和gitlab同步key 此key公钥需要加入gitlab 项目master账号中
if [ ! -e "/data/gerrit/.ssh/id_rsa" ];then
	su -l gerrit -c "ssh-keygen -t rsa -b 8888 -C al6008@163.com -f /data/gerrit/.ssh/id_rsa -P ''"
fi

#信任gitlab主机
grep -q "${GITLAB_IP}" /data/gerrit/.ssh/known_hosts &>/dev/null ||su -l gerrit -c "ssh-keyscan -p ${GITLAB_SSH_PORT} ${GITLAB_IP}  >/data/gerrit/.ssh/known_hosts"
grep -q "${GITLAB_SSH_PORT}" /data/gerrit/.ssh/known_hosts &>/dev/null || sed -i "s@${GITLAB_IP}@[${GITLAB_IP}]\:${GITLAB_SSH_PORT}@" /data/gerrit/.ssh/known_hosts
 
#启动gerrit
chown gerrit:gerrit -R /data/gerrit
chmod 700 -R /data/gerrit/.ssh
su -l gerrit -c '/data/gerrit/gerrit_data/bin/gerrit.sh restart'
tail -f /data/gerrit/gerrit_data/logs/error_log &&exit 0
exit 1

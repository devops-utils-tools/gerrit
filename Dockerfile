from ubuntu:14.04.4
maintainer By:liuwei "al6008@163.com"
expose 80 8443 29418
ENV DEBIAN_FRONTEND noninteractive
run apt-get update &&\
	apt-get install -y python-software-properties  software-properties-common  &&\
	add-apt-repository ppa:webupd8team/java -y &&\
	apt-get update &&\
	echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections &&\
	apt-get install -y oracle-java8-installer &&\
	apt-get install -y oracle-java8-set-default &&\
	apt-get install -y gitweb &&\
	apt-get install -y unzip &&\
	apt-get clean all &&\
	rm -rf /var/cache/* 
copy jce_policy-8.zip /tmp
run cd /tmp &&\
	unzip jce_policy-8.zip &&\
	cd UnlimitedJCEPolicyJDK8 &&\
	cp *.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/ &&\
        cd ..&&rm -rf jce_policy-8.zip UnlimitedJCEPolicyJDK8
run mkdir /data &&useradd -m -d /data/gerrit  gerrit  
copy gerrit_data.tar.gz /tmp
workdir /tmp
copy run.sh /run.sh
cmd ["/bin/bash","/run.sh"]

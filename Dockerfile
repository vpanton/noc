FROM     ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#================================================
# Make sure the package repository is up to date
#================================================
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe\n" > /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main universe\n" >> /etc/apt/sources.list
RUN apt-get -qqy update
# Let's make the upgrade even though it is still unclear to me
# if the upgrade is convenient or not
RUN apt-get -qqy upgrade

#========================
# Miscellaneous packages
#========================
RUN apt-get -qqy install ca-certificates curl wget unzip vim software-properties-common python openssh-server unzip git dnsutils psmisc sudo less telnet tcpdump python-dev python-virtualenv libgmp10 libgmp-dev nginx postgresql libpq-dev mongodb mercurial libsmi2ldbl quilt smitools

#=================
# Locale settings
#=================
ENV LANGUAGE en_GB.UTF-8
ENV LANG en_GB.UTF-8
RUN locale-gen en_GB.UTF-8
# Reconfigure
RUN dpkg-reconfigure --frontend noninteractive locales
RUN apt-get -qqy install language-pack-en

#===================
# Timezone settings
#===================
ENV TZ "Europe/London"
RUN echo "Europe/London" | sudo tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata



RUN mkdir /var/run/sshd
RUN echo "UseDNS no" >> /etc/ssh/sshd_config
RUN groupadd noc
RUN useradd -g noc -s /bin/sh -d /home/noc noc

RUN cd /opt && hg clone http://bitbucket.org/nocproject/noc noc
RUN virtualenv  /opt/noc
RUN /etc/init.d/nginx start && /etc/init.d/postgresql start &&  sudo --user=postgres psql -c "CREATE USER noc SUPERUSER ENCRYPTED PASSWORD 'thenocproject';" && sudo --user=postgres psql -c "CREATE DATABASE noc WITH OWNER=noc ENCODING='UTF8' TEMPLATE template0;" && /etc/init.d/mongodb start && mongo noc --eval 'db.addUser("noc", "thenocproject")' && /opt/noc/share/vagrant/x86_64/Ubuntu/12.04/bootstrap.sh


ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


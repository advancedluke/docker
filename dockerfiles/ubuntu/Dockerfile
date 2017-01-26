FROM ubuntu:16.04
MAINTAINER Cheese <iyham@naver.com>

ENV DEBIAN_FRONTEND noninteractive
ENV user "cheese"
ENV password "changeme"
RUN useradd $user -m  -s /bin/bash
RUN echo $user':'$password | chpasswd

# Localization
#RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list
#RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Sudoer Setting
RUN apt-get update && apt-get install -y sudo
RUN echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
RUN chmod 0440 /etc/sudoers.d/$user
RUN sed -i 's/101/0/g' /usr/sbin/policy-rc.d

# Install ssh and supervisord
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor

# make supervisor run in foreground
RUN touch /etc/supervisor/conf.d/supervisord.conf

RUN echo [supervisord] >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf

RUN echo [program:sshd] >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=/usr/sbin/sshd -D' >> /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord"]

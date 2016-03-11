FROM ubuntu:14.04
MAINTAINER luke <iyham@naver.com>
ENV DEBIAN_FRONTEND noninteractive
ENV user "ubuntu"
ENV password "ubuntu"
RUN useradd $user -m  -s /bin/bash
RUN echo $user':'$password | chpasswd

RUN echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
RUN chmod 0440 /etc/sudoers.d/$user
RUN sed -i 's/101/0/g' /usr/sbin/policy-rc.d

# Localization
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN apt-get update && apt-get install -y openssh-server supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

CMD ["/usr/bin/supervisord"]

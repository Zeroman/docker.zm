FROM zeroman/base

RUN apt-get install -y --no-install-recommends openssh-server

RUN mkdir /var/run/sshd;mkdir /root/.ssh

RUN echo 'root:root' | chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

EXPOSE 22 

CMD ["/usr/sbin/sshd", "-D"]


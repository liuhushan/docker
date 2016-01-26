# CentOS 7 + SSHD

FROM centos

MAINTAINER Andre Fernandes
RUN yum update -y
WORKDIR /root
RUN yum install -y openssh-server openssh-clients passwd sudo && \
    yum clean all

ENV USERPWD secret
ADD removekeys.sh /opt/removekeys.sh

RUN useradd -u 5001 -G users -m user && \
    echo "$USERPWD" | passwd user --stdin && \
    chmod +x /opt/removekeys.sh && \
    /usr/bin/ssh-keygen -A -v && \
    sed -i '/^session.*pam_loginuid.so/s/^session/# session/' /etc/pam.d/sshd && \
    sed -i 's/Defaults.*requiretty/#Defaults requiretty/g' /etc/sudoers

# passwordless sudo
ADD user /etc/sudoers.d/user

RUN  yum install python -y
COPY ./components/get-pip.py /tmp/
RUN python /tmp/get-pip.py
RUN pip install django
RUN pip install gunicorn
WORKDIR /opt/app
EXPOSE 22 80 3306 8080
ENTRYPOINT ["gunicorn","-b","0.0.0.0:80"]
CMD ["/usr/sbin/sshd", "-D"]


FROM centos:7
ENV container docker

ARG USER

COPY id_rsa.pub /tmp/
RUN ( \
        cd /lib/systemd/system/sysinit.target.wants/; \
        for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done \
    ); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    ln -sf /usr/share/zoneinfo/Japan /etc/localtime; \
    sed -i "s/^\(tsflags=nodocs\)/#\1/g" /etc/yum.conf; \
    yum update -y; \
    yum install -y sudo initscripts openssh-server man git vim-enhanced screen; \
    useradd $USER -G wheel; \
    passwd -d $USER; \
    mkdir -m 700 /home/$USER/.ssh; \
    cp /tmp/id_rsa.pub /home/$USER/.ssh/authorized_keys; \
    chown -R $USER.$USER /home/$USER/.ssh; \
    rm /tmp/id_rsa.pub;

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

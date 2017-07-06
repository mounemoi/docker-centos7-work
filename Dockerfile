FROM centos:7
ENV container docker

ARG USER

COPY id_rsa.pub /tmp/

RUN \
    echo '# man page をインストールするように'; \
    sed -i "s/^\(tsflags=nodocs\)/#\1/g" /etc/yum.conf; \
    \
    echo '# override_install_langs 設定を無効に'; \
    sed -i "s/^\(override_install_langs=\)/#\1/g" /etc/yum.conf; \
    \
    echo '# yum update & 必要なパッケージのインストール'; \
    yum update -y; \
    yum install -y \
        sudo initscripts openssh-server man git vim-enhanced screen gcc make bzip2 wget \
        epel-release openssl-devel zlib-devel bzip2-devel readline-devel sqlite-devel; \
    \
    echo '# systemd を利用可能にする'; \
    ( \
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
    \
    echo '# 時刻を JST に'; \
    ln -sf /usr/share/zoneinfo/Japan /etc/localtime; \
    \
    echo '# ssh ログインできるように'; \
    systemctl enable sshd; \
    rm -f /usr/lib/tmpfiles.d/systemd-nologin.conf; \
    \
    echo '# lastlog の有効化'; \
    mkdir -p /etc/systemd/system/sshd.service.d/; \
    echo $'[Service]\nExecStartPre=/usr/bin/touch /var/log/lastlog' > /etc/systemd/system/sshd.service.d/create_lastlog.conf; \
    \
    echo '# 作業用ユーザの作成'; \
    useradd $USER -G wheel; \
    passwd -d $USER; \
    mkdir -m 700 /home/$USER/.ssh; \
    cp /tmp/id_rsa.pub /home/$USER/.ssh/authorized_keys; \
    chown -R $USER:$USER /home/$USER/.ssh; \
    rm /tmp/id_rsa.pub;

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

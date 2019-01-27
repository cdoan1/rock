#!/bin/bash

function create_mount ()
{
    if [ -z "$1" ]                           # Is parameter #1 zero length?
    then
        echo "-Parameter #1 is zero length.-"  # Or no parameter passed.
        exit 1
    else
        echo "-Parameter #1 is \"$1\".-"
    fi
    MOUNTPOINT=$1
    if lsblk | grep xvdc; then
        echo "second disk found ..."
        parted /dev/xvdc mklabel gpt
        sudo parted -a opt /dev/xvdc mkpart primary ext4 0% 100%
        sudo mkfs.ext4 -L datapartition /dev/xvdc1
        mkdir -p $MOUNTPOINT
        sudo mount -o defaults /dev/xvdc1 $MOUNTPOINT
    else
        echo "no second disk found ..."
    fi
}
function install_tmux_rhel()
{
    TOP=`pwd`
    yum install -y gcc kernel-devel make ncurses-devel
    curl -OL https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
    tar -xvzf libevent-2.0.22-stable.tar.gz
    cd libevent-2.0.22-stable
    ./configure --prefix=/usr/local
    make
    sudo make install
    cd ..
    curl -OL https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz
    tar -xvzf tmux-2.3.tar.gz
    cd tmux-2.3
    LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
    make
    sudo make install
    cd ..
    tmux -V
    cd ~ && git clone https://github.com/cdoan1/.tmux.git && .tmux/setup.sh
    cd $TOP
}
function setup_firewall()
{
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    iptables -A INPUT -m state --state INVALID -j DROP

    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i eth0 -j ACCEPT
    iptables -A OUTPUT -i eth0 -j ACCEPT

    iptables -P INPUT DROP
    iptables -P FORWARD DROP

    ## SAVE IPTABLES RULES BEFORE ICP INSTALL

    iptables-save > /etc/sysconfig/iptables.baseline
    ip6tables-save > /etc/sysconfig/ip6tables.baseline
}
function restore_firewall()
{
    # restore
    iptables-restore < /etc/sysconfig/iptables.baseline
    ip6tables-restore < /etc/sysconfig/ip6tables.baseline
}
function setup_docker()
{
    DOCKERIMAGE=""
    wget -O icp-docker-18.03.1_x86_64.bin $DOCKERIMAGE
    chmod 755 icp-docker-18.03.1_x86_64.bin
    ./icp-docker-18.03.1_x86_64.bin --install

    if [ -f ~/.ssh/id_rsa ]; then
        chmod 0600 ~/.ssh/id_rsa
    fi

    systemctl start docker.service
    systemctl enable docker.service
    systemctl restart docker.service
    systemctl status docker.service
}

sudo sed -i.bak 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
if [ -f /etc/cloud/cloud.cfg ]; then
    sudo sed -i.bak -e 's/^ - set_hostname/# - set_hostname/' \
    -e 's/^ - update_hostname/# - update_hostname/' \
    /etc/cloud/cloud.cfg
fi

sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"
sudo yum -y -q update
sudo yum -y -q install ansible pyOpenSSL python-cryptography python-lxml
sudo yum -y -q install device-mapper-libs device-mapper-event-libs
sudo yum -y -q install golang
sudo yum -y -q install wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct

string=`hostname`
if [ -z "${string##*management*}" ]; then
    # all `management` nodes
    create_mount "/var/lib/icp"
else
    # all not `management` nodes
    if [ -z "${string##*worker*}" ]; then
        echo "Worker: no mount"
    else
        create_mount "/var/lib/docker"
    fi
fi

if [ -z "${string##*boot*}" ]; then
    yum -y install nfs-utils rpcbind
    if [ ! -d /var/lib/docker/registry ]; then
        mkdir -p /var/lib/docker/registry
        chown nobody:nobody /var/lib/docker/registry
    fi
    cat > /etc/exports << EOF
/var/lib/docker/registry *(rw,nohide,async,no_subtree_check,no_root_squash)
EOF
    service rpcbind start
    service nfs start
fi

if [ -z "${string##*haproxy*}" ]; then
	install_tmux
fi

setup_docker
setup_firewall
install_tmux_rhel
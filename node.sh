
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
systemctl disable firewalld && systemctl stop firewalld
setenforce 0
echo "SELINUX=disabled" > /etc/sysconfig/selinux
swapoff -a
sed -e '/swap/ s/^#*/#/' -i /etc/fstab
cat <<EOF >>  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
yum install -y kubelet kubeadm kubectl docker
systemctl enable kubelet && systemctl start kubelet
systemctl enable docker && systemctl start docker
systemctl daemon-reload
systemctl restart kubelet
yum install -y -q openssh-server
systemctl enable sshd
systemctl start sshd
yum install -y -q which net-tools sudo sshpass less
cd /home/zippyops

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
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Swap
sleep 60
joinCommand=$(kubeadm token create --print-join-command)
echo "$joinCommand --ignore-preflight-errors=Swap,FileContent--proc-sys-net-bridge-bridge-nf-call-iptables" > /root/jointoken.sh
sleep 30
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
cd /root
yum install git -y
git clone https://github.com/hemapriyamaheswaran/azurekubeweave.git
chmod 755 /root/azurekubeweave/weave.sh
/root/azurekubeweave/weave.sh
cd /root/
yum install -y -q openssh-server
systemctl enable sshd
systemctl start sshd

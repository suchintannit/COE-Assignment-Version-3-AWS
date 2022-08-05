
  echo "Creating the Output File#############################################\n"
  touch ./join.sh
  echo "output file cleared############################"
  echo "Starting the Kubernetes Cluster on Master Node############################################\n"
  # Start cluster
  sudo kubeadm init --apiserver-advertise-address=${hostname -I} --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all
  echo "Change the owner of config file#############################################\n"
  # Configure kubectl
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  # Fix kubelet IP
  echo "Fixing Kubelet IP#############################################\n"
  echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=10.0.0.10"' | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  
  # Configure flannel
  echo "Install the flannel network fabric#############################################\n"
  curl -o kube-flannel.yml https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
  sed -i.bak 's|"/opt/bin/flanneld",|"/opt/bin/flanneld", "--iface=enp0s8",|' kube-flannel.yml
  kubectl create -f kube-flannel.yml
  echo "Relaoding the system#############################################\n"
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  echo "Save join token to join.sh file#############################################\n"
  kubeadm token create --print-join-command > /vagrant/join.sh
  chmod +x /vagrant/join.sh
  echo "Install Multicast Tools#############################################\n"
  sudo apt-get install -y avahi-daemon libnss-mdns
  echo "Master node setup Complete#############################################\n"
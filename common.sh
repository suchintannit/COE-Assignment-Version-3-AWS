#This is common tools script that installs docker and kubernetes on each node of the cluster and makes sure that they are ready to be added to the cluster

  echo "Starting the Common Tools#############################################\n"
  sudo apt-get update -y
  echo "Installing Docker#####################################################\n"
  sudo apt-get install -y docker.io
  echo "Adding the Kubernetes Repo#############################################\n"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  sudo apt-get update -y
  echo "Installing Kubernetes Tools#############################################\n"
  sudo apt-get install -y kubelet kubeadm kubectl  
  sudo apt-mark hold kubeadm kubelet kubectl
  echo "Testing install of Kubernetes############################################\n"
  kubeadm version
  echo "Install dependent Tools#############################################\n"
  sudo apt-get install -y ebtables ethtool
  echo "bridged traffic to iptables is enabled for kube-router.\n"
  echo "Disable Swap###############################################"
  # disable swap
  sudo swapoff -a
  sudo sed -i '/swap/d' /etc/fstab
  echo "Swap Disabled##############################################"
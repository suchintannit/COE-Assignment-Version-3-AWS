
## Creation of a Multi-tier app on AWS using Terraform-Ansible-Scripts-Kubernetes-Jenkins-Git

#### Dr. Suchintan Mishra [suchintan_mishra@epam.com]

#### Problem Statement: Multi-tier App in DevOps-Candidate should be able to handle all stages of DevOps Independently
	Project/Assignment - 5 Days		
		
			
----------------------------------------------------------
  	Topics with Hands-on Lab:
  
	1. Three Tier web application using docker and Kubernetes 
	
	2. Infrastructure as Code Using Terraform (Modules)	
	
	3. Configuration Management using Ansible (Roles)	
	
	4. Application code management using Git
	
	5. Building CI/CD pipeline to deploy new version of Application (Jenkins)	
	
	6. Bulding Monitoring for application	

### 1. Architecture

The tools are integrated in the following way:

			 ______________________________________________________________________________________
			'											'
			'	 common.sh	''''''''''''\   kubeadm,kubectl,dashboard,REST			'
			' /----> master.sh --->	'   Master  / <<------------<------------- 			'
			'/			''''''''''''				'			'
			'								'			'
			'								'			'
			'								'
			'	common.sh	''''''''''''\				'			'
	Terraform------>	node.sh	 ---->	   Node01---->-> Docker Container <-<---- ' <----<----kubernetes'
			'	 			    /	  (To-do APP)		'		        '
	        	'\			''''''''''''				'			'					
			' \								'
			' \								'
			'  \	   common.sh	''''''''''''				'			' (｡◕‿◕｡)
			'   \----->node.sh --->	'   Node02--->-> Docker Conatiner  <-<----'			'	
														 -->CLOUDWATCH
			'			''''''''''''	    (MySQL)					'
	 		'											'
			'______________________________________________________________________________________	'
												
												'𝗔𝗨𝗚𝗨𝗦𝗧 – 𝟮𝟬𝟮𝟮	
												'🅇|𝟢𝟣|𝟢𝟤|𝟢𝟥|𝟢𝟦|𝟢𝟧|𝟢𝟨
										 Application Code Management with Git	
				
### 2.Execution Steps						

The project has a terraform file called create-infra.tf that will create 3 nodes in the AWS. Once the nodes are created the provisioner module of the terraform provisions 2 bash scripts in each node. The table below summarizes this architecture. The terffaorm script would not run this scripts. 
| IP           | Hostname | Componets                                | Scripts|
| ------------ | -------- | ---------------------------------------- |---------|
| 10.0.0.10 | master    | kube-apiserver, kube-controller-manager, kube-scheduler, etcd, kubelet, docker, flannel, dashboard | common.sh master.sh|
| 10.0.0.11 | worker1    | kubelet, docker, flannel, todo-myapp          |common.sh master.sh|
| 10.0.0.12 | worker2    | kubelet, docker, flannel, mysql-container               |common.sh master.sh|

Execute the first step of the project by running the follwoing the root folder of the project:
		
		PS>terraform init
		PS>terraform plan
		PS>terraform apply

Once the resources are made ssh into the master node and execute the following:
		
		$sudo chmod +x master.sh
		$sudo chmod +x common.sh
		$sudo sh common.sh
		$sudo sh master.sh
		
On successful execution of the above commands the master node will print the kubeadm join command for its workers.
		
Do the same on each worker node the resources are made ssh into the master node and execute the following:
		
		$sudo chmod +x worker.sh
		$sudo chmod +x common.sh
		$sudo sh common.sh
		$sudo sh worker.sh
Once the above commands execute successfully, now paste the kubeadm join command from the master node. This worker should now join the master. Restart kubelet in worker.

At this step we have a working cluster using kubeadm with deployed ec2 instances. Now we are ready to deploy pods into the created nodes.

### Deploy pods into nodes
In order to deply pods to the worker nodes, the worker nodes must be labelled. The labelling of worker nodes allows us to deploy pods in them. To get the current status of the labels run the following command:

		kubectl get nodes --show-labels

Assign labels to worker1 and worker2 with labels disktype=worker1-ssd and disktype=worker2-ssd by executing the following commands:

		kubectl label nodes worker1 name: worker1
		kubectl label nodes worker1 name: worker2

**Step 4:** create the YML files for the getting-started-app and the mysql-app

		apiVersion: v1
		kind: Pod
		metadata:
  			name: to-do-app
  			labels:
    		env: test
		spec:
  			containers:
  				- name: to-do-app
    			 image: 896325/suchintan-getting-started
    			 imagePullPolicy: IfNotPresent
  			nodeSelector:
    			name: worker1

save this file as getting-started.yml. Note that the nodeselector property allows us to select the worker 1 to deploy the pods.

		apiVersion: v1
		kind: Pod
		metadata:
  			name: mysql-pod
  			labels:
    		context: assignment-k8s-lab
		spec:
  			containers:
    			- name: mysql
      		 	image: mysql:latest
      			env:
        			- name: "MYSQL_USER"
          		  	value: "mysql"
        			- name: "MYSQL_PASSWORD"
          	  	  	value: "mysql"
        			- name: "MYSQL_DATABASE"
         	  	  	value: "sample"
        			- name: "MYSQL_ROOT_PASSWORD"
          	  	  	value: "supersecret"
      			ports:
        			- containerPort: 3306
			nodeSelector:
    			name: worker2
save this file as mysql.yml. Note that the nodeselector property allows us to select the worker 1 to deploy the pods.
 
**Step 5:** Once the pods are deployed check their status using

			Deploy the pods 
			kubectl 
			kubectl get pods -o wide
			kubectl get all -o wide

### About the DEvOps Tools Used:


### Terraform

		PS>terraform init
		PS>terraform plan
		PS>terraform apply

This command invokes the terraform in the project.  Of the 3 nodes, one is the master and will run the kubernetes controller and dashboard. The master node is responsible to run the control plane. The control plane listens to REST API request. The worker nodes01 executes a python to-do docker container while the node02 stores its persitant database through a mysql container. This project demonstrates how a multi container app can be managed by a cluster.

### Ansible:


### Kubernetes: 

Kubernetes is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available. Nodes (like VMs) and inside these nodes Pods (like Containers) are executed. Kubernetes works on a master-slave architecture where there is atleast one master and multiple workers.

### Docker 

containers enable application developers to package software for delivery to testing, and then to the operations team for production deployment. The operations team then has the challenge of running Docker container applications at scale in production. Kubernetes is a tool to run and manage a group of Docker containers. While Docker focuses on application development and packaging, Kubernetes ensures those applications can run at scale.
	 	
	 
### 4. Troubleshoot Execution.
Do a terraform apply the first time you execute. Let the process complete in one go. If it gets stuck then close the VMs from virtualbox and then do the follwoing options from the root folder.

	PS>terraform destroy

	If there are errors then execute:

	Delete resources from AWS manually.
	
Note: Try finding your version of aws cli its has been tested on aws 2.7.6 try to match the version by changing the providers module in create-infra.tf
	
### 5. Bash Scripts for Automation

Bash is a Unix command line interface for interacting with the operating system, available for Linux and macOS. Bash scripts help group commands to create a program. All instructions that run from the terminal work in Bash scripts as well.

Bash scripting is a crucial tool for system administrators and developers. Scripting helps automate repetitive tasks and interact with the OS through custom instruction combinations. The skill is simple to learn and requires only basic terminal commands to get started.

You will often encounter shell scripts starting with #! /bin/bash, #! is called a shebang or hashbang. shebang plays an important role in shell scripting, especially when dealing with different types of shells.
		
This is common tools script that installs docker and kubernetes on each node of the cluster and makes sure that they are ready to be added to the cluster

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
	
This is the 'master.sh' script that creates a control plane on the master node.

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
  	kubeadm token create --print-join-command > /ubuntu/join.sh
  	chmod +x /ubuntu/join.sh
  	echo "Install Multicast Tools#############################################\n"
  	sudo apt-get install -y avahi-daemon libnss-mdns
  	echo "Master node setup Complete#############################################\n"
	
Finally the worker.sh file runs in the worker and is responsible to join the worker.

	echo Restart kubelet and containerd
	sudo systemctl restart kubelet
	sudo systemctl restart containerd
### 6. Monitoring the Cluster:

CloudWatch collects monitoring and operational data in the form of logs, metrics, and events, and visualizes it using automated dashboards
	
### 7. Conclusions and Limitations:

Using this project a basic understanding of the devops tools and their usage can be made. Having a lot of choice makes things difficult sometimes but it should be kept the following table can help.

	| Technology    | Automation Level          | Alternatives                     | Path in Repo|
	| ------------- | --------------------      | -------------------------        |----------   |
	| Vagrant       | Resource Creation         | Terraform, AWS CLOUD Formation   |             |
	| Terraform     | Resource Creation         | Vagrant, AWS CLOUD FOrmation     |             |
	|Ansible        | Application deployment    | CHEF, Puppet                     |             |     
	|Docker         | Application deployment    |                                  |             |             
	|Kubernetes     | Resource Monitoring       | Kubernetes Charm, AWS EKS        |             |


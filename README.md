
## Creation of a AWS cluster on AWS using Terraform-Ansible-Scripts-Kubernetes-Jenkins-Git

#### Dr. Suchintan Mishra [suchintan_mishra@epam.com]

#### Problem Statement:
Project/Assignment - 5 Days		
		
DevOps Project/Assignment	Topics with Hands-on Lab	
Activity - 5 Days	
----------------------------------------------------------
    	
	1. Three Tier web application using docker and Kubernetes 
	
	2. Infrastructure as Code Using Terraform (Modules)	
	
	3. Configuration Management using Ansible (Roles)	
	
	4. Application code management using Git
	
	5. Building CI/CD pipeline to deploy new version of Application (Jenkins)	
	
	6. Bulding Monitoring for application	

### 1. Architecture

The project has a terraform file called create-infra.tf that will create 3 nodes in the AWS. Once the nodes are created the provisioner module of the terraform provisions 2 bash scripts in each node. The table below summarizes this architecture. The terffaorm script would not run this scripts. 
| IP           | Hostname | Componets                                | Scripts|
| ------------ | -------- | ---------------------------------------- |---------|
| 10.0.0.10 | master    | kube-apiserver, kube-controller-manager, kube-scheduler, etcd, kubelet, docker, flannel, dashboard | common.sh master.sh|
| 10.0.0.11 | node01    | kubelet, docker, flannel, todo-myapp          |common.sh master.sh|
| 10.0.0.12 | node02    | kubelet, docker, flannel, mysql-container               |common.sh master.sh|

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
		'  \	   common.sh	''''''''''''				'			'
		'   \----->node.sh --->	'   Node02--->-> Docker Conatiner  <-<----'			'
		'			''''''''''''	    (MySQL)					'
	 	'											'
		'______________________________________________________________________________________	'
		
	 

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


### 2. Terraform

**Vagrant** is a command line tool used to automate the formation of virtual machines (VMs). It is a good option to use vagrant to automate the creation of VMs on which our master and workers will run. For this example, the vagrantfile create 3 ubuntu 'nodes' running the vagrant box ubuntu. 

To execute this whole project just execute the following in the root folder in Powershell as the administrator. Please ADD A BLANK Folder named 'shared' in the root folder.

		PS>terraform init
		PS>terraform plan
		PS>terraform apply

This command invokes the vagrantfile in the project.  Of the 3 nodes, one is the master and will run the kubernetes controller and dashboard. The master node is responsible to run the control plane. The control plane listens to REST API request. The worker nodes01 executes a python to-do docker container while the node02 stores its persitant database through a mysql container. This project demonstrates how a multi container app can be managed by a cluster. The vagrant file contains 3 basic variables
### 3. Ansible

### 4. Kubernetes**: Kubernetes is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available. Nodes (like VMs) and inside these nodes Pods (like Containers) are executed. Kubernetes works on a master-slave architecture where there is atleast one master and multiple workers.

### 5. Docker containers enable application developers to package software for delivery to testing, and then to the operations team for production deployment. The operations team then has the challenge of running Docker container applications at scale in production. Kubernetes is a tool to run and manage a group of Docker containers. While Docker focuses on application development and packaging, Kubernetes ensures those applications can run at scale.
**NUM_WORKER_NODES=1** - Defines the number of worker nodes.

**IP_NW="10.0.0."** - Defines the IP range in which nodes will be created.

**IP_START=10** - The last octate of MASTER IP address.

Once the master is created the vagrant file uses the "common.sh" and "master.sh" to provision it as a kubernetes _Master_. Also, when the worker nodes are created the vagrant file provisions them as _Workers_ using the "common.sh" and the "node.sh" scripts.

### 3. How the Tools (Terraform, Script and Ubuntu) Automation Works?
	 	
	 
### 5. Troubleshoot Execution.
Do a vagrant up the first time you execute. Let the process complete in one go. If it gets stuck then close the VMs from virtualbox and then do the follwoing options from the root folder.

	PS>terraform destroy

	If there are errors then execute:

	Delete resources from AWS manually.
	
	Note: Try finding your version of aws cli its has been tested on aws 2.7.6 try to match the version by changing the providers module in create-infra.tf
	
### Bash Scripts for Automation

Bash is a Unix command line interface for interacting with the operating system, available for Linux and macOS. Bash scripts help group commands to create a program. All instructions that run from the terminal work in Bash scripts as well.

Bash scripting is a crucial tool for system administrators and developers. Scripting helps automate repetitive tasks and interact with the OS through custom instruction combinations. The skill is simple to learn and requires only basic terminal commands to get started.

You will often encounter shell scripts starting with #! /bin/bash, #! is called a shebang or hashbang. shebang plays an important role in shell scripting, especially when dealing with different types of shells.
### 7. Explanation of Output During the Execution of "common.sh" file.
	PS>"Installing Docker"

	Until this step in the common.sh we try to download all images required for the kudeadm configuration. This step without errors signifies that we are now ready to deploy our control plane. Adding Kubernetes Repository. Adding Firewall Rules. Deactivatind 	Firewall. Disabling SWAP

	PS>"Adding Kubernetes Repository"

	Now, run the apt-add-repository command to add the Kubernetes package repository in Ubuntu. You must perform the following steps:
	
		printf "##### Adding Kubernetes Repository #####\n"
		sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
		echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list


	PS>"Adding Firewall Rules"



	PS>"Deactivatind Firewall"



	PS>"Disabling SWAP".

 

### 8. Explanation of Output During the Execution of "master.sh" file.


	PS>"Preflight Check Passed: Downloaded All Required Images".

	Until this step in the master.sh we try to download all images required for the kudeadm configuration. This step without errors signifies that we are now ready to deploy our control plane.

	PS>"K8s Control Plane Successful".

	After this output you can be certain that the init command has been executed and the control plane is now running at 10.0.0.10 and the api-server is listening to that address.

	PS>"Admin Conf Directory Made. ENV variable exported".

	The admin configuration directory is made through the following commands which have to be executed 

	*as root:

		$ export KUBECONFIG=/etc/kubernetes/admin.conf
	
	*or as others:

		$ mkdir -p "$HOME"/.kube
  		$ cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
 		$ chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
	
	PS>"Network Appplied".

	Flannel in Kubernetes is a virtual layer that is used with containers, it is designed basically for containers only. The above output shows that a network for pods has been created.

	PS>"Join Sh Created".

	Until this step in the master.sh we try to download all images required for the kudeadm configuration. This step without errors signifies that we are noe 		readyt to deploy our control plane.

	PS>"Install Calico Network Plugin".

	After this output you can be certain that the init command has been executed and the control plane is now running at 10.0.0.10 and the api-server is listening 		to that address.

	PS>

### 9. Explanation of the node.sh file.

This script is meant to make the _workers_ join the working _master_. The 'master.sh' script while deploying the master will create the print-join command that can be used to make the workers join a cluster. node.sh automates by executing this script.
### 10. FAQs.
Error FAQs:

	Error: Long wait during execution of certain commands. {processing triggers for man-db, generating initramfs, get package #118}. 
	Solution: All these are normal. Make sure you have a good internet connection and stay online.
	Error: System not running as sudo.
	Solution: Make sure vagrant and virtualbox are not blocked on your host system and have sufficient privilleges.
	Error: Unspecified filesystem vboxfs.
	Solution: Try to change the version of ubuntu in main vagrantfile.
	
Question: What is SWAP space and why it must be disabled in kubernetes master and worker nodes?

Answer: **Swap space** is a space on a hard disk that is a substitute for physical memory. It is used as virtual memory which contains process memory images. Whenever our computer runs short of physical memory it uses its virtual memory and stores information in memory on disk. Swap space helps the computer’s operating system in pretending that it has more RAM than it actually has. It is also called a swap file. To summarize, the lack of swap support lies in the fact that swap usage is not even expected in Kubernetes and there are enormous work to be done before swap can be used in product scenarios. IMHO, these work are no just about Kubernets itself but also enven more about Linux kernel. It might be problem for the Kubernetes community to find a strong motivation to tackle this issue considering the huge amount of efforts ahead.

Question: Why the **Master-Slave** Architecture and how it helps in production?

Answer: The master node in a Kubernetes architecture is used to manage the states of a cluster. It is actually an entry point for all types of administrative tasks. In the Kubernetes cluster, more than one master node is present for checking the fault tolerance.




### How the Project Executes ?

**Step 1:** Automated Creation of a local K8s cluster.

A K8S cluster is created on a vagrant environment with 1 master node and 2 worker nodes. The master node is responsible to create a control plane to which the workers can join. The script automatically starts the control plane in the master node and also makes the worker nodes join it. Once the worker nodes have joined. the cluster can be verified on the master node by running:

		kubectl get nodes -o wide
		kubectl get all -o wide

**Step 2:** Assign Labels to the worker nodes.


**Step 6:** From the above commands find the external ip of the pods. 

			vagrant ssh worker1
			
ssh into the worker node using. As the mworkers donot run kube-proxy we cannot see output from master node. Curl to this ip to verify if the the pods are running the required containers or not.


			curl http://<IP from above> 

NOTE:- The same project should also be executed through jenkins as a CI/CD project and the screenshots are present in the folder 'screenshots' in the root of the project. hint is to install the jenkins plugin for vagrant and then do a vagrant up inside jenkins.

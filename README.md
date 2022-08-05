
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

#### Architecture of Solution
The project will create a Kubernetes 1.15.0 cluster with 3 nodes which contains the components below:

| IP           | Hostname | Componets                                |
| ------------ | -------- | ---------------------------------------- |
| 10.0.0.10 | master    | kube-apiserver, kube-controller-manager, kube-scheduler, etcd, kubelet, docker, flannel, dashboard |
| 10.0.0.11 | node01    | kubelet, docker, flannel, todo-myapp          |
| 10.0.0.12 | node02    | kubelet, docker, flannel, mysql-container               |


		 ______________________________________________________________________________________
		'											'
		'	 common.sh	''''''''''''\   kubeadm,kubectl,dashboard,REST			'
		' /----> master.sh --->	'   Master  / <<------------<------------- 			'
		'/			''''''''''''				'			'
		'								'			'
		'								'			'
		'								'
		'	common.sh	''''''''''''\				'			'
	Vagrant-'----->	node.sh	 ---->	   Node01---->-> Docker Container <-<---- ' <----<----kubernetes'
		'	 			    /	  (To-do APP)		'		        '
	        '\			''''''''''''				'			'					
		' \								'
		' \								'
		'  \	   common.sh	''''''''''''				'			'
		'   \----->node.sh --->	'   Node02--->-> Docker Conatiner  <-<----'			'
		'			''''''''''''	    (MySQL)					'
	 	'											'
		'______________________________________________________________________________________	'
		
#### Automated Stages in DevOps Development

     1. Automated Creation of Infrastructure
     
     In this project we create the AWS infrstructure using the infra.tf file. The screenshots of this phase are included in the email
     
     2. Automated Resource Configuration
     
     The resource configuration can be done using ansible and/or scripts. The project includes 3 scripts - common.sh, master.sh, worker.sh
     
     3. Automated Cluster and Auto-scaling
     
     The project uses Kubeadm for cluster creation and auto-scaling. 
     
     4. Automated Application Code Manangement-Github
     
     Git is used for Application Code Manangement
     
     5. Automated CI/CD
     
     Jenkins has been used to check the CI/CD project
     
     6. Automated Monitoring.
     
     Cloudwatch has been used to watch the cluster and its status.
#### How to execute the project?

The project can be executed by just using a single command. Download the project folder and then inside the folder use Powershell to run the follwoing command

    PS>terraform init
    PS>terraform plan
    PS>terraform apply
    
    
The resources and the cluster created can be destroyed by executing the following command in the root folder of the project.

    PS>terraform destroy
    
 
### 5. Troubleshoot Execution.
Do a vagrant up the first time you execute. Let the process complete in one go. If it gets stuck then close the VMs from virtualbox and then do the follwoing options from the root folder.

	PS>terraform destroy
	
### Why Bash Scripts for Automation ?

Bash is a Unix command line interface for interacting with the operating system, available for Linux and macOS. Bash scripts help group commands to create a program. All instructions that run from the terminal work in Bash scripts as well.

Bash scripting is a crucial tool for system administrators and developers. Scripting helps automate repetitive tasks and interact with the OS through custom instruction combinations. The skill is simple to learn and requires only basic terminal commands to get started.

You will often encounter shell scripts starting with #! /bin/bash, #! is called a shebang or hashbang. shebang plays an important role in shell scripting, especially when dealing with different types of shells.

### How the Project Executes ?

**Step 1:** Automated Creation of a local K8s cluster.

A K8S cluster is created on a vagrant environment with 1 master node and 2 worker nodes. The master node is responsible to create a control plane to which the workers can join. The script automatically starts the control plane in the master node and also makes the worker nodes join it. Once the worker nodes have joined. the cluster can be verified on the master node by running:

		kubectl get nodes -o wide
		kubectl get all -o wide

**Step 2:** Assign Labels to the worker nodes.

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

**Step 6:** From the above commands find the external ip of the pods. 

			vagrant ssh worker1
			
ssh into the worker node using. As the mworkers donot run kube-proxy we cannot see output from master node. Curl to this ip to verify if the the pods are running the required containers or not.


			curl http://<IP from above> 

NOTE:- The same project should also be executed through jenkins as a CI/CD project and the screenshots are present in the folder 'screenshots' in the root of the project. hint is to install the jenkins plugin for vagrant and then do a vagrant up inside jenkins.

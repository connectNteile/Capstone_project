Guide 
Running  Vagrant VM while connecting AWS involves configuring your Vagrant VM
to interact with AWS, setting up the neccessary tools, and then following the steps
 to deploy the socks shop  application

Step 1: Setup your Vagrant VM to work with AWS 
1.1 Create  a Vagrantfile
	vagrant init ubuntu/focal64

    Edit the file to ensure it has enough resources
    vagrant.configure ("2") do |config|
      config.vm.box = "ubuntu/bionic64"

      config.vm.provider "virtualox" do |vb| 
	vb.memory = "4096"
	vb.cpus = 2
      end

  #optional: forward ports if you eed access services ruig on the VM
      config.vm.network "forward_port", guest: 80, host: 8080
      config.vm.network "forward_port", guest: 443, host: 8443
   end

1.2 Start the VM  ad SSH into it
	vagrant up
	vagrant ssh

Step 2: Install Required Tools on Vagrant VM
2.1 update and install dependencies
	sudo apt-get update
	sudo apt-get istall -y \
	awscli \
	git \
	vim \
	unzip \
	software-properties-common

2.2 Install Docker  
	sudo apt-get install -y
	docker.io
	sudo systemctl start docker
	sudo systemctl enable docker
	sudo usermod -aG dociker vagrant 
  Logout ad ssh back in to apply Docker group changes

2.3 Install Kubectl
	curl -LO
	"https://dl.k8s.io/release
	/$(curl -L -s
	https://dl.k8s.io/release
	/stable.txt)/bin/linux/amd64
	/kubectl"
	chmod +x kubectl
	sudo mv kubectl /usr/local/bin

2.4 Install Helm
	curl
	https://baltocdn.com/helm/signing.asc | sudo apt-key add -
	sudo apt-get install
	apt-transport-https --yes
	echo "deb
	https://baltocdn.com/helm
	/stable/debian/ all main" |
	sudo tee /etc/apt
	sources.list.d/
	helm-stable-debian.list
	sudo apt-get update
	sudo apt-get istall -y helm

2.5 Install Terraform
	curl -fsSL
	https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	sudo apt-add-repository "deb
	[arch=amd64]
	https://apt.releases.hashicorp.com $(lsb_release -cs) main"
	sudo apt-get update && sudo apt-get install -y terraform

Step 3: Configure AWS CLI on Vagrant VM
3.1 Setup AWS CLI (Configure AWS CLI with your credentials:
	aws configure
  
AWS Access key ID: Your AWS access key.
AWS Secret Access Key: Your AWS secret key
Default region ame: The regio you want to use e.g. us-east-2
Default Output format: json

Step 4: Provisio Infrastructure on AWS with Terraform
4.1 create a terraform configuration files 
	1. (provider.tf)
		provider "aws"{
	  	  region = "us-east-1"
		}
	2. vpc.tf	
		resources "aws_vpc" "main" {
		  cidr_block = "10.0.0.0/16"
		}   
		
		resources "aws_subnet" "subnet" {
		  vpc_id = aws_vpc.main.id
			  cidr_block = 10.0.1.0/24" 
		}
	      
	3. eks.tf
		module "eks" {
		  source = "terraform-aws-modules/eks/aws"
		  cluster_name = "1.21" 
		  subnets = [aws_subnet.subnet.id]
		  vpc_id = aws_vpc.main.id	
		}
	
4.2 Deploy the infrastructure
Initialize and apply the Terraform configuration:
	terraform init
	terraform apply -auto-approve

so this will create VPC, subnet, and EKS cluster on AWS.


Step 5: Configure kubectl to access the EKS Cluster
so once EKS Cluster is up, configure kubectl to interact with it
	aws eks --region us-east-2
	update-kubeconfig --name
	socks-shop-cluster

verify the connection
	kubectl get nodes

Step 6: Deploy the Socks Shop Application on AWS EKS
6.1. Clone the socks shop repository
	git clone https://github.com/microservices-demo/microservices-demo.git
	cd microservices-demo/deploy/kubernetes

6.2 Deploy the Application
Deploy the socks shop application on EKS Cluster
	kubectl apply -f
	complete-demo.yaml
Verify the deployment
	kubectl get pods
	kubectl get services

Step 7: Setup Monitoring, Logging &n Security
7.1 Install Prometheus and Grafana using Helm
	a. Add Helm repository
		helm repo add prometheus-community
		https://prometheus-commuity.github.io/helm-charts 
		helm repo update
	b. deploy promethus
		helm install prometheus prometheus-community/prometheus
	c. deploy Grafana
		helm install grafana prometheus-community/grafana
7.2 Setup HTTPs with Let's Encrypt
1. Install cert-manager
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install cert-manager jetstack/cert-manager --namespace
	cert-manager --create-namespace
2. create a issuer and certificate: create and apply a kubernetes manifest for your ClusterIssuer and Certificate, pointing to your

Step 8: Create a CI/CD pipeline
8.1 using github actions
	a. create a .github/workflows/deploy.yml
		name: deploy to kuberetes

		on:
		  push:
		    branches:
		      - main

		jobs:
		  build:
		    runs-on: ubuntu-latest

		    steps:
		    - uses: actions/checkout@v2

		    - name: Set up Kubernetes
		      uses: aws/setup-kubectl@v1
		      with:
		        version: '1.21.01
		    - name: Deploy to kubernetes
		      run: |
			kubectl apply -f microservices-demo/deploy/kubernetes/completes-demo.yaml
	b. Push to github
		git add .
		git commit -m "Add CI/CD pipeline"
		git push origin main 				 	  		    				  
This pipeline will automatically deploy your application to kubernetes whenever you push changes to the main branch.

So with this we have successfully setup to deploy sock shop microservices applicatio on AWS EKS from vagrat maaged VM.
I have istalled ecessary tools, setup AWS infrastructure with Terraform and deployed the application using kubernetes.
Monitoring, logging ad HTTPS are configured, and automated deployments using CI/CD pipeline          
	
	  
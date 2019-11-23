# Three nodes kubernetes cluster  in AWS using Terraform.

# clone project into your local server
git clone https://github.com/geethankuriakose/myproject.git 

cd cats
# Login into docker hub. 

#Please update your user name & password in scripts/my_password.txt & scripts/docker_login.sh
#please verify docker service is running in your local server

./scripts/docker_login.sh 

# Build & push docker images into docker hub

./scripts/build_push_docker_img.sh
cd ..

# Download , Install & configure Terraform

wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
unzip terraform_0.11.11_linux_amd64.zip
sudo cp terraform /usr/local/bin

# Create an user in AWS IAM

create an aws iam user and group with AWSEC2FULLaccess rights  and download your pem file into myproject directory

# update following varaibles in myprooject.tf
 
variable "ssh_key_name" {default = "Enter your pen name"}
access_key = "Enter your access_key"
secret_key = "Enter your secret_key"

# Bootstrap terraform

terraform init
terraform plan
terraform apply

# Deploy your pods into kubernetees cluster
#master server
ssh -i "amiuser.pem" ubuntu@ec2-3-19-123-163.us-east-2.compute.amazonaws.com

kubectl get nodes
kubectl  create -f ~/yamls/rollingupdate_v10.yaml

# To watch container  status

watch kubectl get all -o wide
kubectl rollout status deployment myapp-deploy  | less
kubectl describe deployment myapp-deploy
kubectl rollout  history  deployment myapp-deploy

# Rolling update without zero Downtime

kubectl set image  deployment myapp-deploy  myapp=sosamma2018/myapp:v11 --record
    or 
kubectl  apply -f ~/yamls/rollingupdate_v11.yaml

watch kubectl get all -o wide
kubectl rollout  history  deployment myapp-deploy

# if any error found in our deployment  , please do the revision

kubectl rollout  history  deployment myapp-deploy --revision=1 
kubectl rollout undo deployment myapp-deploy --to-revision=1
watch kubectl get all -o wide

# Remove  myapp  Deployment from kubernetees cluster 
##kubectl delete -f   /home/vagrant/myproject/service.yaml

kubectl  delete deployment myapp-deploy


# To tear down all the created resources

terraform destroy



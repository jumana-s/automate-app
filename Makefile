COLOUR_GREEN=\033[0;32m
COLOUR_RED=\033[0;31m
COLOUR_BLUE=\033[0;34m
COLOUR_END=\033[0m

REGION := us-east-1
ECR_REPOSITORY := simple-api-app-images
CLUSTER := dev-cluster
APP_SVC := simple-app-service
APP_NAME := simple-app
LINES := 16
AWS_ACCESS_KEY := 
AWS_SECRET_KEY := 

all: install run-all

install: install-aws install-terraform install-terragrunt install-docker install-kubectl

run-all:  aws-configure create-infra build-app deploy-app get-app-link

destroy: destroy-app destroy-infra

install-aws:
	@echo "$(COLOUR_BLUE)Installing aws$(COLOUR_END)";
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip";
	unzip awscliv2.zip;
	sudo ./aws/install;
	rm -rf aws && rm awscliv2.zip;
	@echo "$(COLOUR_GREEN)aws has been installed$(COLOUR_END)"

# executed in src/ cause it extracts folder named terraform and cant have two folders named terraform
install-terraform:
	@echo "$(COLOUR_BLUE)Installing terraform$(COLOUR_END)";
	curl "https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip" -o "src/terraform.zip"; 
	unzip src/terraform.zip -d src/; 
	sudo mv ./src/terraform /usr/local/bin/terraform; 
	rm src/terraform.zip
	@echo "$(COLOUR_GREEN)terraform has been installed$(COLOUR_END)"

install-terragrunt:
	@echo "$(COLOUR_BLUE)Installing terragrunt$(COLOUR_END)";
	curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.45.11/terragrunt_linux_amd64" -o "terragrunt";
	chmod +x terragrunt;
	sudo mv terragrunt /usr/local/bin/terragrunt;
	@echo "$(COLOUR_GREEN)terragrunt has been installed$(COLOUR_END)"

install-docker:
	@echo "$(COLOUR_BLUE)Installing docker$(COLOUR_END)";
	curl -fsSL https://get.docker.com -o get-docker.sh; 
	sudo sh ./get-docker.sh;
	rm get-docker.sh;
	@echo "$(COLOUR_GREEN)docker has been installed$(COLOUR_END)"

install-kubectl:
	@echo "$(COLOUR_BLUE)Install kubectl$(COLOUR_END)";
	curl -LO "https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl";
	chmod +x kubectl;
	sudo mv kubectl /usr/local/bin
	@echo "$(COLOUR_GREEN)kubectl has been installed$(COLOUR_END)"
	
aws-configure:
	@echo "$(COLOUR_BLUE)configuring aws credentials$(COLOUR_END)"
	aws configure set aws_access_key_id $(AWS_ACCESS_KEY);
	aws configure set aws_secret_access_key $(AWS_SECRET_KEY);
	aws configure set default.region $(REGION);
	aws sts get-caller-identity;
	@echo "$(COLOUR_GREEN)aws has been configured$(COLOUR_END)"

create-infra: 
	@echo "$(COLOUR_BLUE)Creating infrastructure$(COLOUR_END)";
	cd terraform/terragrunt/dev/infra && \
	terragrunt run-all init --terragrunt-non-interactive && \
	terragrunt run-all plan && \
	terragrunt run-all apply --terragrunt-non-interactive;
	@echo "$(COLOUR_GREEN)Infra created xD$(COLOUR_END)" 

build-app:
	@echo "$(COLOUR_BLUE)Building & pushing image$(COLOUR_END)";
	$(eval ACCOUNT:= $(shell aws ecr describe-registry --query registryId --output text))
	aws ecr get-login-password --region $(REGION) | sudo docker login --username AWS \
	 --password-stdin $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com;
	sudo docker build -t $(ECR_REPOSITORY):latest . ;
	sudo docker tag $(ECR_REPOSITORY):latest $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com/$(ECR_REPOSITORY);
	sudo docker push $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com/$(ECR_REPOSITORY);
	@echo "$(COLOUR_GREEN)Image built$(COLOUR_END)" 

deploy-app:
	@echo "$(COLOUR_BLUE)Creating app$(COLOUR_END)" ; 
	cd terraform/terragrunt/dev/apps && \
	terragrunt run-all init --terragrunt-non-interactive && \
	terragrunt run-all plan && \
	terragrunt run-all apply --terragrunt-non-interactive;
	@echo "$(COLOUR_GREEN)App created$(COLOUR_END)" 

get-app-link:
	@echo "$(COLOUR_BLUE)Getting app link$(COLOUR_END)";
	aws eks update-kubeconfig --region $(REGION) --name $(CLUSTER);
	sleep 5;
	$(eval link := $(shell kubectl get svc $(APP_SVC) -n $(APP_NAME) -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'))
	@echo "$(COLOUR_GREEN)Link: \n\t http://$(link)/msg $(COLOUR_END)";
	@echo "$(COLOUR_RED)\tMight need to referesh a couple of times, endpoint might not be ready.$(COLOUR_END)"

destroy-app:
	@echo "$(COLOUR_BLUE)Delete app$(COLOUR_END)" ;
	cd terraform/terragrunt/dev/apps && \
	terragrunt run-all destroy --terragrunt-non-interactive;
	@echo "$(COLOUR_GREEN)App deleted$(COLOUR_END)" 

# Will leave this as interactive in case you dont want to delete your infra
destroy-infra:
	@echo "$(COLOUR_BLUE)Delete infra$(COLOUR_END)";
	
	# empty repository
	aws ecr batch-delete-image --region $(REGION) --repository-name $(ECR_REPOSITORY) \
    	--image-ids imageTag=latest ;
	
	cd terraform/terragrunt/dev/infra && \
	terragrunt run-all destroy;
	
	@echo "$(COLOUR_GREEN)Infra deleted$(COLOUR_END)" 

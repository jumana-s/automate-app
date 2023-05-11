COLOUR_GREEN=\033[0;32m
COLOUR_RED=\033[0;31m
COLOUR_BLUE=\033[0;34m
COLOUR_END=\033[0m

REGION := us-east-1
ECR_REPOSITORY := simple-api-app-images
CLUSTER := dev-cluster
APP_SVC := simple-app-service
APP_NAME := simple-app


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
	cd src; \
	curl "https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip" -o "terraform.zip"; \
	unzip terraform.zip; \
	# chmod +x terraform
	sudo mv ./terraform /usr/local/bin/terraform; \
	@echo "$(COLOUR_GREEN)terraform has been installed$(COLOUR_END)"

install-terragrunt:
	@echo "$(COLOUR_BLUE)Installing terragrunt$(COLOUR_END)";
	curl "https://github.com/gruntwork-io/terragrunt/releases/download/v0.45.11/terragrunt_linux_amd64" -o "terragrunt";
	chmod u+x terragrunt;
	mv terragrunt /usr/local/bin/terragrunt;
	@echo "$(COLOUR_GREEN)terragrunt has been installed$(COLOUR_END)"

install-docker:
	@echo "$(COLOUR_BLUE)Installing docker$(COLOUR_END)";
	curl -fsSL https://get.docker.com -o get-docker.sh; 
	sudo sh ./get-docker.sh;
	@echo "$(COLOUR_GREEN)docker has been installed$(COLOUR_END)"

install-kubectl:
	@echo "$(COLOUR_BLUE)Install kubectl$(COLOUR_END)";
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl;
	@echo "$(COLOUR_GREEN)docker has been installed$(COLOUR_END)"

create-infra:
	@echo "$(COLOUR_BLUE)Creating infrastructure$(COLOUR_END)";
	cd terraform/terragrunt/dev/infra;
	terragrunt run-all init;
	terragrunt run-all plan;
	terragrunt run-all apply;
	@echo "$(COLOUR_GREEN)Infra created xD$(COLOUR_END)" 

build-app:
	@echo "$(COLOUR_BLUE)Building & pushing image$(COLOUR_END)";
	export ACCOUNT=$(shell aws ecr describe-registry --query registryId --output text); \
	aws ecr get-login-password --region $(REGION) | docker login --username AWS \
	 --password-stdin $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com;
	docker build -t $(ACCOUNT)/$(ECR_REPOSITORY):latest . ;
	docker push $(ACCOUNT)/$(ECR_REPOSITORY):latest ;
	@echo "$(COLOUR_GREEN)Image built$(COLOUR_END)" 

deploy-app:
	@echo "$(COLOUR_BLUE)Creating app$(COLOUR_END)" ; 
	cd terraform/terragrunt/dev/apps;
	terragrunt run-all init;
	terragrunt run-all plan;
	terragrunt run-all apply;
	@echo "$(COLOUR_GREEN)Infra created xD$(COLOUR_END)" 

get-app-link:
	@echo "$(COLOUR_BLUE)Getting app link$(COLOUR_END)";
	aws eks update-kubeconfig --region $(REGION) --name $(CLUSTER);
	export link=$(shell kubectl get svc $(APP_SVC) -n $(APP_NAME) -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
	@echo "$(COLOUR_GREEN)Link - http://$(link)/msg $(COLOUR_END)" 

destroy: destroy-app destroy-infra

destroy-app:
	@echo "$(COLOUR_BLUE)Delete app$(COLOUR_END)" ;
	cd terraform/terragrunt/dev/apps;
	terragrunt run-all destroy;
	@echo "$(COLOUR_GREEN)App deleted$(COLOUR_END)" 

destroy-infra:
	@echo "$(COLOUR_BLUE)Delete infra$(COLOUR_END)";
	cd terraform/terragrunt/dev/infra;
	terragrunt run-all destroy;
	@echo "$(COLOUR_GREEN)Infra deleted$(COLOUR_END)" 

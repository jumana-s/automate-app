# Liatrio Cloud Native Exercise

A take home project to automate infrastructure creation and application deployment.

## Setup Locally

Steps to create terraform infrastructure, build & push image, and deploy image to kubernetes cluster.

### Prerequisites

- We will be using AWS for all parts, so you will need to [create an AWS account](https://aws.amazon.com/resources/create-account/)
  - Please create an IAM user with permission policy `AdministratorAccess` on AWS console.
  - Create an access key for the user in the Security credentials tab.
  - Save access and secret key to [Makefile](./Makefile) variables.
- Region is written as `us-east-1` in configuration across the repo. If you are using another region edit [common.hcl](./terraform/terragrunt/dev/common.hcl), [terragrunt.hcl](./terraform/terragrunt/terragrunt.hcl), and [Makefile](./Makefile).
- Script was created/written on/for Linux. Can't guarantee it works for macOS.

**NOTE**: S3 Bucket names need to be unique. Tried leaving unique name.[Might need to change](./terraform/terragrunt/terragrunt.hcl)

### Run

If you already have **aws**, **terraform**, **kubectl**, **terragrunt**, and **docker** installed you can run `make run-all`. It will configure aws with the credentials given, create the cluster, and deploy application.

- If you need to install one of the listed tools above see [Commands](#commands)

else

**Run** `make all` to install cli commands, configure aws, create cluster, and deploy application.

#### Cleanup / Destroy

To destroy terraform resources run `make destroy`

#### Commands

| command                   | description                                                                                                                                  |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `make all`                | Install aws, docker, kubectl, terragrunt, and terraform. Configure aws, create infrastructure, deploy application, and provide app link.     |
| `make install`            | Install aws, docker, kubectl, terragrunt, and terraform. **Note:** only use if you don't have any those, else use specific install commands. |
| `make run-all`            | Configure aws, create infrastructure, deploy application, and provide app link                                                               |
| `make destroy`            | Destroy infrastructure and undeploy app                                                                                                      |
| `make install-aws`        | Install AWS cli                                                                                                                              |
| `make install-terraform`  | Install Terraform                                                                                                                            |
| `make install-terragrunt` | Install Terragrunt                                                                                                                           |
| `make install-docker`     | Install Docker                                                                                                                               |
| `make install-kubectl`    | Install kubectl                                                                                                                              |
| `make aws-configure`      | Configure aws using user provide AWS access and secret key                                                                                   |
| `make create-infra`       | Creates Infrastructure                                                                                                                       |
| `make build-app`          | Build and pushes docker image to ECR                                                                                                         |
| `make deploy-app`         | Deploy's app on cluster and creates service to expose deployment to the internet                                                             |
| `make get-app-link`       | Get the deployment's link                                                                                                                    |
| `make destroy-app`        | Undeploy's app and deletes service                                                                                                           |
| `make destroy-infra`      | Destroys ECR and cluster                                                                                                                     |

## Replicate setting up workflow

1. Have an AWS Account
2. [Configure OpenID Connect within your workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
3. Give the Identity provider enough permissions.
4. Add Github secret of role ARN called `AWS_PIPELINE_ROLE`
5. Update region in workflow files if needed, right now its set to `us-east-1`

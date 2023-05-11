# Liatrio Cloud Native Exercise

## Setup Locally

Steps to create terraform infrastructure, build & push image, and deploy image to kubernetes cluster.

### Prerequisites

- We will be using AWS for all parts, so you will need to [create an AWS account](https://aws.amazon.com/resources/create-account/)
- Please configure aws for your cli. Whether you want to [use AWS access key or another configuring method](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
  - Make sure the user has Admin permissions.
- Region is written as `us-east-1` in configuration across the repo. If you are using another region edit [common.hcl](./terraform/terragrunt/dev/common.hcl), [terragrunt.hcl](./terraform/terragrunt/terragrunt.hcl), and [Makefile](./Makefile).
- Script was created/written on/for Linux. Can't guarantee it works for macOS.

## Replicate setting up workflow

1. Have an AWS Account
2. [Configure OpenID Connect within your workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
3. Give the Identity provider enough permissions.
4. Add Github secret of role ARN called `AWS_PIPELINE_ROLE`
5. Update region in workflow files if needed, right now its set to `us-east-1`

# Infrastructure

## Run

Need to have an AWS account, create an IAM user then authenticate AWS cli locally.
Also need to have terragrunt installed!

### For Infra

- Move to terragrunt/dev/infra `cd terragrunt/dev/infra`
- Run `terragrunt run-all init`
- Run `terragrunt run-all plan`
- Run `terragrunt run-all apply`

### For Apps

- Move to terragrunt/dev/infra `cd terragrunt/dev/apps`
- Run `terragrunt run-all init`
- Run `terragrunt run-all plan`
- Run `terragrunt run-all apply`

### To test modules

- Move to terratest/ `cd terratest`
- Run `go test -v -timeout 30m`

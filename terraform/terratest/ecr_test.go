package test

import (
	"testing"
	
	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestECRCreate(t *testing.T) {
	t.Parallel()

	ecr_name := "test"

	/// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        // The path to where our Terraform code is located
        TerraformDir: "../modules/ecr",

        //Variables to pass to our Terraform code using -var options
        Vars: map[string]interface{}{
            "name":  ecr_name,
        },
    })

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`.
	terraform.InitAndApply(t, terraformOptions)

	created_repo_name := terraform.Output(t, terraformOptions, "created_repo_name")

	// Verify that the ECR has been created successfully
	assert.Equal(t, ecr_name, created_repo_name)
}

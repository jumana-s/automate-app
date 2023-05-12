//
// Building cluster needs to be done twice, tests will prob fail
//

package test

import (
	"testing"
	
	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestEKSCluster(t *testing.T) {
	t.Parallel()

	cluster_name := "test"

	/// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        // The path to where our Terraform code is located
        TerraformDir: "../modules/cluster",

        //Variables to pass to our Terraform code using -var options
        Vars: map[string]interface{}{
            "cluster_name":  cluster_name,
        },
    })

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`.
	terraform.InitAndApply(t, terraformOptions)

	result_name := terraform.Output(t, terraformOptions, "cluster_name")
	status      := terraform.Output(t, terraformOptions, "status")
	endpoint    := terraform.Output(t, terraformOptions, "cluster_endpoint")

	// Verify that the EKS cluster has been created successfully
	assert.Equal(t, "ACTIVE", status)
	assert.Equal(t, cluster_name, result_name)
	assert.NotNil(t, endpoint)
}

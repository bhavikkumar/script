# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$name,
   [Parameter(Mandatory=$true)][string]$description,
   [Parameter(Mandatory=$true)][string]$policyFileLocation
)

Write-Host "Creating service control policy(SCP)"
aws organizations create-policy --type SERVICE_CONTROL_POLICY --description $description --name $name --content file://$policyFileLocation --profile $profile

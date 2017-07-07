# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$policyId,
   [Parameter(Mandatory=$true)][string]$targetId
)

Write-Host "Attaching service control policy (SCP)"
aws organizations attach-policy --policy-id $policyId --target-id $targetId --profile $profile

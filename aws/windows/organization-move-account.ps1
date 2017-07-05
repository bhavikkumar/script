# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$accountId,
   [Parameter(Mandatory=$true)][string]$organizationalUnit
)

# Get the current parent, which by default should be the root organization
$ListParentsResponse = (aws organizations list-parents --child-id $accountId --profile $profile) | ConvertFrom-Json
$Parents = $ListParentsResponse.Parents

If ($Parents.Length -gt 0) {
  $ParentId = $Parents[0].Id

  # Move the account to the correct organizational unit
  aws organizations move-account --account-id $accountId --source-parent-id $ParentId --destination-parent-id $organizationalUnit --profile $profile

  Write-Host "Account $accountId moved successfully"
} Else {
  Write-Host "ERROR: Could not move the account"
}

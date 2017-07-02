# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$email,
   [Parameter(Mandatory=$true)][string]$name,
   [Parameter(Mandatory=$true)][string]$organizationalUnit
)

# Create an account and then keep checking its status until its created.
Write-Host "Creating account: $name, this may take a few minutes..."
$CreateAccountResponse = (aws organizations create-account --email $email --account-name "$name" --profile $profile)  | ConvertFrom-Json

$CreateAccountRequestId = $CreateAccountResponse.CreateAccountStatus.Id
$Status = $CreateAccountResponse.CreateAccountStatus.State

# Every x seconds check if the account status is now succeeded
While ($Status -ne "SUCCEEDED")
{
  Start-Sleep -s 30
  $AccountStatusResponse = (aws organizations describe-create-account-status --create-account-request-id $CreateAccountRequestId --profile $profile) | ConvertFrom-Json
  $AccountId = $AccountStatusResponse.CreateAccountStatusRequest.AccountId
  $Status = $AccountStatusResponse.CreateAccountStatusRequest.State
}

# Get the current parent, which by default should be the root organization
$ListParentsResponse = (aws organizations list-parents --child-id $AccountId --profile $profile) | ConvertFrom-Json

$ParentId = $ListParentsResponse.Parents[0].Id

# Move the account to the correct organizational unit
aws organizations move-account --account-id $AccountId --source-parent-id $ParentId --destination-parent-id $organizationalUnit --profile $profile

Write-Host "Account $name successfully created"

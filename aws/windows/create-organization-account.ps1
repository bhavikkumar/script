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

Write-Host "Create Account Request Id: $CreateAccountRequestId"

# Every x seconds check if the account status is now succeeded
While ($Status -ne "SUCCEEDED")
{
  Start-Sleep -s 120
  $AccountStatusResponse = (aws organizations describe-create-account-status --create-account-request-id $CreateAccountRequestId --profile $profile) | ConvertFrom-Json
  $AccountId = $AccountStatusResponse.CreateAccountStatus.AccountId
  $Status = $AccountStatusResponse.CreateAccountStatus.State
}

Write-Host "Account $name with Account Id $AccountId successfully created"

# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$mfaArn,
   [Parameter(Mandatory=$true)][string]$mfatoken
)

# This script could be replaced with AWS Tools for Windows Powershell
$Response = (aws sts get-session-token --serial-number $mfaArn --token-code $mfatoken --profile $profile)  | ConvertFrom-Json

$NewAccessKeyId = $Response.Credentials.AccessKeyId
$NewSecretKey = $Response.Credentials.SecretAccessKey
$NewSessionToken =  $Response.Credentials.SessionToken
$ExpirationTime = $Response.Credentials.Expiration
$TempProfile = $profile + "-temp"

aws configure set aws_access_key_id $NewAccessKeyId --profile $TempProfile
aws configure set aws_secret_access_key $NewSecretKey --profile $TempProfile
aws configure set aws_session_token $NewSessionToken --profile $TempProfile

Write-Host "Profile Name: $TempProfile"
Write-Host "Expires At : $ExpirationTime"

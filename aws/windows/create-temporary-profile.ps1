# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$identityAccount,
   [Parameter(Mandatory=$true)][string]$username,
   [Parameter(Mandatory=$false)][string]$assumeRoleAccount,
   [Parameter(Mandatory=$false)][string]$roleName,
   [Parameter(Mandatory=$true)][string]$mfatoken
)

# This script could be replaced with AWS Tools for Windows Powershell
$mfaAccount = "arn:aws:iam::" + $identityAccount + ":mfa/" + $username
$Response = (aws sts get-session-token --serial-number $mfaAccount --token-code $mfatoken --profile $profile)  | ConvertFrom-Json

If(![string]::IsNullOrEmpty($Response)) {
  $NewAccessKeyId = $Response.Credentials.AccessKeyId
  $NewSecretKey = $Response.Credentials.SecretAccessKey
  $NewSessionToken =  $Response.Credentials.SessionToken
  $ExpirationTime = $Response.Credentials.Expiration
  $MFAProfile = $profile + "-mfa"

  aws configure set aws_access_key_id $NewAccessKeyId --profile $MFAProfile
  aws configure set aws_secret_access_key $NewSecretKey --profile $MFAProfile
  aws configure set aws_session_token $NewSessionToken --profile $MFAProfile

  Write-Host "Created MFA Profile"
  Write-Host "Profile Name: $MFAProfile"
  Write-Host "Expires At : $ExpirationTime"
}

If (![string]::IsNullOrEmpty($assumeRoleAccount) -and ![string]::IsNullOrEmpty($roleName)) {
  $RoleProfileName = $username + "-" + $roleName + "-" + $assumeRoleAccount
  $roleAccount = "arn:aws:iam::" + $assumeRoleAccount + ":role/" + $roleName

  $AssumeRoleResponse = (aws sts assume-role --role-arn $roleAccount --role-session-name $RoleProfileName --profile $MFAProfile) | ConvertFrom-Json

  If (![string]::IsNullOrEmpty($AssumeRoleResponse)) {
    $AssumeRoleAccessKey = $AssumeRoleResponse.Credentials.AccessKeyId
    $AssumeRoleSecretKey = $AssumeRoleResponse.Credentials.SecretAccessKey
    $AssumeRoleSessionToken =  $AssumeRoleResponse.Credentials.SessionToken
    $AssumeRoleExpirationTime = $AssumeRoleResponse.Credentials.Expiration

    aws configure set aws_access_key_id $AssumeRoleAccessKey --profile $RoleProfileName
    aws configure set aws_secret_access_key $AssumeRoleSecretKey --profile $RoleProfileName
    aws configure set aws_session_token $AssumeRoleSessionToken --profile $RoleProfileName

    Write-Host "------"
    Write-Host "Created Assumed Role Profile"
    Write-Host "Profile Name: $RoleProfileName"
    Write-Host "Expires At : $AssumeRoleExpirationTime"
  }
}

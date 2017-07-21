# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile
)

Write-Host "Enabling service control policies (SCP)"
$RootOrganizations = (aws organizations list-roots --profile $profile)  | ConvertFrom-Json

$Roots = $RootOrganizations.Roots

If ($Roots.Length -gt 0) {
  $Root = $Roots[0].Id

  # Move the account to the correct organizational unit
  aws organizations enable-policy-type --root-id $Root --policy-type SERVICE_CONTROL_POLICY --profile $profile

  Write-Host "SCP enabled successfully"
} Else {
  Write-Host "ERROR: Could not enable SCP the account"
}

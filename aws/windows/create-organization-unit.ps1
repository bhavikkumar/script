# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile,
   [Parameter(Mandatory=$true)][string]$parentId,
   [Parameter(Mandatory=$true)][string]$name
)

# Create a organizational unit and attach it to the parent
aws organizations create-organizational-unit --parent-id $parentId --name "$name" --profile $profile

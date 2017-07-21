# This is a unsigned script, therefore the execution policy has to be set
# to unrestricted.

# The credentials here should be a IAM user with the correct privileges and not
# the root user.

param (
   [Parameter(Mandatory=$true)][string]$profile
)

# Create a master organization - this becomes the master account
aws organizations create-organization --feature-set ALL --profile $profile

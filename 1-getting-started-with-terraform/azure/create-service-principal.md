# Create an Azure Service Principal Account

**AzPowerShell**

Install `AzPowerShell`

```
Install-Module -Name Az -MinimumVersion 4.7.0
```

Connect to Azure with Az PowerShell

1. Run `Connect-AzAccount`
2. Copy toekn string from output
3. Open URL link provided in output
4. Sign into your Azure account

Create the Service Principal

```
$password = '<Password>'

$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password=$password};
  $spSplat = @{
      DisplayName = 'terraform-in20hours'
      PasswordCredential = $credentials
}

$sp = New-AzAdServicePrincipal @spSplat
```

_Replace `<Password>` with your password._

Assign the Contributor Role

```
$subId = (Get-AzContext).Subscription.Id

$roleAssignmentSplat = @{
ObjectId = $sp.id; RoleDefinitionName = 'Contributor'; Scope = "/subscriptions/$subId"
}

New-AzRoleAssignment @roleAssignmentSplat
```

Save AzPowerShell context

```powershell
Save-AzContext -Path $env:HOME/.azure/azpowershell.json
```

_Used by the Docker container to import local Azure context._

**AzCLI**

Install `AzCLI`

```
#mac
brew update && brew install azure-cli

#windows
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
```

Connect to Azure with AzCLI

1. Run `az login`
2. Select the correct Azure subscription to authenticate to

Create the Service Principal

```
$subId = (az account show | ConvertFrom-Json).id
az ad sp create-for-rbac -n 'terraform-in20hours' --role contributor --scope subscriptions/$subId
```

_Safely store the password output from this command._

Configuring the Service Principal in Terraform

```
$env:ARM_CLIENT_ID=(Get-AzADServicePrincipal -DisplayName 'terraform-in20hours').ApplicationId.Guid
$env:ARM_CLIENT_SECRET=$password
$env:ARM_SUBSCRIPTION_ID=(Get-AzContext).Subscription.Id
$env:ARM_TENANT_ID=(Get-AzContext).Tenant.Id
```
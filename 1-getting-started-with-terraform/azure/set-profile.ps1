$importAzContext = @"
if (Test-Path `"$env:HOME/.azure/azpowershell.json`")
{
    Import-AzContext -Path (`"$env:HOME/.azure/azpowershell.json`") | Out-Null
    `$azContext = Get-AzContext
    `$currentContext = [pscustomobject]@{
        subscriptionName=`$azContext.Subscription.Name
        subscriptionId=`$azContext.Subscription.Id
        tenantId=`$azContext.Subscription.TenantId
        account=`$azContext.Account
    }
}
Write-Host '---------------------------------------------'
Write-Host 'Azure Context:'
`$currentContext | Format-List | Out-String
"@

$importAzContext | Out-File $profile.AllUsersAllHosts


# if (Test-Path $env:HOME/.azure)
# {
#     Write-Host 'AzCli config detected'
#     Write-Host 'Populating Azure Service Principal Client Secret variables'
# 	`$env:ARM_CLIENT_ID=(az ad sp list --filter "displayname eq '$env:TERRAFORM_AZURE_SP'" --query [0].appId -o tsv)
# 	`$env:ARM_TENANT_ID=(az account show --query tenantId -o tsv)
# 	`$env:ARM_SUBSCRIPTION_ID=(az account show --query id -o tsv)
#     `$env:ARM_CLIENT_SECRET=Read-Host -Prompt 'Enter ARM_CLIENT_SECRET'
# }
# elseif (!(Test-Path $env:HOME/.azure)){
#     Write-Host 'AzCLI config not found...'
#     Write-Host 'Populating Azure Service Principal Client Secret variables'
#     `$env:ARM_CLIENT_ID=(Get-AzADServicePrincipal -DisplayName $($env:TERRAFORM_AZURE_SP)).ApplicationId.Guid
#     `$env:ARM_SUBSCRIPTION_ID=(Get-AzContext).Subscription.Id
#     `$env:ARM_TENANT_ID=(Get-AzContext).Tenant.Id
#     `$env:ARM_CLIENT_SECRET=Read-Host -Prompt 'Enter ARM_CLIENT_SECRET'
# }
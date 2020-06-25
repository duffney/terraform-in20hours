terraform apply -var="password=<password>" -auto-approve

(Get-AzPublicIpAddress | where name -Match 'tf-pip--').ipaddress -join ','
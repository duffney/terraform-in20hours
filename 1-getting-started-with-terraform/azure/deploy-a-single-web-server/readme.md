$text = gc ./custom_data.sh -Raw
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText


https://adsecurity.org/?p=478
https://medium.com/@gmusumeci/how-to-bootstrapping-azure-vms-with-terraform-c8fdaa457836
https://docs.microsoft.com/en-us/azure/developer/terraform/create-vm-cluster-with-infrastructure
https://amazicworld.com/building-auto-scaling-groups-in-azure-with-terraform/
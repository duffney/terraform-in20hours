# terraform-in20hours
Learning Terraform in 20 Hours

Outcome: Create windows & linux vm, sql instance, and app gateway 


1. Install Terraform in a Docker container

```
docker build -t terraform .

 docker run -it -v ${PWD}:/work terraform

```

2. Authentication to Azure
    
    Option 1: [Azure CLI](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html)
    #FACT: Use `az account show` to see which sub terraform will use.

    Option 2: [Authenticating using a Service Principal](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)

3. Initialize Terraform

    `terraform init`

Commands

```
terrafrom init

terraform plan

terraform apply

terraform destroy
```



## resources

https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure

https://phoenixnap.com/kb/how-to-install-terraform-centos-ubuntu

https://stackoverflow.com/questions/41485217/mount-current-directory-as-a-volume-in-docker-on-windows-10
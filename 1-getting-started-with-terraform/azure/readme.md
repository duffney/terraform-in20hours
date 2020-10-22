# Chapter 1: Getting Started with Terraform

## Setting Up Your Azure Account

---

**Prerequisites**

* [Azure Account](https://azure.microsoft.com/en-us/free/)
* [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)

> Note: All code examples are from a PowerShell prompt

---

**Install** `AzCLI`

```
#mac
brew update && brew install azure-cli

#windows
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
```

**Connect to Azure with AzCLI**

1. Run `az login`
2. Select the correct Azure subscription to authenticate to

**Install Terraform & Connect to Azure**

Build the `terraform-in20hours` Docker image

```
docker build . -t terraform-in20hours
```

Start the `terraform-in20hours` container

```
docker run --rm -it -v ${home}/.azure:/root/.azure -v ${PWD}:/terraform -w /terraform terraform-in20hours
```

_Terraform is using AzCLI for authentication. Mounting the `.azure` directory shares the authentication with your local machine._
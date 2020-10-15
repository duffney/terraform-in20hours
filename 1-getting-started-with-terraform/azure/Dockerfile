FROM mcr.microsoft.com/powershell:latest

ENV TERRAFORM_VERSION 0.13.4 
ENV TERRAFORM_AZURE_SP terraform-in20hours 

RUN apt-get update && apt-get install wget unzip

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    pwsh -c "Set-PackageSource -Name PSGallery -Trusted" && \
    pwsh -c "Install-Module AZ -Scope AllUsers"

COPY ["/set-profile.ps1","/tmp"]
RUN  ["pwsh","/tmp/set-profile.ps1"]

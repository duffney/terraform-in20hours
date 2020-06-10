FROM mcr.microsoft.com/powershell:7.0.0-ubuntu-18.04

ENV TERRAFORM_VERSION 0.12.26

RUN apt-get update && apt-get install wget unzip

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    pwsh -c "Set-PackageSource -Name PSGallery -Trusted" && \
    pwsh -c "Install-Module AZ -Scope AllUsers"

WORKDIR /work
### Azure Provisioning
This module helps us to create N number of VMs on Azure via terraform.

## Setup

# Azure
Please install azure client on your laptop. 
```
$az --version
azure-cli                         2.0.64 *

acr                                2.2.6 *
acs                                2.4.1 *
***More verbose logs***
Legal docs and information: aka.ms/AzureCliLegal
```
Configure aws credentials using "azure configure". It normally stores these files under .azure in your home directory. Verify your azure client credentials by running
```
$az login
$az account list --output table
Name            CloudName    SubscriptionId                        State    IsDefault
--------------  -----------  ------------------------------------  -------  -----------
SUB-NAME        AzureCloud   SUBSCRIPTION-ID                       Enabled  True
$az account set --subscription "SUBSCRIPTION-ID"
```

# Variables
Modify variables.tf as per your aws environment. Also change number of virtual machines to suit your needs.   
You may update these variables by passing it as terraform command line parameters too.
- name_prefix [Name prefix]
- resource_group_name [Resoure group name]
- location [Azure location]
- vmsize [VM size]
- vmcount [VM Count]
- subnet_name [Subnet name]
- vnet_name [Vnet name]
- vnet_rg [network resource group]

# SSH key pair
Ssh key pair generation is automatic and managed by terraform. Once terraform is applied you will find it under 'ssh_keys' folder.   

# Terraform
Install terraform from https://www.terraform.io/downloads.html (version 0.12+)
```
$terraform -version
Terraform v0.12.0

Your version of Terraform is out of date! The latest version
is 0.12.16. You can update by downloading from www.terraform.io/downloads.html
```

Run command below to initialize terraform based on your *.tf files.
```
$terraform init
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "azurerm" (hashicorp/azurerm) 1.37.0...
- Downloading plugin for provider "tls" (hashicorp/tls) 2.1.1...
- Downloading plugin for provider "null" (hashicorp/null) 2.1.2...

***More verbose logs***

Terraform has been successfully initialized!

***More verbose logs***
```


## Virtual Machines
# Terraform apply
Run terraform apply to create VMs on Azure.
```
$terraform apply
$terraform apply -auto-approve
$terraform apply -var "name_prefix=euw-gatling" -var "location=westeurope" -var "vmsize=Standard_D2_v2" -var "vmcount=3" -var "subnet_name=euw-gatling-sn" -var "vnet_name=euw-gatling-vn" -var "vnet_rg=euw-gatling-rg" -var "simulationclass=HttpBinSimulation"
$terraform apply -var "name_prefix=euw-gatling" -var "location=westeurope" -var "vmsize=Standard_D2_v2" -var "vmcount=3" -var "subnet_name=euw-gatling-sn" -var "vnet_name=euw-gatling-vn" -var "vnet_rg=euw-gatling-rg" -var "simulationclass=HttpBinSimulation" -auto-approve
```
You may keep on appending variables like shown above or you can change variables.tf file as shown above.    
Additionally you add flag '-auto-approve' to execute terraform without manual confirmation   

## Cleanup
# Terraform destroy
```
$terraform destroy
$terraform destroy -auto-approve
$terraform destroy -var "name_prefix=euw-gatling" -var "location=westeurope" -var "vmsize=Standard_D2_v2" -var "vmcount=3" -var "subnet_name=euw-gatling-sn" -var "vnet_name=euw-gatling-vn" -var "vnet_rg=euw-gatling-rg" -var "simulationclass=HttpBinSimulation"
$terraform destroy -var "name_prefix=euw-gatling" -var "location=westeurope" -var "vmsize=Standard_D2_v2" -var "vmcount=3" -var "subnet_name=euw-gatling-sn" -var "vnet_name=euw-gatling-vn" -var "vnet_rg=euw-gatling-rg" -var "simulationclass=HttpBinSimulation" -auto-approve
```
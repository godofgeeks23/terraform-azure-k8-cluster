# # Configure the Azure provider
# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 3.0.2"
#     }
#   }

#   required_version = ">= 1.1.0"
# }

# provider "azurerm" {
#   features {}
# }

# resource "azurerm_resource_group" "rg" {
#   name     = "myTFResourceGroup"
#   location = "centralindia"

#   tags = {
#     Environment = "Terraform Getting Started"
#     Team        = "DevOps"
#   }

# }

# # Create a virtual network
# resource "azurerm_virtual_network" "vnet" {
#   name                = "myTFVnet"
#   address_space       = ["10.0.0.0/16"]
#   location            = "centralindia"
#   resource_group_name = azurerm_resource_group.rg.name
# }

provider "azurerm" {
  features {}
}

variable "vm_count" {
  default = 5
}

resource "azurerm_resource_group" "rg" {
  name     = "k8s-cluster-rg"
  location = "centralindia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "k8s-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "k8s-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "k8s-node-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B2s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # custom_data = filebase64("cloud-init.yaml")
}

#provider "azurerm" {
#  features {}
#}

data "azurerm_subscription" "current" {
}

data azurerm_resource_group "rg" {
    name="tfe"
}

data azurerm_virtual_network "vnet"{
    resource_group_name= data.azurerm_resource_group.rg.name
    name="tfe-net"
}

#resource "azurerm_virtual_network" "vnet" {
##  name                = "win11-vnet"
#  address_space       = ["10.0.0.10/16"]
#  location            = data.azurerm_resource_group.rg.location
#  resource_group_name = data.azurerm_resource_group.rg.name
#}

resource "azurerm_subnet" "subnet" {
  name                 = "win11-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "win11-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "tfe-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

/*
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
*/

  security_rule {
    name                       = "Allow-WAC"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6516"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  
}

resource "azurerm_network_interface" "nic" {
  name                = "win11-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "win11" {
  name                = "win11-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "GG!*jKtp*!HH5Y#2Yt"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "win11-osdisk"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-pro"
    version   = "latest"
  }

  identity{
    type = "SystemAssigned"
  }

  automatic_updates_enabled = true
}

#resource "time_sleep" "wait_for_service_principal"{
#  depends_on = [azurerm_windows_virtual_machine.win11]
#}

resource "azurerm_role_assignment" "admin" {
 
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_windows_virtual_machine.win11.identity[0].principal_id
 
}

resource "azurerm_role_assignment" "User" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_windows_virtual_machine.win11.identity[0].principal_id
 
}

resource "azurerm_role_assignment" "Contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = azurerm_windows_virtual_machine.win11.identity[0].principal_id
 
}


output "win11_public_ip" {
  value = azurerm_public_ip.pip.ip_address
  description = "Public IP address of the Windows 11 VM"
}
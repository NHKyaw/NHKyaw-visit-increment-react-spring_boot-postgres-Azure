data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


locals {
  project_prefix = "${var.environment}-az-visit-increment"
}

resource "azurerm_virtual_network" "az_visit_increment_vnet" {
  name                = "${local.project_prefix}-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.vm-net-cidr]
}


resource "azurerm_subnet" "az_visit_increment_subnet" {
  name                 = "${local.project_prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.az_visit_increment_vnet.name
  address_prefixes     = [var.cidr-env]
}

resource "azurerm_public_ip" "az_visit_increment_public_ip" {
  name                = "${local.project_prefix}-public-ip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "az_visit_increment_nsg" {
  name                = "${local.project_prefix}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "az_visit_increment_nic" {
  name                = "${local.project_prefix}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_visit_increment_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_visit_increment_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.az_visit_increment_nic.id
  network_security_group_id = azurerm_network_security_group.az_visit_increment_nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${local.project_prefix}-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = "Standard_D2s_v3"
  admin_username      = var.vm_admin_username

  network_interface_ids = [
    azurerm_network_interface.az_visit_increment_nic.id
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_virtual_machine_extension" "docker" {
  name                 = "${local.project_prefix}-docker-extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "commandToExecute": "apt-get update && apt-get install -y ca-certificates curl gnupg && install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && chmod a+r /etc/apt/keyrings/docker.gpg && echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && usermod -aG docker nhkyaw"
    }
  SETTINGS

  timeouts {
    create = "30m"
  }
}
# resource "azurerm_virtual_machine_extension" "docker" {
#   name                 = "${local.project_prefix}-docker-extension"
#   virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   settings = <<SETTINGS
#     {
#       "commandToExecute": "bash install.sh" 
#     }
#   SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#       "fileUris": ["https://raw.githubusercontent.com/docker/docker-install/master/install.sh"]
#     }
#   PROTECTED_SETTINGS

#   timeouts {
#     create = "30m"
#   }
# }

terraform {
  backend "azurerm" {
    resource_group_name  = "th-lab_group"
    storage_account_name = "nhkstgacc"
    container_name       = "tfstate"
  }
}




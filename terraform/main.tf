provider "azurerm" {
  features {}
}

# Creating a resource group
resource "azurerm_resource_group" "myapp-res-grp" {
  name     = "${var.env_prefix}_res_grp"
  location = "West Europe"
}

# Creating a virtual network
resource "azurerm_virtual_network" "myapp-vn" {
  name                = "${var.env_prefix}-vpc"
  address_space       = [var.vn_cidr_block]
  location            = azurerm_resource_group.myapp-res-grp.location
  resource_group_name = azurerm_resource_group.myapp-res-grp.name
}

# Creating a subnet
resource "azurerm_subnet" "myapp-subnet" {
  name                 = "${var.env_prefix}-subnet-1"
  address_prefixes     = [var.subnet_cidr_block]
  resource_group_name  = azurerm_resource_group.myapp-res-grp.name
  virtual_network_name = azurerm_virtual_network.myapp-vn.name
}

# Creating a route table
resource "azurerm_route_table" "myapp-route-table" {
  name                          = "${var.env_prefix}-rtb"
  location                      = azurerm_resource_group.myapp-res-grp.location
  resource_group_name           = azurerm_resource_group.myapp-res-grp.name
  disable_bgp_route_propagation = false

  route {
    name           = "${var.env_prefix}-route1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

# Associate the route table with the subnet
resource "azurerm_subnet_route_table_association" "myapp-rt-association" {
  subnet_id      = azurerm_subnet.myapp-subnet.id
  route_table_id = azurerm_route_table.myapp-route-table.id
}

# Create a public IP address
resource "azurerm_public_ip" "myapp-public-ip" {
  name                = "${var.env_prefix}-public-ip"
  location            = azurerm_resource_group.myapp-res-grp.location
  resource_group_name = azurerm_resource_group.myapp-res-grp.name
  allocation_method   = "Static"
}

# Create a network security group (NSG)
resource "azurerm_network_security_group" "myapp-nsg" {
  name                = "${var.env_prefix}-nsg"
  location            = azurerm_resource_group.myapp-res-grp.location
  resource_group_name = azurerm_resource_group.myapp-res-grp.name
  # Allow SSH (port 22) traffic
  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001 # Choose an appropriate priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # Allow port 8080 traffic (HTTP)
  security_rule {
    name                       = "allow-8080"
    priority                   = 1002 # Choose an appropriate priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "myapp-net-int-sec-grp-association" {
  network_interface_id      = azurerm_network_interface.myapp-net-interface.id
  network_security_group_id = azurerm_network_security_group.myapp-nsg.id
}

resource "azurerm_network_interface" "myapp-net-interface" {
  name                = "${var.env_prefix}-nic"
  location            = azurerm_resource_group.myapp-res-grp.location
  resource_group_name = azurerm_resource_group.myapp-res-grp.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.myapp-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myapp-public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "myapp-vm" {
  name                  = "${var.env_prefix}-machine"
  resource_group_name   = azurerm_resource_group.myapp-res-grp.name
  location              = azurerm_resource_group.myapp-res-grp.location
  size                  = "Standard_DS1_v2"
  admin_username        = var.vm_credentials.username
  network_interface_ids = [azurerm_network_interface.myapp-net-interface.id]

  # admin_password      = var.vm_credentials.password
  admin_ssh_key {
    username   = var.vm_credentials.username
    public_key = file(var.vm_credentials.ssh_file_location)
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  user_data = filebase64("docker.sh")
}

output "vm_ip" {
  value = azurerm_linux_virtual_machine.myapp-vm.public_ip_address
}

variable "vn_cidr_block" {
  description = "CIDR block for the Azure Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  description = "CIDR block for the Azure Subnet"
  type        = string
  default     = "10.0.10.0/24"
}
variable "env_prefix" {
  description = "Prefix for naming Azure resources"
  type        = string
  default     = "dev"
}
variable "vm_credentials" {
  description = "Credentials for the Azure Virtual Machine"
  type = object({
    username          = string
    ssh_file_location = string
  })
  default = {
    username          = "azureuser"
    ssh_file_location = "/root/.ssh/my_ssh_key.pub"
  }
}
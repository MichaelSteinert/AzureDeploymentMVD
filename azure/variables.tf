variable "resource_group_location" {
  type        = string
  default     = "germanywestcentral"
  description = "Location in West Central Germany for Resource Group."
}

variable "mvd_resource_group_name_prefix" {
  type        = string
  default     = "mvd"
  description = "Prefix of the Resource Group Name that is combined with a random ID so Name is unique in Azure Subscription."
}

variable "mvd_username" {
  type        = string
  description = "The Username for the local Account that will be created on the new VM."
  default     = "mvdadmin"
}

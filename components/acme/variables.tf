variable "root_id" {
  type    = string
  default = "hmcts"
}

variable "root_name" {
  type    = string
  default = "HMCTS Programmes"
}

# unused
variable "env" {}
variable "builtFrom" {}
variable "product" {}

variable "subscriptions" {
  default = {}
}

variable "location" {
  default = "UK South"
}

variable "acme_storage_account_repl_type" {
  default = "ZRS"
}

variable "allow_nested_items_to_be_public" {
  default = false
}

variable "expiresAfter" {
  description = "Date when Sandbox resources can be deleted. Format: YYYY-MM-DD"
  default     = "3000-01-01"
}

variable "subscription_id" {
  description = "The ID of the subscription that contains the DNS Zones"
  default     = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
  type        = string
}

variable "additional_dns_contributor_envs" {
  type    = set(string)
  default = []
}

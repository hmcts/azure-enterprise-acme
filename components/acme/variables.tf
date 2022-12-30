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
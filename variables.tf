variable "chart" { type = string }
variable "domain" { type = string }
variable "entrypoints" { type = list(string) }
variable "extras" { default = {} }
variable "middlewares" { type = list(map(string)) }
variable "middlewares_namespace" { type = string }
variable "repository" { type = string }

variable "create_namespace" {
  default = false
  type    = bool
}

variable "traefik-api-version" {
  default = "traefik.containo.us/v1alpha1"
  type    = string
}

variable "no_set_defaults" {
  default = false
  type    = bool
}

variable "dns_servers" {
  default = [
    "8.8.8.8",
    "8.8.4.4",
  ]
  type = list(string)
}

variable "env" {
  default = { env = { PGID = 1000, PUID = 1000, TZ = "America/Los_Angeles" } }
  type    = object({ env = optional(map(string), {}) }, {})
}

variable "image" {
  type = object({
    pullPolicy = string
    registry   = string
    tag        = string
  })
}

variable "exempt_values" {
  default     = ["nfs-subdir-external-provisioner"]
  description = "Charts to exempt from dynamic value parsing"
  type        = list(string)
}

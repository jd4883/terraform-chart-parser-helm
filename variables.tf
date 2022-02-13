variable "chart" { type = string }
variable "domain" { type = string }
variable "entrypoints" { type = list(string) }
variable "extras" { default = {} }
variable "middlewares" { type = list(map(string)) }
variable "middlewares_namespace" { type = string }
variable "repository" { type = string }

variable "traefik-api-version" {
  type    = string
  default = "traefik.containo.us/v1alpha1"
}

variable "no_set_defaults" {
  type    = bool
  default = false
}

variable "dns_servers" {
  type = list(string)
  default = [
    "8.8.8.8",
    "8.8.4.4",
  ]
}

variable "env" {
  type = map(object({
    PUID = number
    PGID = number
    TZ   = string
  }))
  default = {
    env = {
      PGID = 1000
      PUID = 1000
      TZ   = "America/Los_Angeles"
    }
  }
}

variable "image" {
  type = object({
    pullPolicy = string
    registry   = string
    tag        = string
  })
}

variable "exempt_values" {
  description = "Charts to exempt from dynamic value parsing"
  type        = list(string)
  default = [
    "nfs-subdir-external-provisioner",
  ]
}

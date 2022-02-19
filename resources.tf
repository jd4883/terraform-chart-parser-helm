resource "helm_release" "chart" {
  atomic                     = tobool(lookup(var.extras, "atomic", false))
  chart                      = var.chart
  cleanup_on_fail            = tobool(lookup(var.extras, "cleanup_on_fail", true))
  create_namespace           = false
  dependency_update          = tobool(lookup(var.extras, "dependency_update", true))
  description                = lookup(var.extras, "description", null)
  devel                      = lookup(var.extras, "devel", null)
  disable_crd_hooks          = tobool(lookup(var.extras, "disable_crd_hooks", false))
  disable_openapi_validation = tobool(lookup(var.extras, "disable_openapi_validation", true))
  disable_webhooks           = tobool(lookup(var.extras, "disable_webhooks", false))
  force_update               = tobool(lookup(var.extras, "force_update", false))
  keyring                    = lookup(var.extras, "keyring", null)
  lint                       = tobool(lookup(var.extras, "lint", true))
  max_history                = lookup(var.extras, "max_history", 0)
  name                       = local.name
  namespace                  = local.namespace
  recreate_pods              = tobool(lookup(var.extras, "recreate_pods", false))
  render_subchart_notes      = tobool(lookup(var.extras, "render_subchart_notes", true))
  replace                    = tobool(lookup(var.extras, "replace", false))
  repository                 = var.repository
  repository_ca_file         = lookup(var.extras, "repository_ca_file", null)
  repository_cert_file       = lookup(var.extras, "repository_cert_file", null)
  repository_key_file        = lookup(var.extras, "repository_key_file", null)
  repository_password        = lookup(var.extras, "repository_password", null)
  repository_username        = lookup(var.extras, "repository_username", null)
  reset_values               = tobool(lookup(var.extras, "reset_values", false))
  reuse_values               = tobool(lookup(var.extras, "reuse_values", true))
  skip_crds                  = tobool(lookup(var.extras, "skip_crds", false))
  timeout                    = lookup(var.extras, "timeout", 60)
  values                     = [local.values]
  verify                     = tobool(lookup(var.extras, "verify", false))
  version                    = lookup(var.extras, "version", null)
  wait                       = tobool(lookup(var.extras, "wait", true))
  wait_for_jobs              = tobool(lookup(var.extras, "wait_for_jobs", true))
  dynamic "set" {
    for_each = concat(
      anytrue([(var.no_set_defaults), contains(var.exempt_values, var.chart)]) ? [] : [for server in var.dns_servers : {
        name  = "podDnsConfig.nameservers[${index(var.dns_servers, server)}]"
        value = server
      }],
      anytrue([!(var.chart == "nfs-subdir-external-provisioner")]) ? [
        {
          name  = "podDnsConfig.searches[0]"
          value = var.domain
        },
      ] : [],
      lookup(var.extras, "set", []),
    )
    content {
      name  = set.value.name
      value = set.value.value
      type  = lookup(set.value, "type", "string")
    }
  }
  dynamic "set_sensitive" {
    for_each = concat(
      lookup(var.extras, "set_sensitive", [])
    )
    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
      type  = lookup(set_sensitive.value, "type", "string")
    }
  }
  dynamic "postrender" {
    for_each = concat(
      lookup(var.extras, "postrender", [])
    )
    content {
      binary_path = postrender.value.binary_path
    }
  }
  lifecycle {
    ignore_changes = [status]
  }
}

resource "kubectl_manifest" "ingress-route" {
  count           = can(var.extras.ingress) ? 1 : 0
  yaml_body       = yamlencode(local.ingress)
  validate_schema = true
  depends_on      = [helm_release.chart]
}

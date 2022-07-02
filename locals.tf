locals {
  atomic                     = tobool(lookup(var.extras, "atomic", false))
  cleanup_on_fail            = tobool(lookup(var.extras, "cleanup_on_fail", true))
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
  middlewares_namespace      = lookup(var.extras, "middlewares_namespace", var.middlewares_namespace)
  namespace                  = lookup(var.extras, "namespace", "default")
  postrender                 = distinct(concat(lookup(var.extras, "postrender", [])))
  recreate_pods              = tobool(lookup(var.extras, "recreate_pods", false))
  render_subchart_notes      = tobool(lookup(var.extras, "render_subchart_notes", true))
  replace                    = tobool(lookup(var.extras, "replace", false))
  repository_ca_file         = lookup(var.extras, "repository_ca_file", null)
  repository_cert_file       = lookup(var.extras, "repository_cert_file", null)
  repository_key_file        = lookup(var.extras, "repository_key_file", null)
  repository_password        = lookup(var.extras, "repository_password", null)
  repository_username        = lookup(var.extras, "repository_username", null)
  reset_values               = tobool(lookup(var.extras, "reset_values", false))
  reuse_values               = tobool(lookup(var.extras, "reuse_values", true))
  set = distinct(
    concat(
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
  )
  set_sensitive = distinct(concat(lookup(var.extras, "set_sensitive", [])))
  skip_crds     = tobool(lookup(var.extras, "skip_crds", false))
  timeout       = lookup(var.extras, "timeout", 60)
  verify        = tobool(lookup(var.extras, "verify", false))
  version       = lookup(var.extras, "version", null)
  wait          = tobool(lookup(var.extras, "wait", true))
  wait_for_jobs = tobool(lookup(var.extras, "wait_for_jobs", true))
  middlewares = distinct(
    [
      for i in lookup(var.extras, "middlewares", var.middlewares) : {
        name      = i.name
        namespace = local.namespace
      }
    ]
  )
  name   = lookup(var.extras, "name", var.chart)
  domain = lookup(var.extras, "domain", var.domain)
  values = yamlencode(
    merge(
      anytrue([(var.no_set_defaults), contains(var.exempt_values, var.chart)]) ? {} : var.env,
      { image = var.image },
      lookup(var.extras, "values", {}),
    )
  )
  ingress = {
    apiVersion = var.traefik-api-version
    kind       = "IngressRoute"
    metadata = {
      name      = local.name
      namespace = local.namespace
    }
    spec = {
      entryPoints = lookup(var.extras, "entrypoints", var.entrypoints)
      routes = [
        {
          match       = "Host(${join(", ", formatlist("`%s.${local.domain}`", distinct(concat([local.name], lookup(var.extras, "subdomains", [])))))})"
          kind        = "Rule"
          middlewares = local.middlewares
          services = [
            {
              name = lookup(var.extras, "service_name", local.name)
              kind = lookup(var.extras, "service_kind", "Service")
              port = lookup(var.extras, "service_port", 80)
            }
          ]
        }
      ]
      tls = { secretName = "${local.domain}-tls" }
    }
  }
}

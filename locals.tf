locals {
  namespace             = lookup(var.extras, "namespace", "default")
  middlewares_namespace = lookup(var.extras, "middlewares_namespace", var.middlewares_namespace)
  middlewares = [
    for i in lookup(var.extras, "middlewares", var.middlewares) : {
      name      = i.name
      namespace = local.namespace
    }
  ]
  name   = lookup(var.extras, "name", var.chart)
  domain = lookup(var.extras, "domain", var.domain)
  values = yamlencode(
    merge(
      (!contains(var.exempt_values, var.chart) ? var.env : {}),
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

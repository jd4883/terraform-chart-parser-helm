resource "helm_release" "chart" {
  atomic                     = local.atomic
  chart                      = var.chart
  cleanup_on_fail            = local.cleanup_on_fail
  create_namespace           = var.create_namespace
  dependency_update          = local.dependency_update
  description                = local.description
  devel                      = local.devel
  disable_crd_hooks          = local.disable_crd_hooks
  disable_openapi_validation = local.disable_openapi_validation
  disable_webhooks           = local.disable_webhooks
  force_update               = local.force_update
  keyring                    = local.keyring
  lint                       = local.lint
  max_history                = local.max_history
  name                       = local.name
  namespace                  = local.namespace
  recreate_pods              = local.recreate_pods
  render_subchart_notes      = local.render_subchart_notes
  replace                    = local.replace
  repository                 = var.repository
  repository_ca_file         = local.repository_ca_file
  repository_cert_file       = local.repository_cert_file
  repository_key_file        = local.repository_key_file
  repository_password        = local.repository_password
  repository_username        = local.repository_username
  reset_values               = local.reset_values
  reuse_values               = local.reuse_values
  skip_crds                  = local.skip_crds
  timeout                    = local.timeout
  values                     = [local.values]
  verify                     = local.verify
  version                    = local.version
  wait                       = local.wait
  wait_for_jobs              = local.wait_for_jobs
  dynamic "set" {
    for_each = local.set
    content {
      name  = set.value.name
      type  = lookup(set.value, "type", "string")
      value = set.value.value
    }
  }
  dynamic "set_sensitive" {
    for_each = local.set_sensitive
    content {
      name  = set_sensitive.value.name
      type  = lookup(set_sensitive.value, "type", "string")
      value = set_sensitive.value.value
    }
  }
  dynamic "postrender" {
    for_each = local.postrender
    content { binary_path = postrender.value.binary_path }
  }
}

resource "kubectl_manifest" "ingress-route" {
  count           = can(var.extras.ingress) ? 1 : 0
  validate_schema = true
  yaml_body       = yamlencode(local.ingress)
  depends_on      = [helm_release.chart]
}

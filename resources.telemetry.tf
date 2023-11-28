resource "azurerm_subscription_template_deployment" "telemetry" {
  count            = local.telemetry_deployment_enabled ? 1 : 0
  name             = local.telemetry_arm_deployment_name
  location         = var.location
  template_content = local.telemetry_arm_subscription_template_content
}
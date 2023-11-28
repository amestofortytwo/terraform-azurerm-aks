locals {
  telemetry_aks_guid = "5538854f-10bc-41e9-a69c-9a0a7223740f"

  telemetry_arm_subscription_template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "variables": {},
  "resources": [],
  "outputs": {
    "telemetry": {
      "type": "String",
      "value": "For more information, see https://github.com/amestofortytwo/terraform-azurerm-aks#telemetry"
    }
  }
}
TEMPLATE

  telemetry_arm_deployment_name = substr(
    format(
      "pid-%s",
      local.telemetry_aks_guid
    ),
    0,
    64
  )

  telemetry_deployment_enabled = !var.disable_telemetry
}

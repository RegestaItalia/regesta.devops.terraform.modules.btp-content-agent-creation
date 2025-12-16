terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.18.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "~> 1.11.0"
    }
  }
}

# -------------------
# VARIABILI
# -------------------
variable "subaccountid" {
  type = string
}

variable "spaceid" {
  type = string
}

variable "ctms_service_key" {
  type        = string
  description = "Service key JSON for Cloud Transport Management Service (optional). If provided, creates a TransportManagementService destination."
  default     = null
  sensitive   = true
}

# -------------------
# DATA SOURCE
# -------------------
data "btp_subaccount" "current" {
  id = var.subaccountid
}

# -------------------
# AGENT UI INTEGRATION
# -------------------
resource "btp_subaccount_subscription" "content-agent-ui" {
  subaccount_id = var.subaccountid
  app_name      = "content-agent-ui"
  plan_name     = "free"
}

# -------------------
# CLOUD FOUNDRY SERVICES
# -------------------
data "cloudfoundry_service_plan" "content-agent" {
  name                  = "standard"
  service_offering_name = "content-agent"
}

resource "cloudfoundry_service_instance" "content-agent" {
  name         = "content-agent"
  type         = "managed"
  space        = var.spaceid
  service_plan = data.cloudfoundry_service_plan.content-agent.id
}

resource "cloudfoundry_service_credential_binding" "content-agent-key" {
  type             = "key"
  name             = "content-agent-key"
  service_instance = cloudfoundry_service_instance.content-agent.id
}

data "cloudfoundry_service_plan" "content-agent-application" {
  name                  = "application"
  service_offering_name = "content-agent"
}

resource "cloudfoundry_service_instance" "content-agent-application" {
  name         = "content-agent-application"
  type         = "managed"
  space        = var.spaceid
  service_plan = data.cloudfoundry_service_plan.content-agent-application.id
  parameters = jsonencode({
    roles = [
      "Import",
      "Read",
      "Export",
      "Security Operator"
    ]
  })
}

resource "cloudfoundry_service_credential_binding" "content-agent-application-key" {
  type             = "key"
  name             = "content-agent-application-key"
  service_instance = cloudfoundry_service_instance.content-agent-application.id
}

# -------------------
# DESTINATION (CONDITIONAL)
# -------------------
resource "btp_subaccount_destination" "transport-management-service" {
  count = var.ctms_service_key != null ? 1 : 0

  subaccount_id  = var.subaccountid
  name           = "TransportManagementService"
  type           = "HTTP"
  url            = jsondecode(var.ctms_service_key)["uri"]
  authentication = "OAuth2ClientCredentials"
  proxy_type     = "Internet"
  description    = "Cloud Transport Management Service destination"
  
  additional_configuration = jsonencode({
    clientId            = jsondecode(var.ctms_service_key)["uaa"]["clientid"]
    clientSecret        = jsondecode(var.ctms_service_key)["uaa"]["clientsecret"]
    tokenServiceURL     = "${jsondecode(var.ctms_service_key)["uaa"]["url"]}/oauth/token"
    tokenServiceURLType = "Dedicated"
  })
}

# -------------------
# OUTPUT
# -------------------
output "service-key" {
  value     = cloudfoundry_service_credential_binding.content-agent-key
  sensitive = true
}

output "service-key-application" {
  value     = cloudfoundry_service_credential_binding.content-agent-application-key
  sensitive = true
}

output "ctms-destination" {
  value = var.ctms_service_key != null ? {
    name = btp_subaccount_destination.transport-management-service[0].name
    url  = btp_subaccount_destination.transport-management-service[0].url
  } : null
  description = "Cloud Transport Management Service destination details (if CTMS service key was provided)"
}

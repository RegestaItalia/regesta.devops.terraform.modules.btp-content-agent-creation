terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.12.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.9.0"
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

# -------------------
# OUTPUT
# -------------------
output "service-key" {
  value     = cloudfoundry_service_credential_binding.content-agent-key
  sensitive = true
}

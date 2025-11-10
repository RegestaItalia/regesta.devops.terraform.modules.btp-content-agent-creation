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

variable "content-agent-plan" {
  type    = string
  default = "default"
}

# -------------------
# DATA SOURCE
# -------------------
data "btp_subaccount" "current" {
  id = var.subaccountid
}

# -------------------
# ENTITLEMENTS & SUBSCRIPTION
# -------------------
resource "btp_subaccount_entitlement" "content-agent" {
  subaccount_id = var.subaccountid
  service_name  = "content-agent"
  plan_name     = var.content-agent-plan
}

# -------------------
# CLOUD FOUNDRY SERVICES
# -------------------
data "cloudfoundry_service_plan" "content-agent" {
  depends_on            = [btp_subaccount_entitlement.content-agent]
  name                  = var.content-agent-plan
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

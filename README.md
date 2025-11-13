````markdown


# Modulo Terraform: BTP Content Agent Creation

Questo modulo Terraform abilita le entitlements, crea la subscription e le istanze di servizio necessarie per SAP Content Agent su un subaccount e uno space Cloud Foundry.


## Provider richiesti

```hcl
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
```



### Configurazione dei provider

Esempio di configurazione dei provider con placeholder:

```hcl
provider "btp" {
  globalaccount = "<GLOBALACCOUNT_ID>" # ID dell'account globale BTP
  username      = "<USERNAME>"          # Username per autenticazione
  password      = "<PASSWORD>"          # Password per autenticazione
}

provider "cloudfoundry" {
  api_url  = "<CF_API_URL>" # URL dell'API Cloud Foundry
  user     = "<USERNAME>"   # Username per autenticazione
  password = "<PASSWORD>"   # Password per autenticazione
}
```

#### Spiegazione parametri
**Provider BTP**
- `globalaccount`: ID dell'account globale BTP.
- `username`: username per autenticazione.
- `password`: password per autenticazione.

**Provider Cloud Foundry**
- `api_url`: URL dell'API Cloud Foundry.
- `user`: username per autenticazione.
- `password`: password per autenticazione.



## Guida all'utilizzo

```hcl
module "content_agent" {
  source = "git::https://github.com/RegestaItalia/regesta.devops.terraform.modules.btp-content-agent-creation.git?ref=main"

  subaccountid = "your_subaccount_id"
  spaceid      = "your_space_id"
}
```


## Variabili di input

- **subaccountid** (string): ID del subaccount BTP.
- **spaceid** (string): ID dello space Cloud Foundry.




## Output

- **service-key**: Oggetto della chiave di servizio generata per Content Agent (piano standard). Contiene le credenziali necessarie per accedere al servizio.
- **service-key-application**: Oggetto della chiave di servizio generata per Content Agent (piano application). Contiene le credenziali necessarie per accedere al servizio.


## Risorse create

- **Subscription** per `content-agent-ui` con piano `free`
- **Istanza gestita** di servizio Cloud Foundry per `content-agent` con piano `standard`
- **Service key** per `content-agent` (piano standard)
- **Istanza gestita** di servizio Cloud Foundry per `content-agent-application` con piano `application`
- **Service key** per `content-agent-application` (piano application)

````

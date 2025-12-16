````markdown


# Modulo Terraform: BTP Content Agent Creation

Questo modulo Terraform abilita le entitlements, crea la subscription e le istanze di servizio necessarie per SAP Content Agent su un subaccount e uno space Cloud Foundry.


## Provider richiesti

```hcl
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

### Utilizzo base

```hcl
module "content_agent" {
  source = "git::https://github.com/RegestaItalia/regesta.devops.terraform.modules.btp-content-agent-creation.git?ref=main"

  subaccountid = "your_subaccount_id"
  spaceid      = "your_space_id"
}
```

### Utilizzo con destinazione CTMS

```hcl
module "content_agent" {
  source = "git::https://github.com/RegestaItalia/regesta.devops.terraform.modules.btp-content-agent-creation.git?ref=main"

  subaccountid     = "your_subaccount_id"
  spaceid          = "your_space_id"
  ctms_service_key = jsonencode({
    uri = "https://your-ctms-url"
    uaa = {
      clientid     = "your_client_id"
      clientsecret = "your_client_secret"
      url          = "https://your-uaa-url"
    }
  })
}
```


## Variabili di input

- **subaccountid** (string, required): ID del subaccount BTP.
- **spaceid** (string, required): ID dello space Cloud Foundry.
- **ctms_service_key** (string, optional, sensitive): Service key JSON per Cloud Transport Management Service. Se fornita, viene creata automaticamente una destinazione chiamata "TransportManagementService".




## Output

- **service-key**: Oggetto della chiave di servizio generata per Content Agent (piano standard). Contiene le credenziali necessarie per accedere al servizio (sensitive).
- **service-key-application**: Oggetto della chiave di servizio generata per Content Agent (piano application). Contiene le credenziali necessarie per accedere al servizio (sensitive).
- **ctms-destination**: Dettagli della destinazione CTMS creata (nome e URL), se la chiave CTMS è stata fornita. Null altrimenti.

## Risorse create

- **Subscription** per `content-agent-ui` con piano `free`
- **Istanza gestita** di servizio Cloud Foundry per `content-agent` con piano `standard`
- **Service key** per `content-agent` (piano standard)
- **Istanza gestita** di servizio Cloud Foundry per `content-agent-application` con piano `application` (con ruoli: Import, Read, Export, Security Operator)
- **Service key** per `content-agent-application` (piano application)
- **Destinazione BTP** "TransportManagementService" (opzionale, solo se `ctms_service_key` è fornita)

## Note

- Se viene fornita la variabile `ctms_service_key`, il modulo crea automaticamente una destinazione BTP chiamata "TransportManagementService" configurata con OAuth2ClientCredentials
- La destinazione CTMS utilizza i parametri estratti dalla service key fornita per configurare l'autenticazione

````

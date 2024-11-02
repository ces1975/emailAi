provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-genai-email"
  location = "East US"  # escolha a região que preferir
}

resource "azurerm_cognitive_account" "openai_account" {
  name                = "genai-email-openai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "OpenAI"  # Tipo de serviço de IA

  sku_name = "S0"  # Selecione o SKU mais adequado para o seu caso

  capabilities {
    enable_openai = true
  }
}

resource "azurerm_cognitive_deployment" "openai_deployment" {
  name                = "gpt-email-assistant"
  cognitive_account_id = azurerm_cognitive_account.openai_account.id
  deployment_model    = "text-davinci-003"  # Escolha o modelo desejado

  # Opcional: configure as propriedades do modelo
  scale_settings {
    scale_type = "Standard"
  }
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.openai_account.endpoint
}

resource "azurerm_key_vault" "openai_keyvault" {
  name                = "openaiKeyVault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
}

resource "azurerm_key_vault_secret" "openai_api_key" {
  name         = "openai-api-key"
  value        = azurerm_cognitive_account.openai_account.primary_access_key
  key_vault_id = azurerm_key_vault.openai_keyvault.id
}

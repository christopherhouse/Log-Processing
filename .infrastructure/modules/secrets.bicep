param keyVaultName string
param apimApplicationInisightsName string
param functionAppApplicationInsightsName string
param cosmosAccountName string
param storageAccountName string
param eventHubNamespaceName string

resource apimAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: apimApplicationInisightsName
  scope: resourceGroup()
}

resource functionAppAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: functionAppApplicationInsightsName
  scope: resourceGroup()
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource apimAppInsightsInstrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'apimApplicationInsightsInstrumentationKey'
  parent: keyVault
  properties: {
    value: apimAppInsights.properties.InstrumentationKey
  }
}

resource apimApplicationInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'apimApplicationInsightsConnectionString'
  parent: keyVault
  properties: {
    value: apimAppInsights.properties.ConnectionString
  }
}

resource funtionAppAppInsightsInstrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'functionAppApplicationInsightsInstrumentationKey'
  parent: keyVault
  properties: {
    value: functionAppAppInsights.properties.InstrumentationKey
  }
}

resource functionAppApplicationInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'functionAppApplicationInsightsConnectionString'
  parent: keyVault
  properties: {
    value: functionAppAppInsights.properties.ConnectionString
  }
}

resource cosmosDbConnectionStringSecret 'Microsoft.Keyvault/vaults/secrets@2022-07-01' = {
  name: 'cosmosDbConnectionString'
  parent: keyVault
  properties: {
    value: listConnectionStrings(resourceId('Microsoft.DocumentDb/databaseAccounts', cosmosAccountName), '2022-08-15').connectionStrings[0].connectionString
  }
}

resource storageAccountConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'storageAccountConnectionString'
  parent: keyVault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2022-09-01').keys[0].value};EndpointSuffix=core.windows.net'
  }
}

resource eventHub 'Microsoft.EventHub/namespaces@2022-01-01-preview' existing = {
  name: eventHubNamespaceName
  scope: resourceGroup()
}

resource eventHubListenAccessPolicy 'Microsoft.EventHub/namespaces/AuthorizationRules@2022-01-01-preview' existing = {
  name: 'rootListenAccessPolicy'
  parent: eventHub
}

resource eventHubSendAccessPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' existing = {
  name: 'rootSendAccessPolicy'
  parent: eventHub
}

resource eventHubSendAccessPolicySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'eventHubSendAccessPolicy'
  parent: keyVault
  properties: {
    value: eventHubSendAccessPolicy.properties.primaryConnectionString
  }
}

resource eventHubListenAccessPolicySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'eventHubListenAccessPolicy'
  parent: keyVault
  properties: {
    value: eventHubListenAccessPolicy.properties.primaryConnectionString
  }
}

output apimAppInsightsInstrumentationKeySecretUri string = apimAppInsightsInstrumentationKeySecret.properties.secretUri
output apimApplicationInsightsConnectionStringSecretUri string = apimApplicationInsightsConnectionStringSecret.properties.secretUri
output funtionAppAppInsightsInstrumentationKeySecretUri string = funtionAppAppInsightsInstrumentationKeySecret.properties.secretUri
output functionAppApplicationInsightsConnectionStringSecretUri string = functionAppApplicationInsightsConnectionStringSecret.properties.secretUri
